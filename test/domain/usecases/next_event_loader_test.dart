import 'dart:math';

import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:flutter_test/flutter_test.dart';

class NextEventLoader {
  final LoadNextEventRepository repo;

  NextEventLoader({required this.repo});

  Future<NextEvent> call({required String groupId}) async {
    return repo.loadNextEvent(groupId: groupId);
  }
}

abstract class LoadNextEventRepository {
  Future<NextEvent> loadNextEvent({required String groupId});
}

class LoadNextEventSpyRepository implements LoadNextEventRepository{
  String? groupId;
  var callsCount = 0;
  NextEvent? output;
  Error? error;

  @override
  Future<NextEvent> loadNextEvent({required String groupId}) async {
    this.groupId = groupId;
    callsCount++;

    if(error != null) {
      throw error!;
    }

    return output!;
  }
}

void main() {
  late String groupdId;
  late LoadNextEventSpyRepository repo;
  late NextEventLoader sut;

  setUp(() {
    groupdId = Random().nextInt(50_000).toString();
    repo = LoadNextEventSpyRepository();
    repo.output = NextEvent(
      groupName: 'any_name',
      date: DateTime.now(),
      players: [
        NextEventPlayer(
          id: Random().nextInt(50_000).toString(),
          name: 'Henrique Martins',
          confirmationDate: DateTime.now(),
          isConfirmed: true,
          photo: 'any_photo',
        ),
        NextEventPlayer(
          id: Random().nextInt(50_000).toString(),
          name: 'Isaac Melo Alves Martins',
          confirmationDate: DateTime.now(),
          isConfirmed: false,
          position: 'any_position',
        ),
      ],
    );

    sut = NextEventLoader(repo: repo);
  });

  test('should load event data from a repository ', () async {
    await sut(groupId: groupdId);

    expect(repo.groupId, groupdId);
    expect(repo.callsCount, 1);
  });

  test('should return event data on success ', () async {
    final event = await sut(groupId: groupdId);

    expect(event.groupName, repo.output?.groupName);
    expect(event.date, repo.output?.date);

    expect(event.players.length, 2);

    expect(event.players[0].id, repo.output?.players[0].id);
    expect(event.players[0].name, repo.output?.players[0].name);
    expect(event.players[0].confirmationDate, repo.output?.players[0].confirmationDate);
    expect(event.players[0].isConfirmed, repo.output?.players[0].isConfirmed);
    expect(event.players[0].photo, repo.output?.players[0].photo);

    expect(event.players[1].id, repo.output?.players[1].id);
    expect(event.players[1].name, repo.output?.players[1].name);
    expect(event.players[1].confirmationDate, repo.output?.players[1].confirmationDate);
    expect(event.players[1].isConfirmed, repo.output?.players[1].isConfirmed);
    expect(event.players[1].position, repo.output?.players[1].position);
  });

  test('should rethrow on error ', () async {
    final error = Error();
    repo.error = error;
    final future = sut(groupId: groupdId);

    expect(future, throwsA(error));
  });
}
