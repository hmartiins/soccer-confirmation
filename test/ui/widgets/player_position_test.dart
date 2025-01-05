import 'package:advanced_flutter/ui/widgets/player_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('should handle goalkeeper position', (tester) async {
    final sut = MaterialApp(
      home: PlayerPosition(position: 'goalkeeper'),
    );
    await tester.pumpWidget(sut);
    expect(find.text('Goleiro'), findsOneWidget);
  });

  testWidgets('should handle defender position', (tester) async {
    final sut = MaterialApp(
      home: PlayerPosition(position: 'defender'),
    );
    await tester.pumpWidget(sut);
    expect(find.text('Zagueiro'), findsOneWidget);
  });

  testWidgets('should handle midfielder position', (tester) async {
    final sut = MaterialApp(
      home: PlayerPosition(position: 'midfielder'),
    );
    await tester.pumpWidget(sut);
    expect(find.text('Meia'), findsOneWidget);
  });

  testWidgets('should handle forward position', (tester) async {
    final sut = MaterialApp(
      home: PlayerPosition(position: 'forward'),
    );
    await tester.pumpWidget(sut);
    expect(find.text('Atacante'), findsOneWidget);
  });

  testWidgets('should handle positionless', (tester) async {
    final sut = MaterialApp(
      home: PlayerPosition(position: null),
    );
    await tester.pumpWidget(sut);
    expect(find.text('Gandula'), findsOneWidget);
  });
}
