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
  NextEventPlayer makeSut(String name) =>
      NextEventPlayer(id: '', name: name, isConfirmed: true);

  test('should return the first letter of the first and last names', () {
    // System under test
    final sut = makeSut('Henrique Martins');
    final sut2 = makeSut('Giovanna Silva');
    final sut3 = makeSut('Isaac Melo Alves Martins');

    expect(sut.getInitials(), 'HM');
    expect(sut2.getInitials(), 'GS');
    expect(sut3.getInitials(), 'IM');
  });
}
