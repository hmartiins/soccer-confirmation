import 'package:advanced_flutter/domain/entities/errors.dart';
import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:advanced_flutter/infra/repositories/load_next_event_from_api_with_cache_fallback_repo.dart';

import 'package:flutter_test/flutter_test.dart';

import '../../mocks/fakes.dart';
import '../cache/mocks/cache_save_client_mock.dart';
import '../mocks/load_next_event_repo_spy.dart';

void main() {
  late String key;
  late String groupId;
  late LoadNextEventRepositorySpy apiRepo;
  late LoadNextEventRepositorySpy cacheRepo;
  late CacheSaveClientMock cacheClient;
  late LoadNextEventFromApiWithCacheFallbackRepository sut;

  setUp(() {
    key = anyString();
    groupId = anyString();
    apiRepo = LoadNextEventRepositorySpy();
    cacheRepo = LoadNextEventRepositorySpy();
    cacheClient = CacheSaveClientMock();
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
      date: DateTime(2025, 1, 1, 9, 30),
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
          confirmationDate: DateTime(2025, 3, 1, 9, 30),
        ),
      ],
    );
    await sut.loadNextEvent(groupId: groupId);
    expect(cacheClient.key, '$key:$groupId');
    expect(cacheClient.value, {
      'groupName': apiRepo.output.groupName,
      'date': '2025-01-01T09:30:00.000',
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
          'confirmationDate': '2025-03-01T09:30:00.000',
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

  test('should rethrow api error when its SessionExpiredError', () async {
    apiRepo.error = SessionExpiredError();
    final future = sut.loadNextEvent(groupId: groupId);
    expect(future, throwsA(apiRepo.error));
  });

  test('should rethrow cache error when api and cache fails', () async {
    apiRepo.error = Error();
    cacheRepo.error = Error();
    final future = sut.loadNextEvent(groupId: groupId);
    expect(future, throwsA(cacheRepo.error));
  });
}
