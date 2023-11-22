import 'package:latlong2/latlong.dart';

class MqttData {
  // [lat, lon, rotation?, speed?, tripId?, direction, isFull?]
  final String shortName;
  final LatLng position;
  final int? rotation;
  final int? speed;
  final int? tripId;
  final int direction;
  final bool? isFull;
  final int? nextStop;
  final int vehicleNum;
  final DateTime lastUpdate;
  const MqttData({
    required this.shortName,
    required this.vehicleNum,
    required this.position,
    this.rotation,
    this.tripId,
    this.speed,
    required this.direction,
    this.isFull,
    this.nextStop,
    required this.lastUpdate,
  });
  MqttData copyWith(
      {LatLng? position,
      int? rotation,
      int? speed,
      int? tripId,
      int? direction,
      bool? isFull,
      int? nextStop,
      DateTime? lastUpdate}) {
    return MqttData(
      shortName: shortName,
      vehicleNum: vehicleNum,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      speed: speed ?? this.speed,
      tripId: tripId ?? this.tripId,
      direction: direction ?? this.direction,
      isFull: isFull ?? this.isFull,
      nextStop: nextStop ?? this.nextStop,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  factory MqttData.fromList(List<dynamic> list, String topic) {
    final List<String> splitTopic = topic.split('/');

    return MqttData(
      shortName: splitTopic[1],
      vehicleNum: int.parse(splitTopic[2]),
      position: LatLng(list[0] as double, list[1] as double),
      rotation: list[2] as int?,
      speed: list[3] as int?,
      tripId: list[4],
      direction: list[5] as int? ?? 2,
      isFull: list.length > 7 ? list[7] : null,
      nextStop: list[6] as int?,
      lastUpdate: DateTime.now(),
    );
  }
}
