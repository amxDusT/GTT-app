import 'package:latlong2/latlong.dart';

class MqttVehicle {
  final String gtfsId;
  final LatLng position;
  final int? rotation;
  final int? speed;
  final int? tripId;
  final int direction;
  final bool? isFull;
  final int? nextStop;
  final int vehicleNum;
  final DateTime lastUpdate;
  const MqttVehicle({
    required this.gtfsId,
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
  MqttVehicle copyWith(
      {LatLng? position,
      int? rotation,
      int? speed,
      int? tripId,
      int? direction,
      bool? isFull,
      int? nextStop,
      DateTime? lastUpdate}) {
    return MqttVehicle(
      gtfsId: gtfsId,
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

  factory MqttVehicle.fromList(List<dynamic> list, String topic) {
    final List<String> splitTopic = topic.split('/');
    return MqttVehicle(
      gtfsId: 'gtt:${splitTopic[1]}U',
      vehicleNum: int.parse(splitTopic[2]),
      position: LatLng(list[0] as double, list[1] as double),
      rotation: list[2] as int?,
      speed: list[3] as int?,
      tripId: list[4],
      direction: list[5] as int? ?? 2,
      nextStop: list[6] as int?,
      isFull: list.length > 7 ? list[7] : null,
      lastUpdate: DateTime.now(),
    );
  }
}
