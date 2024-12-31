import 'package:advanced_flutter/domain/entities/next_event_player.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  String initialsOf(String name) =>
      NextEventPlayer(id: '', name: name, isConfirmed: true).initials;

  test('should return the first letter of the first and last names', () {
    expect(initialsOf('Henrique Martins'), 'HM');
    expect(initialsOf('Giovanna Silva'), 'GS');
    expect(initialsOf('Isaac Melo Alves Martins'), 'IM');
  });

  test('should return the first letter of the first name', () {
    expect(initialsOf('Henrique'), 'HE');
    expect(initialsOf('H'), 'H');
  });

  test('should return "-" when name is empty', () {
    expect(initialsOf(''), '-');
  });

  test('should convert to uppercase', () {
    expect(initialsOf('isaac melo alves martins'), 'IM');
    expect(initialsOf('henrique'), 'HE');
    expect(initialsOf('h'), 'H');
  });

  test('should ignore extra whitespaces', () {
    expect(initialsOf('Henrique Martins '), 'HM');
    expect(initialsOf(' Henrique Martins'), 'HM');
    expect(initialsOf('Henrique  Martins'), 'HM');
    expect(initialsOf(' Henrique  Martins '), 'HM');

    expect(initialsOf(' Henrique '), 'HE');
    expect(initialsOf(' H '), 'H');

    expect(initialsOf(' '), '-');
    expect(initialsOf('  '), '-');
  });
}
