import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:advanced_flutter/infra/types/json.dart';

class NextEventPlayerMapper {
  static List<NextEventPlayer> toList(JsonArr arr) =>
      arr.map(toObject).toList();

  static NextEventPlayer toObject(Json json) => NextEventPlayer(
        id: json['id'],
        name: json['name'],
        photo: json['photo'],
        position: json['position'],
        isConfirmed: json['isConfirmed'],
        confirmationDate: DateTime.tryParse(json['confirmationDate'] ?? ''),
      );
}