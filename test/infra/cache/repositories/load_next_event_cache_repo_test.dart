import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../mocks/fakes.dart';

abstract interface class CacheGetClient {
  Future<dynamic> get({
    required String key,
  });
}

final class CacheGetClientSpy implements CacheGetClient {
  String? key;
  int callsCount = 0;
  dynamic response;

  @override
  Future<dynamic> get({
    required String key,
  }) async {
    this.key = key;
    callsCount++;
    return response;
  }
}

final class LoadNextEventCacheRepository {
  final CacheGetClient cacheClient;
  final String key;

  const LoadNextEventCacheRepository(
      {required this.cacheClient, required this.key});

  Future<NextEvent> loadNextEvent({required String groupId}) async {
    final json = await cacheClient.get(key: '$key:$groupId');
    return NextEventMapper().toObject(json);
  }
}

abstract base class Mapper<Entity> {
  List<Entity> toList(dynamic arr) => arr.map<Entity>(toObject).toList();

  Entity toObject(dynamic json);
}

final class NextEventPlayerMapper extends Mapper<NextEventPlayer> {
  @override
  NextEventPlayer toObject(dynamic json) => NextEventPlayer(
        id: json['id'],
        name: json['name'],
        photo: json['photo'],
        position: json['position'],
        isConfirmed: json['isConfirmed'],
        confirmationDate: json['confirmationDate'],
      );
}

final class NextEventMapper extends Mapper<NextEvent> {
  @override
  NextEvent toObject(dynamic json) => NextEvent(
        groupName: json['groupName'],
        date: json['date'],
        players: NextEventPlayerMapper().toList(json['players']),
      );
}

void main() {
  late String key;
  late String groupId;
  late CacheGetClientSpy cacheClient;
  late LoadNextEventCacheRepository sut;

  setUp(() {
    groupId = anyString();
    key = anyString();
    cacheClient = CacheGetClientSpy();
    cacheClient.response = {
      "groupName": "any_name",
      "date": DateTime(2025, 08, 30, 10, 30),
      "players": [
        {"id": "id_1", "name": "name_1", "isConfirmed": true},
        {
          "id": "id_2",
          "name": "name_2",
          "photo": "photo_2",
          "position": "position_2",
          "confirmationDate": DateTime(2025, 08, 29, 11, 30),
          "isConfirmed": false
        }
      ]
    };

    sut = LoadNextEventCacheRepository(cacheClient: cacheClient, key: key);
  });
  test('should call CacheClient with correct input', () async {
    await sut.loadNextEvent(groupId: groupId);
    expect(cacheClient.key, '$key:$groupId');
    expect(cacheClient.callsCount, 1);
  });

  test('should return NextEvent on success', () async {
    final event = await sut.loadNextEvent(groupId: groupId);
    expect(event.groupName, 'any_name');
    expect(event.date, DateTime(2025, 08, 30, 10, 30));

    expect(event.players[0].id, 'id_1');
    expect(event.players[0].name, 'name_1');
    expect(event.players[0].isConfirmed, true);

    expect(event.players[1].id, 'id_2');
    expect(event.players[1].name, 'name_2');
    expect(event.players[1].position, 'position_2');
    expect(event.players[1].photo, 'photo_2');
    expect(event.players[1].confirmationDate, DateTime(2025, 08, 29, 11, 30));
    expect(event.players[1].isConfirmed, false);
  });
}
