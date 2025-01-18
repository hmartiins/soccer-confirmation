@Timeout(Duration(seconds: 1))
library;

import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:advanced_flutter/presentation/presenters/next_event_presenter.dart';
import 'package:advanced_flutter/presentation/presenters/rx/next_event_rx_presenter.dart';

import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

final class NextEventLoaderSpy {
  int callsCount = 0;
  String? groupId;
  Error? error;
  NextEvent output = NextEvent(
    groupName: anyString(),
    date: anyDateTime(),
    players: [],
  );

  void simulatePlayers(List<NextEventPlayer> players) {
    output = NextEvent(
      groupName: anyString(),
      date: anyDateTime(),
      players: players,
    );
  }

  Future<NextEvent> call({required String groupId}) async {
    callsCount++;
    this.groupId = groupId;
    if (error != null) throw error!;
    return output;
  }
}

void main() {
  late NextEventRxPresenter sut;
  late NextEventLoaderSpy nextEventLoader;
  late String groupId;

  setUp(() {
    nextEventLoader = NextEventLoaderSpy();
    groupId = anyString();
    sut = NextEventRxPresenter(nextEventLoader: nextEventLoader.call);
  });

  test('should get event data', () async {
    await sut.loadNextEvent(groupId: groupId);
    expect(nextEventLoader.callsCount, 1);
    expect(nextEventLoader.groupId, groupId);
  });

  test('should emit correct events on reload with error', () async {
    nextEventLoader.error = Error();
    expectLater(sut.nextEventStream, emitsError(nextEventLoader.error));
    expectLater(sut.isBusyStream, emitsInOrder([true, false]));
    await sut.loadNextEvent(groupId: groupId, isReload: true);
  });

  test('should emit correct events on load with error', () async {
    nextEventLoader.error = Error();
    expectLater(sut.nextEventStream, emitsError(nextEventLoader.error));
    sut.isBusyStream.listen(neverCalled);
    await sut.loadNextEvent(groupId: groupId);
  });

  test('should emit correct events on reload with success', () async {
    expectLater(sut.isBusyStream, emitsInOrder([true, false]));
    expectLater(
      sut.nextEventStream,
      emits(const TypeMatcher<NextEventViewModel>()),
    );
    await sut.loadNextEvent(groupId: groupId, isReload: true);
  });

  test('should emit correct events on load with success', () async {
    sut.isBusyStream.listen(neverCalled);
    expectLater(
      sut.nextEventStream,
      emits(const TypeMatcher<NextEventViewModel>()),
    );
    await sut.loadNextEvent(groupId: groupId);
  });

  test('should build doubt list sorted by name', () async {
    nextEventLoader.simulatePlayers([
      NextEventPlayer(id: anyString(), name: 'C', isConfirmed: anyBool()),
      NextEventPlayer(id: anyString(), name: 'A', isConfirmed: anyBool()),
      NextEventPlayer(
        id: anyString(),
        name: 'B',
        isConfirmed: anyBool(),
        confirmationDate: anyDateTime(),
      ),
      NextEventPlayer(id: anyString(), name: 'D', isConfirmed: anyBool()),
    ]);
    sut.nextEventStream.listen((event) {
      expect(event.doubt.length, 3);
      expect(event.doubt[0].name, 'A');
      expect(event.doubt[1].name, 'C');
      expect(event.doubt[2].name, 'D');
    });
    await sut.loadNextEvent(groupId: groupId);
  });

  test('should map doubt player', () async {
    final player = NextEventPlayer(
      id: anyString(),
      name: anyString(),
      isConfirmed: anyBool(),
      photo: anyString(),
      position: anyString(),
    );
    nextEventLoader.simulatePlayers([player]);
    sut.nextEventStream.listen((event) {
      expect(event.doubt[0].name, player.name);
      expect(event.doubt[0].initials, player.initials);
      expect(event.doubt[0].photo, player.photo);
      expect(event.doubt[0].position, player.position);
      expect(event.doubt[0].isConfirmed, null);
    });
    await sut.loadNextEvent(groupId: groupId);
  });

  test('should build out list sorted by confirmation', () async {
    nextEventLoader.simulatePlayers([
      NextEventPlayer(
        id: anyString(),
        name: 'C',
        isConfirmed: false,
        confirmationDate: DateTime(2024, 1, 1, 10),
      ),
      NextEventPlayer(
        id: anyString(),
        name: 'A',
        isConfirmed: anyBool(),
      ),
      NextEventPlayer(
        id: anyString(),
        name: 'B',
        isConfirmed: true,
        confirmationDate: DateTime(2024, 1, 1, 11),
      ),
      NextEventPlayer(
        id: anyString(),
        name: 'E',
        isConfirmed: false,
        confirmationDate: DateTime(2024, 1, 1, 09),
      ),
      NextEventPlayer(
        id: anyString(),
        name: 'D',
        isConfirmed: false,
        confirmationDate: DateTime(2024, 1, 1, 12),
      ),
    ]);
    sut.nextEventStream.listen((event) {
      expect(event.out.length, 3);
      expect(event.out[0].name, 'E');
      expect(event.out[1].name, 'C');
      expect(event.out[2].name, 'D');
    });
    await sut.loadNextEvent(groupId: groupId);
  });

  test('should map out player', () async {
    final player = NextEventPlayer(
      id: anyString(),
      name: anyString(),
      isConfirmed: false,
      photo: anyString(),
      position: anyString(),
      confirmationDate: anyDateTime(),
    );
    nextEventLoader.simulatePlayers([player]);
    sut.nextEventStream.listen((event) {
      expect(event.out[0].name, player.name);
      expect(event.out[0].initials, player.initials);
      expect(event.out[0].photo, player.photo);
      expect(event.out[0].position, player.position);
      expect(event.out[0].isConfirmed, player.isConfirmed);
    });
    await sut.loadNextEvent(groupId: groupId);
  });

  test('should build goalkeepers list sorted by confirmation date', () async {
    nextEventLoader.simulatePlayers([
      NextEventPlayer(
        id: anyString(),
        name: 'C',
        isConfirmed: true,
        confirmationDate: DateTime(2024, 1, 1, 10),
        position: 'goalkeeper',
      ),
      NextEventPlayer(
        id: anyString(),
        name: 'A',
        isConfirmed: anyBool(),
      ),
      NextEventPlayer(
        id: anyString(),
        name: 'B',
        isConfirmed: true,
        confirmationDate: DateTime(2024, 1, 1, 11),
        position: 'defender',
      ),
      NextEventPlayer(
        id: anyString(),
        name: 'E',
        isConfirmed: false,
        confirmationDate: DateTime(2024, 1, 1, 09),
      ),
      NextEventPlayer(
        id: anyString(),
        name: 'D',
        isConfirmed: true,
        confirmationDate: DateTime(2024, 1, 1, 12),
      ),
      NextEventPlayer(
        id: anyString(),
        name: 'F',
        isConfirmed: true,
        confirmationDate: DateTime(2024, 1, 1, 8),
        position: 'goalkeeper',
      ),
    ]);
    sut.nextEventStream.listen((event) {
      expect(event.goalkeepers.length, 2);
      expect(event.goalkeepers[0].name, 'F');
      expect(event.goalkeepers[1].name, 'C');
    });
    await sut.loadNextEvent(groupId: groupId);
  });

  test('should map goalkeeper', () async {
    final player = NextEventPlayer(
      id: anyString(),
      name: anyString(),
      isConfirmed: true,
      photo: anyString(),
      confirmationDate: anyDateTime(),
      position: 'goalkeeper',
    );
    nextEventLoader.simulatePlayers([player]);
    sut.nextEventStream.listen((event) {
      expect(event.goalkeepers[0].name, player.name);
      expect(event.goalkeepers[0].initials, player.initials);
      expect(event.goalkeepers[0].photo, player.photo);
      expect(event.goalkeepers[0].position, player.position);
      expect(event.goalkeepers[0].isConfirmed, player.isConfirmed);
    });
    await sut.loadNextEvent(groupId: groupId);
  });

  test('should build players list sorted by confirmation date', () async {
    nextEventLoader.simulatePlayers([
      NextEventPlayer(
        id: anyString(),
        name: 'C',
        isConfirmed: true,
        confirmationDate: DateTime(2024, 1, 1, 10),
        position: 'goalkeeper',
      ),
      NextEventPlayer(
        id: anyString(),
        name: 'A',
        isConfirmed: anyBool(),
      ),
      NextEventPlayer(
        id: anyString(),
        name: 'B',
        isConfirmed: true,
        confirmationDate: DateTime(2024, 1, 1, 11),
        position: 'defender',
      ),
      NextEventPlayer(
        id: anyString(),
        name: 'E',
        isConfirmed: false,
        confirmationDate: DateTime(2024, 1, 1, 09),
      ),
      NextEventPlayer(
        id: anyString(),
        name: 'D',
        isConfirmed: true,
        confirmationDate: DateTime(2024, 1, 1, 12),
      ),
      NextEventPlayer(
        id: anyString(),
        name: 'F',
        isConfirmed: true,
        confirmationDate: DateTime(2024, 1, 1, 8),
        position: 'goalkeeper',
      ),
    ]);
    sut.nextEventStream.listen((event) {
      expect(event.players.length, 2);
      expect(event.players[0].name, 'B');
      expect(event.players[1].name, 'D');
    });
    await sut.loadNextEvent(groupId: groupId);
  });

  test('should map player', () async {
    final player = NextEventPlayer(
      id: anyString(),
      name: anyString(),
      isConfirmed: true,
      photo: anyString(),
      confirmationDate: anyDateTime(),
    );
    nextEventLoader.simulatePlayers([player]);
    sut.nextEventStream.listen((event) {
      expect(event.players[0].name, player.name);
      expect(event.players[0].initials, player.initials);
      expect(event.players[0].photo, player.photo);
      expect(event.players[0].position, player.position);
      expect(event.players[0].isConfirmed, player.isConfirmed);
    });
    await sut.loadNextEvent(groupId: groupId);
  });
}
