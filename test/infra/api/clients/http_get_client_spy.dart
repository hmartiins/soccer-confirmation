import 'package:advanced_flutter/infra/api/clients/http_get_client.dart';
import 'package:advanced_flutter/infra/types/json.dart';

final class HttpGetClientSpy implements HttpGetClient {
  String? url;
  int callsCount = 0;
  Map<String, String?>? params;
  Map<String, String>? queryString;
  Json? headers;
  dynamic response;
  Error? error;

  @override
  Future<T?> get<T>({
    required String url,
    Json? headers,
    Map<String, String?>? params,
    Map<String, String>? queryString,
  }) async {
    this.url = url;
    this.params = params;
    this.queryString = queryString;
    this.headers = headers;
    callsCount++;

    if (error != null) {
      throw error!;
    }

    return response;
  }
}
