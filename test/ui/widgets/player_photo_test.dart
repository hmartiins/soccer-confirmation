import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class PlayerPhoto extends StatelessWidget {
  final String initials;
  final String? photo;

  const PlayerPhoto({
    super.key,
    required this.initials,
    this.photo,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: Text(initials),
    );
  }
}

void main() {
  testWidgets('should present initals when there is no photo', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlayerPhoto(initials: 'HM', photo: null),
      ),
    );
    expect(find.text('HM'), findsOneWidget);
  });
}
