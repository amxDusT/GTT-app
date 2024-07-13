import 'dart:convert';
import 'dart:math';
import 'package:flutter_gtt/exceptions/api_exception.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class GithubApi {
  static const String _releaseUrl =
      'https://api.github.com/repos/amxDust/GTT-app/releases/latest';

  static Future<bool> checkVersion() async {
    // thx to https://stackoverflow.com/a/70136908
    int getExtendedVersionNumber(String version) {
      List versionCells = version.split('.');
      final int length = min(versionCells.length, 3);
      const int powMax = 5;
      versionCells = versionCells.map((i) => int.parse(i)).toList();
      int result = 0;
      for (int i = 0; i < length; i++) {
        result += (versionCells[i] as int) * pow(10, powMax - 2 * i) as int;
      }
      return result;
    }

    try {
      final response = await http.get(Uri.parse(_releaseUrl)).timeout(
            const Duration(seconds: 5),
          );
      if (response.statusCode != 200) {
        throw ApiException(response.statusCode, response.body);
      }
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final String gitVersion = jsonResponse['tag_name'];
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      return getExtendedVersionNumber(gitVersion) >
          getExtendedVersionNumber(currentVersion);
    } catch (e) {
      return false;
    }
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
