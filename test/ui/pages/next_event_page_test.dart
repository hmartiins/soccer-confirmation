import 'package:advanced_flutter/presentation/presenters/next_event_presenter.dart';
import 'package:advanced_flutter/ui/pages/next_event_page.dart';
import 'package:advanced_flutter/ui/widgets/player_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/subjects.dart';

import '../../helpers/fakes.dart';

final class NextEventPresenterSpy implements NextEventPresenter {
  int loadCallsCount = 0;
  String? groupId;
  var nextEventSubject = BehaviorSubject<NextEventViewModel>();

  @override
  Stream<NextEventViewModel> get nextEventStream => nextEventSubject.stream;

  void emitNextEvent([NextEventViewModel? viewModel]) {
    nextEventSubject.add(viewModel ?? const NextEventViewModel());
  }

  void emitNextEventWith({
    List<NextEventPlayerViewModel> goalkeepers = const [],
    List<NextEventPlayerViewModel> players = const [],
    List<NextEventPlayerViewModel> out = const [],
    List<NextEventPlayerViewModel> doubt = const [],
  }) {
    nextEventSubject.add(NextEventViewModel(
      goalkeepers: goalkeepers,
      players: players,
      out: out,
      doubt: doubt,
    ));
  }

  void emitError() {
    nextEventSubject.addError(Error());
  }

  @override
  void loadNextEvent({required String groupId}) {
    loadCallsCount++;
    this.groupId = groupId;
  }
}

void main() {
  late NextEventPresenterSpy presenter;
  late String groupId;
  late Widget sut;

  setUp(() {
    presenter = NextEventPresenterSpy();
    groupId = anyString();
    sut = MaterialApp(
      home: NextEventPage(presenter: presenter, groupId: groupId),
    );
  });

  testWidgets('should load event data on page init', (tester) async {
    await tester.pumpWidget(sut);
    expect(presenter.loadCallsCount, 1);
    expect(presenter.groupId, groupId);
  });

  testWidgets('should present spinner while data is loading', (tester) async {
    await tester.pumpWidget(sut);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('should hide spinner on load success', (tester) async {
    await tester.pumpWidget(sut);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    presenter.emitNextEvent();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('should hide spinner on load error', (tester) async {
    await tester.pumpWidget(sut);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    presenter.emitError();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('should present goalkeepers section', (tester) async {
    await tester.pumpWidget(sut);
    presenter.emitNextEventWith(
      goalkeepers: const [
        NextEventPlayerViewModel(name: 'Henrique'),
        NextEventPlayerViewModel(name: 'Rafael'),
        NextEventPlayerViewModel(name: 'Isaac'),
      ],
    );
    await tester.pump();
    expect(find.text('DENTRO - GOLEIROS'), findsOne);
    expect(find.text('3'), findsOne);
    expect(find.text('Henrique'), findsOne);
    expect(find.text('Rafael'), findsOne);
    expect(find.text('Isaac'), findsOne);
    expect(find.byType(PlayerPosition), findsExactly(3));
  });

  testWidgets('should present players section', (tester) async {
    await tester.pumpWidget(sut);
    presenter.emitNextEventWith(
      players: const [
        NextEventPlayerViewModel(name: 'Henrique'),
        NextEventPlayerViewModel(name: 'Rafael'),
        NextEventPlayerViewModel(name: 'Isaac'),
      ],
    );
    await tester.pump();
    expect(find.text('DENTRO - JOGADORES'), findsOne);
    expect(find.text('3'), findsOne);
    expect(find.text('Henrique'), findsOne);
    expect(find.text('Rafael'), findsOne);
    expect(find.text('Isaac'), findsOne);
    expect(find.byType(PlayerPosition), findsExactly(3));
  });

  testWidgets('should present out section', (tester) async {
    await tester.pumpWidget(sut);
    presenter.emitNextEventWith(
      out: const [
        NextEventPlayerViewModel(name: 'Henrique'),
        NextEventPlayerViewModel(name: 'Rafael'),
        NextEventPlayerViewModel(name: 'Isaac'),
      ],
    );
    await tester.pump();
    expect(find.text('FORA'), findsOne);
    expect(find.text('3'), findsOne);
    expect(find.text('Henrique'), findsOne);
    expect(find.text('Rafael'), findsOne);
    expect(find.text('Isaac'), findsOne);
    expect(find.byType(PlayerPosition), findsExactly(3));
  });

  testWidgets('should present doubt section', (tester) async {
    await tester.pumpWidget(sut);
    presenter.emitNextEventWith(
      doubt: const [
        NextEventPlayerViewModel(name: 'Henrique'),
        NextEventPlayerViewModel(name: 'Rafael'),
        NextEventPlayerViewModel(name: 'Isaac'),
      ],
    );
    await tester.pump();
    expect(find.text('DÚVIDA'), findsOne);
    expect(find.text('3'), findsOne);
    expect(find.text('Henrique'), findsOne);
    expect(find.text('Rafael'), findsOne);
    expect(find.text('Isaac'), findsOne);
    expect(find.byType(PlayerPosition), findsExactly(3));
  });

  testWidgets('should hide all sections', (tester) async {
    await tester.pumpWidget(sut);
    presenter.emitNextEvent();
    await tester.pump();
    expect(find.text('DENTRO - GOLEIROS'), findsNothing);
    expect(find.text('DENTRO - JOGADORES'), findsNothing);
    expect(find.text('FORA'), findsNothing);
    expect(find.text('DÚVIDA'), findsNothing);
    expect(find.byType(PlayerPosition), findsExactly(0));
  });
}
