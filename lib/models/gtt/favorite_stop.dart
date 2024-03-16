import 'dart:ui';

import 'package:flutter_gtt/models/gtt/stop.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:flutter_gtt/resources/storage.dart';

class FavStop extends Stop {
  final DateTime dateTime;
  final Color color;
  final String? descrizione;
  FavStop({
    required this.dateTime,
    required this.color,
    this.descrizione,
    required super.gtfsId,
    required super.code,
    required super.name,
    required super.lat,
    required super.lon,
  });
  factory FavStop.fromStop({
    required Stop stop,
    DateTime? dateTime,
    Color? color,
    String? descrizione,
  }) {
    return FavStop(
      descrizione: descrizione,
      dateTime: dateTime ?? DateTime.now(),
      color: color ?? Storage.chosenColor,
      gtfsId: stop.gtfsId,
      code: stop.code,
      name: stop.name,
      lat: stop.lat,
      lon: stop.lon,
    );
  }
  Map<String, dynamic> toDbMap() {
    return {
      'stopId': gtfsId,
      'date': dateTime.millisecondsSinceEpoch ~/ 1000,
      'color': Storage.colorToString(color),
      'descrizione': descrizione
    };
  }

  static Future<FavStop?> fromDbMap(Map<String, dynamic> js) async {
    Stop? stop =
        await DatabaseCommands.getStop(js['stopId']?.split(':')[1] ?? 0);
    return stop == null
        ? null
        : FavStop.fromStop(
            stop: (await DatabaseCommands.getStop(
                js['stopId']?.split(':')[1] ?? 0))!,
            dateTime:
                DateTime.fromMillisecondsSinceEpoch((js['date'] as int) * 1000),
            color: Storage.stringToColor(js['color'])!,
            descrizione: js['descrizione'],
          );
  }

  factory FavStop.fromJson(Map<String, dynamic> js) {
    return FavStop.fromStop(
      stop: Stop.fromJson(js),
      dateTime: DateTime.fromMillisecondsSinceEpoch((js['date'] as int) * 1000),
      color: Storage.stringToColor(js['color'])!,
      descrizione: js['descrizione'],
    );
  }

  FavStop copyWith({Color? color, String? descrizione, DateTime? dateTime}) {
    return FavStop(
      descrizione: descrizione ?? this.descrizione,
      dateTime: dateTime ?? this.dateTime,
      color: color ?? this.color,
      gtfsId: gtfsId,
      code: code,
      name: name,
      lat: lat,
      lon: lon,
    );
  }
}
