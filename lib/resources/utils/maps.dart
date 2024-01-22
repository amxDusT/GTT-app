import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapUtils {
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
}
