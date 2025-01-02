import 'dart:convert';

import 'package:advanced_flutter/domain/entities/domain_error.dart';
import 'package:advanced_flutter/infra/types/json.dart';
import 'package:dartx/dartx.dart';

import 'package:http/http.dart';

class HttpAdapter {
  final Client client;

  HttpAdapter({required this.client});

  Future<T?> get<T>({
    required String url,
    Map<String, String>? headers,
    Map<String, String?>? params,
    Map<String, String>? queryString,
  }) async {
    final allHeaders = (headers ?? {})
      ..addAll({
        'content-type': 'application/json',
        'accept': 'application/json',
      });
    final uri = _buildUri(url: url, params: params, queryString: queryString);

    final response = await client.get(uri, headers: allHeaders);
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
        throw DomainError.sessionExpired;
      default:
        throw DomainError.unexpected;
    }
  }

  Uri _buildUri({
    required String url,
    Map<String, String?>? params,
    Map<String, String>? queryString,
  }) {
    params
        ?.forEach((key, value) => url = url.replaceFirst(':$key', value ?? ''));

    url = url.removeSuffix('/');
    if (queryString != null) {
      url += '?';
      queryString.forEach((key, value) => url += '$key=$value&');
      url = url.removeSuffix('&');
    }

    return Uri.parse(url);
  }
}