import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:advanced_flutter/infra/mappers/mapper.dart';
import 'package:advanced_flutter/infra/types/json.dart';

final class NextEventPlayerMapper extends Mapper<NextEventPlayer> {
  @override
  NextEventPlayer toObject(dynamic json) => NextEventPlayer(
        id: json['id'],
        name: json['name'],
        photo: json['photo'],
        position: json['position'],
        isConfirmed: json['isConfirmed'],
        confirmationDate: DateTime.tryParse(json['confirmationDate'] ?? ''),
      );

  JsonArr toJsonArr(List<NextEventPlayer> players) =>
      players.map((player) => toJson(player)).toList();

  Json toJson(NextEventPlayer event) => {
        'id': event.id,
        'name': event.name,
        'photo': event.photo,
        'position': event.position,
        'isConfirmed': event.isConfirmed,
        'confirmationDate': event.confirmationDate?.toIso8601String(),
      };
}
