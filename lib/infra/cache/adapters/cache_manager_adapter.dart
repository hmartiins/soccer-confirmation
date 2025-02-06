import 'dart:convert';
import 'dart:typed_data';

import 'package:advanced_flutter/infra/cache/clients/cache_get_client.dart';
import 'package:advanced_flutter/infra/cache/clients/cache_save_client.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

final class CacheManagerAdapter implements CacheGetClient, CacheSaveClient {
  final BaseCacheManager client;

  CacheManagerAdapter({required this.client});

  @override
  Future<dynamic> get({required String key}) async {
    try {
      final info = await client.getFileFromCache(key);
      if (info?.validTill.isBefore(DateTime.now()) != false ||
          !await info!.file.exists()) {
        return null;
      }

      final data = await info.file.readAsString();
      return jsonDecode(data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> save({required String key, required dynamic value}) async {
    await client.putFile(
      key,
      utf8.encode(jsonEncode(value)),
      fileExtension: 'json',
    );
  }
}
