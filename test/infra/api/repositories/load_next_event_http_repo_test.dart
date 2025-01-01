import 'package:advanced_flutter/domain/entities/domain_error.dart';
import 'package:advanced_flutter/infra/api/repositories/load_next_event_http_repo.dart';

import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../clients/http_client_spy.dart';

void main() {
  const url = 'https://domain.com/api/groups/:groupId/next_event';

  late String groupId;
  late HttpClientSpy httpClient;
  late LoadNextEventHttpRepository sut;

  setUp(() {
    groupId = anyString();
    httpClient = HttpClientSpy();
    httpClient.responseJson = '''
      {
        "groupName": "any_name",
        "date": "2025-08-30T10:30",
        "players": [
          {
            "id": "id_1",
            "name": "name_1",
            "isConfirmed": true
          },
          {
            "id": "id_2",
            "name": "name_2",
            "photo": "photo_2",
            "position": "position_2",
            "confirmationDate": "2025-08-29T11:30",
            "isConfirmed": false
          }
        ]
      }
    ''';
    sut = LoadNextEventHttpRepository(httpClient: httpClient, url: url);
  });

  test('should request with correct method', () async {
    await sut.loadNextEvent(groupId: groupId);
    expect(httpClient.method, 'get');
    expect(httpClient.callsCount, 1);
  });

  test('should request with correct url', () async {
    await sut.loadNextEvent(groupId: groupId);
    expect(httpClient.url, 'https://domain.com/api/groups/$groupId/next_event');
  });

  test('should request with correct headers', () async {
    await sut.loadNextEvent(groupId: groupId);
    expect(httpClient.headers?['content-type'], 'application/json');
    expect(httpClient.headers?['accept'], 'application/json');
  });

  test('should return NextEvent on 200', () async {
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

  test('should throw UnexpectedError on 400', () async {
    httpClient.simulateBadRequestError();
    final future = sut.loadNextEvent(groupId: groupId);
    expect(future, throwsA(DomainError.unexpected));
  });

  test('should throw SessionExpiredError on 401', () async {
    httpClient.simulateUnauthorizedError();
    final future = sut.loadNextEvent(groupId: groupId);
    expect(future, throwsA(DomainError.sessionExpired));
  });

  test('should throw UnexpectedError on 403', () async {
    httpClient.simulateForbiddenError();
    final future = sut.loadNextEvent(groupId: groupId);
    expect(future, throwsA(DomainError.unexpected));
  });

  test('should throw UnexpectedError on 404', () async {
    httpClient.simulateNotFoundError();
    final future = sut.loadNextEvent(groupId: groupId);
    expect(future, throwsA(DomainError.unexpected));
  });

  test('should throw UnexpectedError on 500', () async {
    httpClient.simulateServerError();
    final future = sut.loadNextEvent(groupId: groupId);
    expect(future, throwsA(DomainError.unexpected));
  });
}
