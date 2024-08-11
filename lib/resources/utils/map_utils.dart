import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  /// keep for each route, the list of signed stops
  static final Map<String, Set<int>> _signedStops = {};

  static void addSignedStop(String routeId, int signedStops) {
    final stops = (_signedStops[routeId] ?? {})..add(signedStops);
    _signedStops[routeId] = stops;
  }

  static void removeSignedStop(String routeId, int signedStops) {
    final stops = (_signedStops[routeId] ?? {})..remove(signedStops);
    _signedStops[routeId] = stops;
  }

  static Set<int> getSignedStops(String routeId) {
    return _signedStops[routeId] ?? {};
  }

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    } else {
      throw 'Could not open the map.';
    }
  }

  static List<LatLng> decodeGooglePolyline(String encodedPolyline) {
    List<LatLng> decodedPoints = [];
    int index = 0;
    int lat = 0, lon = 0;

    while (index < encodedPolyline.length) {
      int shift = 0, result = 0;
      int byte;

      do {
        byte = encodedPolyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int deltaLat = ((result & 1) == 1 ? ~(result >> 1) : (result >> 1));
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        byte = encodedPolyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int deltaLon = ((result & 1) == 1 ? ~(result >> 1) : (result >> 1));
      lon += deltaLon;

      double latDouble = lat / 1e5;
      double lonDouble = lon / 1e5;

      LatLng point = LatLng(latDouble, lonDouble);
      decodedPoints.add(point);
    }

    return decodedPoints;
  }

  static List<LatLng> polylineOffset(List<LatLng> initialPolyline,
      [double offset = 0.0001]) {
    return initialPolyline
        .map((point) => LatLng(point.latitude + offset, point.longitude))
        .toList();
  }

  /*
    Check if vehicle is bus or tram.
    Trams have vehicle number:
    - 28xx : old trams, yellow/orange
    - 50xx : "TPR", grey trams
    - 60xx : "Cityway" trams, quadrati
    - 80xx : "Hitachirail" trams, new ones, blue.
    rest is bus
  */
  static bool isTram(int vehicleNum) {
    return RegExp(r'^(28|50|60|80)\d{2}$').hasMatch(vehicleNum.toString());
  }

  static Marker addressMarker(LatLng point) {
    return Marker(
      point: point,
      width: 10,
      height: 10,
      child: const Icon(
        Icons.circle,
        color: Colors.grey,
      ),
    );
  }

  static bool isAtSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static String getHour(DateTime date) {
    return DateFormat('H:mm', Get.locale?.languageCode).format(date);
  }

  static String dateToString(DateTime date) {
    final now = DateTime.now();
    if (isAtSameDay(date, now)) {
      final hour = getHour(date);
      return 'Oggi, $hour';
    } else if (isAtSameDay(date, now.add(const Duration(days: 1)))) {
      final hour = getHour(date);
      return 'Domani, $hour';
    } else if (isAtSameDay(date, now.subtract(const Duration(days: 1)))) {
      final hour = getHour(date);
      return 'Ieri, $hour';
    }
    return DateFormat('d MMM H:mm', Get.locale?.languageCode).format(date);
  }
}
