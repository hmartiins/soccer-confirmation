import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/infra/mappers/mapper.dart';
import 'package:advanced_flutter/infra/mappers/next_event_player_mapper.dart';
import 'package:advanced_flutter/infra/types/json.dart';

final class NextEventMapper extends Mapper<NextEvent> {
  @override
  NextEvent toObject(dynamic json) => NextEvent(
        groupName: json['groupName'],
        date: DateTime.parse(json['date']),
        players: NextEventPlayerMapper().toList(json['players']),
      );

  Json toJson(NextEvent event) => {
        'groupName': event.groupName,
        'date': event.date.toIso8601String(),
        'players': NextEventPlayerMapper().toJsonArr(event.players),
      };
}
