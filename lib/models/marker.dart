import 'package:flutter/material.dart';
import 'package:flutter_gtt/models/gtt_models.dart';
import 'package:flutter_gtt/models/mqtt_data.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Test {
  //final Marker mark;
  //Test({int marker}) : mark = Marker(point: point, child: child);
}

@immutable
class VehicleMarker extends Marker {
  final MqttData mqttData;
  VehicleMarker({required this.mqttData})
      : super(
          point: mqttData.position,
          child: Transform.rotate(
            angle: (mqttData.rotation ?? 0) * pi / 180,
            child: const Icon(
              Icons.navigation,
              size: 20,
              color: Colors.blue,
            ),
          ),
        );
}

@immutable
class FermataMarker extends Marker {
  final Stop fermata;
  FermataMarker({required this.fermata})
      : super(
          point: LatLng(fermata.lat, fermata.lon),
          child: const Icon(
            Icons.circle,
            size: 10,
            color: Colors.red,
          ),
        );
}
