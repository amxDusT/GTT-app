import 'package:flutter/material.dart';
import 'package:flutter_gtt/models/gtt_stop.dart';
import 'package:flutter_gtt/models/mqtt_data.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:latlong2/latlong.dart';

class Test {
  //final Marker mark;
  //Test({int marker}) : mark = Marker(point: point, child: child);
}

@immutable
class VehicleMarker extends Marker {
  final MqttVehicle mqttData;
  final Color? color;
  VehicleMarker({required this.mqttData, this.color})
      : super(
          point: mqttData.position,
          child: Transform.rotate(
            angle: (mqttData.rotation ?? 0) * pi / 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  //top: 5,
                  child: Container(
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Utils.lighten(color ?? Colors.blue)
                          .withOpacity(0.9), //color ?? Colors.blue,
                    ),
                  ),
                ),
                DecoratedIcon(
                  icon: Icon(
                    Icons.assistant_navigation,
                    size: 24,
                    color: color ?? Colors.blue,
                  ),
                  decoration: const IconDecoration(border: IconBorder()),
                ),
              ],
            ),
          ),
        );

  VehicleMarker copyWith({MqttVehicle? mqttData, Color? color}) {
    return VehicleMarker(
      mqttData: mqttData ?? this.mqttData,
      color: color ?? this.color,
    );
  }
}

@immutable
class FermataMarker extends Marker {
  final Stop fermata;
  FermataMarker({required this.fermata})
      : super(
          point: LatLng(fermata.lat, fermata.lon),
          child: const Icon(
            Icons.circle,
            size: 12,
            color: Colors.red,
          ),
        );
}
