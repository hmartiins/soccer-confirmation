import 'dart:convert';

import 'package:advanced_flutter/domain/entities/errors.dart';
import 'package:advanced_flutter/infra/api/clients/http_get_client.dart';
import 'package:advanced_flutter/infra/types/json.dart';
import 'package:dartx/dartx.dart';

import 'package:http/http.dart';

final class HttpAdapter implements HttpGetClient {
  final Client client;

  const HttpAdapter({required this.client});

  @override
  Future<T?> get<T>({
    required String url,
    Json? headers,
    Json? params,
    Map<String, String>? queryString,
  }) async {
    final response = await client.get(
      _buildUri(url: url, params: params, queryString: queryString),
      headers: _buildHeaders(url: url, headers: headers),
    );
    return _handleResponse<T>(response);
  }

  T? _handleResponse<T>(Response response) {
    switch (response.statusCode) {
      case 200:
        if (response.body.isEmpty) return null;
        {
          final data = jsonDecode(response.body);
          return (T == JsonArr)
              ? data.map<Json>((e) => e as Json).toList()
              : data;
        }
      case 204:
        return null;
      case 401:
        throw SessionExpiredError();
      default:
        throw UnexpectedError();
    }
  }

  Map<String, String> _buildHeaders({
    required String url,
    Json? headers,
  }) {
    final defaultHeaders = {
      'content-type': 'application/json',
      'accept': 'application/json',
    };
    return defaultHeaders
      ..addAll({
        for (final key in (headers ?? {}).keys) key: headers![key].toString(),
      });
  }

  Uri _buildUri({
    required String url,
    Json? params,
    Map<String, String>? queryString,
  }) {
    params?.forEach((key, value) =>
        url = url.replaceFirst(':$key', value?.toString() ?? ''));

    url = url.removeSuffix('/');
    if (queryString != null) {
      url += '?';
      queryString.forEach((key, value) => url += '$key=$value&');
      url = url.removeSuffix('&');
    }

    return Uri.parse(url);
  }
}
