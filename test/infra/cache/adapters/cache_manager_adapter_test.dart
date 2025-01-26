import 'dart:convert';
import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../mocks/fakes.dart';
import '../mocks/file_spy.dart';

final class CacheManagerAdapter {
  final BaseCacheManager client;

  CacheManagerAdapter({required this.client});

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
}

final class CacheManagerSpy implements BaseCacheManager {
  int getFileFromCacheCallsCount = 0;
  String? key;
  FileSpy file = FileSpy();
  bool _isFileInfoEmpty = false;
  DateTime _validTill = DateTime.now().add(const Duration(seconds: 2));
  Error? _getFileFromCacheError;

  void simulateEmptyFileInfo() => _isFileInfoEmpty = true;
  void simulateCacheOld() =>
      _validTill = DateTime.now().subtract(const Duration(seconds: 2));
  void simulateGetFileFromCacheError() => _getFileFromCacheError = Error();

  @override
  Future<FileInfo?> getFileFromCache(
    String key, {
    bool ignoreMemCache = false,
  }) async {
    getFileFromCacheCallsCount++;
    this.key = key;
    if (_getFileFromCacheError != null) throw _getFileFromCacheError!;
    return _isFileInfoEmpty
        ? null
        : FileInfo(
            file,
            FileSource.Cache,
            _validTill,
            '',
          );
  }

  @override
  Future<void> dispose() {
    throw UnimplementedError();
  }

  @override
  Future<FileInfo> downloadFile(String url,
      {String? key, Map<String, String>? authHeaders, bool force = false}) {
    throw UnimplementedError();
  }

  @override
  Future<void> emptyCache() {
    throw UnimplementedError();
  }

  @override
  Stream<FileInfo> getFile(String url,
      {String? key, Map<String, String>? headers}) {
    throw UnimplementedError();
  }

  @override
  Future<FileInfo?> getFileFromMemory(String key) {
    throw UnimplementedError();
  }

  @override
  Stream<FileResponse> getFileStream(String url,
      {String? key, Map<String, String>? headers, bool? withProgress}) {
    throw UnimplementedError();
  }

  @override
  Future<File> getSingleFile(String url,
      {String? key, Map<String, String>? headers}) {
    throw UnimplementedError();
  }

  @override
  Future<File> putFile(String url, Uint8List fileBytes,
      {String? key,
      String? eTag,
      Duration maxAge = const Duration(days: 30),
      String fileExtension = 'file'}) {
    throw UnimplementedError();
  }

  @override
  Future<File> putFileStream(String url, Stream<List<int>> source,
      {String? key,
      String? eTag,
      Duration maxAge = const Duration(days: 30),
      String fileExtension = 'file'}) {
    throw UnimplementedError();
  }

  @override
  Future<void> removeFile(String key) {
    throw UnimplementedError();
  }
}

void main() {
  late String key;
  late CacheManagerSpy client;
  late CacheManagerAdapter sut;

  setUp(() {
    key = anyString();
    client = CacheManagerSpy();
    sut = CacheManagerAdapter(client: client);
  });

  test('should call getFileFromcache with correct input', () async {
    await sut.get(key: key);
    expect(client.key, key);
    expect(client.getFileFromCacheCallsCount, 1);
  });

  test('should return null if FileInfo is empty', () async {
    client.simulateEmptyFileInfo();
    final json = await sut.get(key: key);
    expect(json, isNull);
  });

  test('should return null if cache is old', () async {
    client.simulateCacheOld();
    final json = await sut.get(key: key);
    expect(json, isNull);
  });

  test('should call file.exists only once', () async {
    await sut.get(key: key);
    expect(client.file.existsCallsCount, 1);
  });

  test('should return null if file is empty', () async {
    client.file.simulateFileEmpty();
    final json = await sut.get(key: key);
    expect(json, isNull);
  });

  test('should call file.readAsString only once', () async {
    await sut.get(key: key);
    expect(client.file.readAsStringCallsCount, 1);
  });

  test('should return null if file is empty', () async {
    client.file.simulateInvalidResponse();
    final json = await sut.get(key: key);
    expect(json, isNull);
  });

  test('should return json if cache is valid', () async {
    client.file.simulateResponse('''
      {
        "key1": "value1",
        "key2": "value2"
      }
    ''');
    final json = await sut.get(key: key);
    expect(json['key1'], 'value1');
    expect(json['key2'], 'value2');
  });

  test('should return null if file.readAsString fails', () async {
    client.file.simulateReadAsStringError();
    final json = await sut.get(key: key);
    expect(json, isNull);
  });

  test('should return null if file.exists fails ', () async {
    client.file.simulateExistsError();
    final json = await sut.get(key: key);
    expect(json, isNull);
  });

  test('should return null if getFileFromCache fails ', () async {
    client.simulateGetFileFromCacheError();
    final json = await sut.get(key: key);
    expect(json, isNull);
  });
}
