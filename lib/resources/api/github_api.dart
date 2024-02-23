import 'dart:convert';
import 'package:flutter_gtt/resources/api/api_exception.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class GithubApi {
  static const String _releaseUrl =
      "https://api.github.com/repos/amxDust/GTT-app/releases/latest";

  static Future<bool> checkVersion() async {
    // thx to https://stackoverflow.com/a/70136908
    int getExtendedVersionNumber(String version) {
      List versionCells = version.split('.');
      versionCells = versionCells.map((i) => int.parse(i)).toList();
      return versionCells[0] * 100000 +
          versionCells[1] * 1000 +
          versionCells[2];
    }

    final response = await http.get(Uri.parse(_releaseUrl));
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final String gitVersion = jsonResponse['tag_name'];
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String currentVersion = packageInfo.version;

    return getExtendedVersionNumber(gitVersion) >
        getExtendedVersionNumber(currentVersion);
  }

  static Future<Map<String, dynamic>> getAppInfo() async {
    final response = await http.get(Uri.parse(_releaseUrl));
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    final Map<String, dynamic> jsonResponse = json.decode(response.body);

    final Map<String, dynamic> result = {
      'version': jsonResponse['tag_name'],
      'url': jsonResponse['assets'][0]['browser_download_url'],
      'update': jsonResponse['body'] ?? '',
    };
    return result;
  }
}
