import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

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
      foregroundImage: photo != null ? NetworkImage(photo!) : null,
      child: photo == null ? Text(initials) : null,
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

  testWidgets('should hide initals when there is photo', (tester) async {
    mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlayerPhoto(initials: 'HM', photo: 'http://photo.com'),
        ),
      );
      expect(find.text('HM'), findsNothing);
    });
  });
}
