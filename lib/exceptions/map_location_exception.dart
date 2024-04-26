import 'package:geolocator/geolocator.dart';

class MapLocationException implements Exception {
  final LocationPermission? locationPermission;
  final String message;

  MapLocationException(this.message, {this.locationPermission});
}
