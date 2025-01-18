import 'package:advanced_flutter/domain/entities/errors.dart';
import 'package:advanced_flutter/infra/api/adapters/http_adapter.dart';

import 'package:flutter_test/flutter_test.dart';

import '../../../mocks/fakes.dart';
import '../mocks/client_spy.dart';

void main() {
  late ClientSpy client;
  late HttpAdapter sut;
  late String url;

  setUp(() {
    client = ClientSpy();
    client.responseJson = '''
        {
          "key1": "value1",
          "key2": "value2"
        }
      ''';
    sut = HttpAdapter(client: client);
    url = anyString();
  });

  group('get', () {
    test('should request with correct method', () async {
      await sut.get(url: url);

      expect(client.method, 'get');
      expect(client.callsCount, 1);
    });

    test('should request with correct url', () async {
      await sut.get(url: url);
      expect(client.url, url);
    });

    test('should request with default headers', () async {
      await sut.get(url: url);
      expect(client.headers?['content-type'], 'application/json');
      expect(client.headers?['accept'], 'application/json');
    });

    test('should append headers', () async {
      await sut.get(url: url, headers: {
        'h1': 'value1',
        'h2': 'value2',
        'h3': 123,
      });
      expect(client.headers?['h1'], 'value1');
      expect(client.headers?['h2'], 'value2');
      expect(client.headers?['h3'], '123');
    });

    test('should request with correct params', () async {
      url = 'http://anyurl.com/api/:p1/:p2/:p3';
      await sut
          .get(url: url, params: {'p1': 'value1', 'p2': 'value2', 'p3': 123});

      expect(client.url, 'http://anyurl.com/api/value1/value2/123');
    });

    test('should request with optional param', () async {
      url = 'http://anyurl.com/api/:p1/:p2';
      await sut.get(url: url, params: {'p1': 'value1', 'p2': null});

      expect(client.url, 'http://anyurl.com/api/value1');
    });

    test('should request with invalid params', () async {
      url = 'http://anyurl.com/api/:p1/:p2';
      await sut.get(url: url, params: {'p3': 'value3'});

      expect(client.url, url);
    });

    test('should request with correct queryStrings', () async {
      await sut.get(
          url: url, queryString: {'q1': 'value1', 'q2': 'value2', 'q3': 123});

      expect(client.url, '$url?q1=value1&q2=value2&q3=123');
    });

    test('should request with correct queryStrings and params', () async {
      url = 'http://anyurl.com/api/:p1/:p2';

      await sut.get(
        url: url,
        params: {'p1': 'v1', 'p2': 'v2'},
        queryString: {'q1': 'v3', 'q2': 'v4'},
      );

      expect(client.url, 'http://anyurl.com/api/v1/v2?q1=v3&q2=v4');
    });

    test('should throw UnexpectedError on 400', () async {
      client.simulateBadRequestError();
      final future = sut.get(url: url);
      expect(future, throwsA(const TypeMatcher<UnexpectedError>()));
    });

    test('should throw SessionExpiredError on 401', () async {
      client.simulateUnauthorizedError();
      final future = sut.get(url: url);
      expect(future, throwsA(const TypeMatcher<SessionExpiredError>()));
    });

    test('should throw UnexpectedError on 403', () async {
      client.simulateForbiddenError();
      final future = sut.get(url: url);
      expect(future, throwsA(const TypeMatcher<UnexpectedError>()));
    });

    test('should throw UnexpectedError on 404', () async {
      client.simulateNotFoundError();
      final future = sut.get(url: url);
      expect(future, throwsA(const TypeMatcher<UnexpectedError>()));
    });

    test('should throw UnexpectedError on 500', () async {
      client.simulateServerError();
      final future = sut.get(url: url);
      expect(future, throwsA(const TypeMatcher<UnexpectedError>()));
    });

    test('should return a Map', () async {
      final data = await sut.get(url: url);
      expect(data?['key1'], 'value1');
      expect(data?['key2'], 'value2');
    });

    test('should return a List', () async {
      client.responseJson = '''
        [
          {
            "key1": "value1"
          },
          {
            "key2": "value2"
          }
        ]
      ''';
      final data = await sut.get(url: url);
      expect(data?[0]['key1'], 'value1');
      expect(data?[1]['key2'], 'value2');
    });

    test('should return a Map with List', () async {
      client.responseJson = '''
        {
          "key1": "value1",
          "key2": [
            {
              "key3": "value3"
            },
            {
              "key4": "value4"
            }
          ]
        }
      ''';
      final data = await sut.get(url: url);
      expect(data?['key1'], 'value1');
      expect(data?['key2'][0]['key3'], 'value3');
      expect(data?['key2'][1]['key4'], 'value4');
    });

    test('should return null on 200 with empty response', () async {
      client.responseJson = '';
      final data = await sut.get(url: url);
      expect(data, isNull);
    });

    test('should return null on 204', () async {
      client.simulateNoContent();
      final data = await sut.get(url: url);
      expect(data, isNull);
    });
  });
}
