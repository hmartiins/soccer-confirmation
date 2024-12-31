import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

class NextEventLoader {
  final LoadNextEventRepository repo;

  NextEventLoader({required this.repo});

  Future<void> call({required String groupId}) async {
    await repo.loadNextEvent(groupId: groupId);
  }
}

abstract class LoadNextEventRepository {
  Future<void> loadNextEvent({required String groupId});
}

class LoadNextEventMockRepository implements LoadNextEventRepository{
  String? groupId;
  var callsCount = 0;

  @override
  Future<void> loadNextEvent({required String groupId}) async {
    this.groupId = groupId;
    callsCount++;
  }
}

void main() {
  test('should load event data from a repository ', () async {
    final groupdId = Random().nextInt(50_000).toString();

    final repo = LoadNextEventMockRepository();
    final sut = NextEventLoader(repo: repo);
    await sut(groupId: groupdId);

    expect(repo.groupId, groupdId);
    expect(repo.callsCount, 1);
  });
}
