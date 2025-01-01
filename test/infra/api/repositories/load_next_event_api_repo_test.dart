import 'package:advanced_flutter/infra/api/clients/http_get_client.dart';
import 'package:advanced_flutter/infra/api/repositories/load_next_event_api_repo.dart';
import 'package:advanced_flutter/infra/types/json.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

class HttpGetClientSpy implements HttpGetClient {
  String? url;
  int callsCount = 0;
  Json? params;
  dynamic response;
  Error? error;

  @override
  Future<T> get<T>({required String url, Json? params}) async {
    this.url = url;
    this.params = params;
    callsCount++;

    if (error != null) {
      throw error!;
    }

    return response;
  }
}

void main() {
  late String url;
  late String groupId;
  late HttpGetClientSpy httpClient;
  late LoadNextEventApiRepository sut;

  setUp(() {
    groupId = anyString();
    url = anyString();
    httpClient = HttpGetClientSpy();
    httpClient.response = {
      "groupName": "any_name",
      "date": "2025-08-30T10:30",
      "players": [
        {"id": "id_1", "name": "name_1", "isConfirmed": true},
        {
          "id": "id_2",
          "name": "name_2",
          "photo": "photo_2",
          "position": "position_2",
          "confirmationDate": "2025-08-29T11:30",
          "isConfirmed": false
        }
      ]
    };
    sut = LoadNextEventApiRepository(httpClient: httpClient, url: url);
  });

  test('should call HttpClient with correct input', () async {
    await sut.loadNextEvent(groupId: groupId);
    expect(httpClient.url, url);
    expect(httpClient.callsCount, 1);
    expect(httpClient.params, {'groupId': groupId});
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
    httpClient.error = error;
    final future = sut.loadNextEvent(groupId: groupId);
    expect(future, throwsA(error));
  });
}
