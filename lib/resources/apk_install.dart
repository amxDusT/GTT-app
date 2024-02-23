import 'dart:io';

import 'package:flutter_gtt/resources/api/api_exception.dart';
import 'package:flutter_gtt/resources/api/github_api.dart';
import 'package:http/http.dart' as http;
import 'package:install_plugin/install_plugin.dart';

class ApkInstall {
  static Future<void> downloadNewVersion() async {
    final Map<String, dynamic> result = await GithubApi.getAppInfo();

    final response = await http.get(Uri.parse(result['url']));
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    final bodyBytes = response.bodyBytes;

    final String path =
        '/storage/emulated/0/Download/GTT-${result['version']}.apk';
    File file = File(path);
    // save apk to download folder
    await file.writeAsBytes(bodyBytes);
    await _localInstallApk(path);
  }

  static Future<void> _localInstallApk(String path) async {
    await InstallPlugin.install(path);
  }
}
