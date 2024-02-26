import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_controller.dart';
import 'package:flutter_gtt/models/gtt/stop.dart';
import 'package:flutter_gtt/models/mqtt_data.dart';
import 'package:flutter_gtt/resources/globals.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:latlong2/latlong.dart';

@immutable
class VehicleMarker extends Marker {
  final MqttVehicle mqttData;
  final Color? color;
  final Color? internalColor;
  VehicleMarker({required this.mqttData, this.color, this.internalColor})
      : super(
          point: mqttData.position,
          child: Transform.rotate(
            angle: (mqttData.rotation ?? 0) * pi / 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: internalColor ??
                        Utils.lighten(color ?? Colors.blue)
                            .withOpacity(0.9), //color ?? Colors.blue,
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

  VehicleMarker copyWith({
    MqttVehicle? mqttData,
    Color? color,
    Color? internalColor,
  }) {
    return VehicleMarker(
        mqttData: mqttData ?? this.mqttData,
        color: color ?? this.color,
        internalColor: internalColor ?? this.internalColor);
  }
}

@immutable
class FermataMarker extends Marker {
  final Stop fermata;
  final double? zoom;
  FermataMarker({required this.fermata, this.zoom})
      : super(
          height: getSize(
            zoom: zoom,
            minSize: markerMinSize,
            maxSize: markerMaxSize,
          ),
          width: getSize(
            zoom: zoom,
            minSize: markerMinSize,
            maxSize: markerMaxSize,
          ),
          point: LatLng(fermata.lat, fermata.lon),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              //color: Colors.white,
            ),
            child: Icon(
              Icons.circle,
              size: getSize(
                zoom: zoom,
                minSize: fermataMarkerMinSize,
                maxSize: fermataMarkerMaxSize,
              ),
              color: Colors.red,
            ),
          ),
        );

  FermataMarker copyWith({double? zoom}) {
    return FermataMarker(
      fermata: fermata,
      zoom: zoom ?? this.zoom,
    );
  }

  // get size based on zoom
  static double getSize(
      {required double? zoom,
      required double minSize,
      required double maxSize}) {
    return zoom != null
        ? minSize +
            ((zoom - MapPageController.minZoom) /
                    (MapPageController.maxZoom - MapPageController.minZoom)) *
                (maxSize - MapPageController.minZoom)
        : minSize;
  }
}
