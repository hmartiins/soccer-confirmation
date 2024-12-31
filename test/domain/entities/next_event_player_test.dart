import 'package:flutter_test/flutter_test.dart';

class NextEventPlayer {
  final String id;
  final String name;
  final bool isConfirmed;
  final String? photo;
  final String? position;
  final DateTime? confirmationDate;

  NextEventPlayer({
    required this.id,
    required this.name,
    required this.isConfirmed,
    this.photo,
    this.position,
    this.confirmationDate,
  });

  String getInitials() {
    final names = name.split(' ');
    final firstChar = names.first[0];
    final lastChar = names.last[0];

    return '$firstChar$lastChar';
  }
}

void main() {
  test('should return the first letter of the first and last names', () {
    final player = NextEventPlayer(
      id: '',
      name: 'Henrique Martins',
      isConfirmed: true,
    );

    final player2 = NextEventPlayer(
      id: '',
      name: 'Giovanna Silva',
      isConfirmed: true,
    );

    final player3 = NextEventPlayer(
      id: '',
      name: 'Isaac Melo Alves Martins',
      isConfirmed: true,
    );

    expect(player.getInitials(), 'HM');
    expect(player2.getInitials(), 'GS');
    expect(player3.getInitials(), 'IM');
  });
}
