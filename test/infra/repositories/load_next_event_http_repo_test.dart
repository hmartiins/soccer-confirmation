import 'dart:convert';
import 'dart:typed_data';

import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:advanced_flutter/domain/repositories/load_next_event_repository.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';

import '../../helpers/fakes.dart';

enum DomainError { unexpected, sessionExpired }

class LoadNextEventHttpRepository implements LoadNextEventRepository {
  final Client httpClient;
  final String url;

  LoadNextEventHttpRepository({
    required this.httpClient,
    required this.url,
  });

  @override
  Future<NextEvent> loadNextEvent({required String groupId}) async {
    final uri = Uri.parse(url.replaceFirst(':groupId', groupId));
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
    };

    final response = await httpClient.get(uri, headers: headers);

    switch (response.statusCode) {
      case 200:
        break;
      case 401:
        throw DomainError.sessionExpired;
      default:
        throw DomainError.unexpected;
    }

    final event = jsonDecode(response.body);

    return NextEvent(
      groupName: event['groupName'],
      date: DateTime.parse(event['date']),
      players: event['players']
          .map<NextEventPlayer>((player) => NextEventPlayer(
                id: player['id'],
                name: player['name'],
                photo: player['photo'],
                position: player['position'],
                isConfirmed: player['isConfirmed'],
                confirmationDate: DateTime.tryParse(
                  player['confirmationDate'] ?? '',
                ),
              ))
          .toList(),
    );
  }
}

class HttpClientSpy implements Client {
  String? method;
  String? url;
  int callsCount = 0;
  Map<String, String>? headers;
  String responseJson = '';
  int statusCode = 200;

  void simulateBadRequestError() => statusCode = 400;
  void simulateUnauthorizedError() => statusCode = 401;
  void simulateForbiddenError() => statusCode = 403;
  void simulateNotFoundError() => statusCode = 404;
  void simulateServerError() => statusCode = 500;

  @override
  void close() {}

  @override
  Future<Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    throw UnimplementedError();
  }

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) async {
    method = 'get';
    callsCount++;
    this.url = url.toString();
    this.headers = headers;

    return Response(responseJson, statusCode);
  }

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) {
    throw UnimplementedError();
  }

  @override
  Future<Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    throw UnimplementedError();
  }

  @override
  Future<Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    throw UnimplementedError();
  }

  @override
  Future<Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    throw UnimplementedError();
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    throw UnimplementedError();
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    throw UnimplementedError();
  }
}

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
