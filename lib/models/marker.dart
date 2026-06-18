import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/map/map_controller.dart';
import 'package:torino_mobility/models/gtt/stop.dart';
import 'package:torino_mobility/models/mqtt_data.dart';
import 'package:torino_mobility/resources/globals.dart';
import 'package:torino_mobility/resources/utils/utils.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:latlong2/latlong.dart';

@immutable
class UserLocationMarker extends Marker {
  final Position position;
  UserLocationMarker({required this.position, double? heading})
      : super(
            point: LatLng(position.latitude, position.longitude),
            height: 30,
            width: 30,
            child: Transform.rotate(
                angle: heading != null ? heading * pi / 180 : 0,
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    DecoratedIcon(
                      icon: Icon(
                        Icons.navigation,
                        size: 28,
                        color: Colors.blue,
                      ),
                      decoration: IconDecoration(border: IconBorder()),
                    ),
                  ],
                )));
}

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
                            .withValues(alpha: 0.9),
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
        mqttData: this.mqttData.copyWith(
              position: mqttData?.position,
              rotation: mqttData?.rotation,
              speed: mqttData?.speed,
              tripId: mqttData?.tripId,
              direction: mqttData?.direction,
              isFull: mqttData?.isFull,
              nextStop: mqttData?.nextStop,
              lastUpdate: mqttData?.lastUpdate,
            ),
        color: color ?? this.color,
        internalColor: internalColor ?? this.internalColor);
  }
}

@immutable
class FermataMarker extends Marker {
  final Stop fermata;
  final double? zoom;
  final Color color;

  final bool isTerminal;
  static const Color defaultColor = Colors.red;
  FermataMarker({
    required this.fermata,
    this.zoom,
    this.color = defaultColor,
    this.isTerminal = false,
  }) : super(
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
          child: _buildDot(zoom: zoom, color: color, isTerminal: isTerminal),
        );

  static const double _dotMinSize = 12;
  static const double _dotMaxSize = 20;

  static Widget _buildDot({
    double? zoom,
    required Color color,
    bool isTerminal = false,
  }) {
    final size = _dotSize(zoom);
    // White fill; [color] (route color, or green when highlighted) is shown
    // only as the border.
    Widget dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: color, width: size / (isTerminal ? 5 : 7)),
      ),
    );

    // Terminal/CAP stops get a 2nd, outer white ring around the colored border.
    if (isTerminal) {
      dot = Container(
        padding: EdgeInsets.all(size / 5),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: dot,
      );
    }

    return MetaData(
      behavior: HitTestBehavior.opaque,
      child: Center(child: dot),
    );
  }

  static double _dotSize(double? zoom) {
    if (zoom == null) return _dotMinSize;
    final t = ((zoom - MapPageController.minZoom) /
            (MapPageController.maxZoom - MapPageController.minZoom))
        .clamp(0.0, 1.0);
    return _dotMinSize + t * (_dotMaxSize - _dotMinSize);
  }

  FermataMarker copyWith({double? zoom, Color? color, bool? isTerminal}) {
    return FermataMarker(
      fermata: fermata,
      zoom: zoom ?? this.zoom,
      color: color ?? this.color,
      isTerminal: isTerminal ?? this.isTerminal,
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
