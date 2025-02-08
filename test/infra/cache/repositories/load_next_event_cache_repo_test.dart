import 'package:advanced_flutter/domain/entities/errors.dart';
import 'package:advanced_flutter/infra/cache/repositories/load_next_event_cache_repo.dart';

import 'package:flutter_test/flutter_test.dart';

import '../../../mocks/fakes.dart';
import '../mocks/cache_get_client_spy.dart';

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
      "date": '2025-08-30T10:30:00.000',
      "players": [
        {"id": "id_1", "name": "name_1", "isConfirmed": true},
        {
          "id": "id_2",
          "name": "name_2",
          "photo": "photo_2",
          "position": "position_2",
          "confirmationDate": '2025-08-29T11:30:00.000',
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

  test('should rethrow on error', () async {
    final error = Error();
    cacheClient.error = error;
    final future = sut.loadNextEvent(groupId: groupId);
    expect(future, throwsA(error));
  });

  test('should throw UnexpectedError on null response', () async {
    cacheClient.response = null;
    final future = sut.loadNextEvent(groupId: groupId);
    expect(future, throwsA(isA<UnexpectedError>()));
  });
}
