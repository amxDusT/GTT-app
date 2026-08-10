import 'dart:math' as math;

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
    if (offset == 0 || initialPolyline.length < 2) return initialPolyline;

    ({double x, double y}) normal(LatLng a, LatLng b) {
      final cosLat = math.cos(a.latitude * math.pi / 180);
      final vx = (b.longitude - a.longitude) * cosLat; // east
      final vy = b.latitude - a.latitude; // north
      final len = math.sqrt(vx * vx + vy * vy);
      if (len == 0) return (x: 0, y: 0);
      return (x: -vy / len, y: vx / len); //  90°
    }

    final result = <LatLng>[];
    for (int i = 0; i < initialPolyline.length; i++) {
      final point = initialPolyline[i];
      final prev =
          i > 0 ? normal(initialPolyline[i - 1], initialPolyline[i]) : null;
      final next = i < initialPolyline.length - 1
          ? normal(initialPolyline[i], initialPolyline[i + 1])
          : null;

      // miter join
      var nx = (prev?.x ?? next!.x) + (next?.x ?? prev!.x);
      var ny = (prev?.y ?? next!.y) + (next?.y ?? prev!.y);
      final m = math.sqrt(nx * nx + ny * ny);
      if (m != 0) {
        nx /= m;
        ny /= m;
      }

      final cosLat = math.cos(point.latitude * math.pi / 180);
      result.add(LatLng(
        point.latitude + offset * ny,
        point.longitude + offset * nx / (cosLat == 0 ? 1 : cosLat),
      ));
    }
    return result;
  }

  /*
    Check if vehicle is bus or tram.
    Trams have vehicle number:
    - 28xx/29xx : old trams, yellow/orange
    - 50xx : "TPR", grey trams
    - 60xx : "Cityway" trams, quadrati
    - 80xx : "Hitachirail" trams, new ones, blue.
    rest is bus
  */
  static bool isTram(int vehicleNum) {
    return RegExp(r'^(28|29|50|60|80)\d{2}$').hasMatch(vehicleNum.toString());
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
