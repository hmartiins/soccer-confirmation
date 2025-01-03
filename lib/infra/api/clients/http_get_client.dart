import 'package:advanced_flutter/infra/types/json.dart';

abstract interface class HttpGetClient {
  Future<T?> get<T>({
    required String url,
    Json? headers,
    Map<String, String?>? params,
    Map<String, String>? queryString,
  });
}
