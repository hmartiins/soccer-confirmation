@Timeout(Duration(seconds: 1))
library;

import 'package:advanced_flutter/presentation/presenters/next_event_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/subjects.dart';

import '../../helpers/fakes.dart';

final class NextEventRxPresenter {
  final Future<void> Function({required String groupId}) nextEventLoader;
  final nextEventSubject = BehaviorSubject<NextEventViewModel>();
  final isBusySubject = BehaviorSubject<bool>();

  NextEventRxPresenter({required this.nextEventLoader});

  Stream<NextEventViewModel> get nextEventStream => nextEventSubject.stream;
  Stream<bool> get isBusyStream => isBusySubject.stream;

  Future<void> loadNextEvent({
    required String groupId,
    bool isReload = false,
  }) async {
    try {
      if (isReload) isBusySubject.add(true);
      await nextEventLoader(groupId: groupId);
      nextEventSubject.add(const NextEventViewModel());
    } catch (error) {
      nextEventSubject.addError(error);
    } finally {
      if (isReload) isBusySubject.add(false);
    }
  }
}

final class NextEventLoaderSpy {
  int callsCount = 0;
  String? groupId;
  Error? error;

  Future<void> call({required String groupId}) async {
    callsCount++;
    this.groupId = groupId;
    if (error != null) throw error!;
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
}
