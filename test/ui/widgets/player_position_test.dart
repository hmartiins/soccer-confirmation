import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class PlayerPosition extends StatelessWidget {
  final String? position;

  const PlayerPosition({
    super.key,
    this.position,
  });

  String buildPositionLabel() => switch (position) {
        'goalkeeper' => 'Goleiro',
        'defender' => 'Zagueiro',
        _ => 'Gandula',
      };

  @override
  Widget build(BuildContext context) {
    return Text(buildPositionLabel());
  }
}

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

  testWidgets('should handle positionless', (tester) async {
    final sut = MaterialApp(
      home: PlayerPosition(position: null),
    );
    await tester.pumpWidget(sut);
    expect(find.text('Gandula'), findsOneWidget);
  });
}
