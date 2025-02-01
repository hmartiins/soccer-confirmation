import 'package:advanced_flutter/domain/entities/errors.dart';
import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:advanced_flutter/infra/cache/clients/cache_save_client.dart';
import 'package:advanced_flutter/infra/cache/mappers/next_event_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/fakes.dart';
import '../cache/mocks/cache_save_client_spy.dart';

final class LoadNextEventFromApiWithCacheFallbackRepository {
  final Future<NextEvent> Function({required String groupId})
      loadNextEventFromApi;
  final Future<NextEvent> Function({required String groupId})
      loadNextEventFromCache;
  final CacheSaveClient cacheClient;
  final String key;

  const LoadNextEventFromApiWithCacheFallbackRepository({
    required this.loadNextEventFromApi,
    required this.loadNextEventFromCache,
    required this.cacheClient,
    required this.key,
  });

  Future<NextEvent> loadNextEvent({required String groupId}) async {
    try {
      final event = await loadNextEventFromApi(groupId: groupId);
      final json = NextEventMapper().toJson(event);
      await cacheClient.save(key: '$key:$groupId', value: json);
      return event;
    } catch (_) {
      try {
        return await loadNextEventFromCache(groupId: groupId);
      } catch (e) {
        throw UnexpectedError();
      }
    }
  }
}

final class LoadNextEventRepositorySpy {
  String? groupId;
  int callsCount = 0;
  NextEvent output = NextEvent(
    groupName: anyString(),
    date: anyDateTime(),
    players: [],
  );
  Error? error;

  Future<NextEvent> loadNextEvent({required String groupId}) async {
    this.groupId = groupId;
    callsCount++;
    if (error != null) throw error!;
    return output;
  }
}

void main() {
  late String key;
  late String groupId;
  late LoadNextEventRepositorySpy apiRepo;
  late LoadNextEventRepositorySpy cacheRepo;
  late CacheSaveClientSpy cacheClient;
  late LoadNextEventFromApiWithCacheFallbackRepository sut;

  setUp(() {
    key = anyString();
    groupId = anyString();
    apiRepo = LoadNextEventRepositorySpy();
    cacheRepo = LoadNextEventRepositorySpy();
    cacheClient = CacheSaveClientSpy();
    sut = LoadNextEventFromApiWithCacheFallbackRepository(
      key: key,
      cacheClient: cacheClient,
      loadNextEventFromApi: apiRepo.loadNextEvent,
      loadNextEventFromCache: cacheRepo.loadNextEvent,
    );
  });

  test('should load event data from api repo', () async {
    await sut.loadNextEvent(groupId: groupId);
    expect(apiRepo.groupId, groupId);
    expect(apiRepo.callsCount, 1);
  });

  test('should save event data from api on cache', () async {
    apiRepo.output = NextEvent(
      groupName: anyString(),
      date: anyDateTime(),
      players: [
        NextEventPlayer(
          id: anyString(),
          name: anyString(),
          isConfirmed: anyBool(),
        ),
        NextEventPlayer(
          id: anyString(),
          name: anyString(),
          isConfirmed: anyBool(),
          photo: anyString(),
          position: anyString(),
          confirmationDate: anyDateTime(),
        ),
      ],
    );
    await sut.loadNextEvent(groupId: groupId);
    expect(cacheClient.key, '$key:$groupId');
    expect(cacheClient.value, {
      'groupName': apiRepo.output.groupName,
      'date': apiRepo.output.date,
      'players': [
        {
          'id': apiRepo.output.players[0].id,
          'name': apiRepo.output.players[0].name,
          'isConfirmed': apiRepo.output.players[0].isConfirmed,
          'photo': null,
          'position': null,
          'confirmationDate': null,
        },
        {
          'id': apiRepo.output.players[1].id,
          'name': apiRepo.output.players[1].name,
          'isConfirmed': apiRepo.output.players[1].isConfirmed,
          'photo': apiRepo.output.players[1].photo,
          'position': apiRepo.output.players[1].position,
          'confirmationDate': apiRepo.output.players[1].confirmationDate,
        },
      ],
    });
  });

  test('should return api data on success', () async {
    final event = await sut.loadNextEvent(groupId: groupId);
    expect(event, apiRepo.output);
  });

  test('should load event data from cache repo when api fails', () async {
    apiRepo.error = Error();
    await sut.loadNextEvent(groupId: groupId);
    expect(cacheRepo.groupId, groupId);
    expect(cacheRepo.callsCount, 1);
  });

  test('should return cache data when api fails', () async {
    apiRepo.error = Error();
    final event = await sut.loadNextEvent(groupId: groupId);
    expect(event, cacheRepo.output);
  });

  test('should throw UnexpectedError when api and cache fails', () async {
    apiRepo.error = Error();
    cacheRepo.error = Error();
    sut.loadNextEvent(groupId: groupId).then((_) {}, onError: (error) {
      expect(error, isA<UnexpectedError>());
    });
  });
}
