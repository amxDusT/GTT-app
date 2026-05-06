import 'dart:convert';

import 'package:torino_mobility/exceptions/api_exception.dart';
import 'package:http/http.dart' as http;

class GeocoderApi {
  //point.lat=45.06836822407484&point.lon=7.676267623901368&boundary.circle.radius=0.1&lang=it&size=1&layers=address&zones=1
  static const String _url = 'https://geocode.muoversinpiemonte.it/v1/';
  static const String _reverse = 'reverse';
  static const String _search = 'autocomplete';

  static Future<Map<String, dynamic>> getAddressFromPosition(
      double lat, double lon) async {
    final request = Uri.parse(
        '$_url$_reverse?point.lat=$lat&point.lon=$lon&boundary.circle.radius=0.1&lang=it&size=1&layers=address&zones=1');
    final response = await http.get(request);
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    //print(jsonResponse);
    return jsonResponse;
  }

  static Future<Map<String, dynamic>> getAddressFromString(String query,
      {double? lat, double? lon}) async {
    final request = Uri.parse(
        '$_url$_search?text=$query&lang=it${lat != null && lon != null ? '&focus.point.lat=$lat&focus.point.lon=$lon' : ''}');
    final response = await http.get(request);
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    //print(jsonResponse);
    return jsonResponse;
  }
}
