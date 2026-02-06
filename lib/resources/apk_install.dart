import 'dart:io';

import 'package:torino_mobility/exceptions/api_exception.dart';
import 'package:torino_mobility/resources/api/github_api.dart';
import 'package:http/http.dart' as http;
import 'package:install_plugin/install_plugin.dart';

class ApkInstall {
  static Future<void> downloadNewVersion() async {
    final Map<String, dynamic> result = await GithubApi.getAppInfo();

    final String path =
        '/storage/emulated/0/Download/GTT-${result['version']}.apk';

    File file = File(path);
    if (!await file.exists()) {
      await downloadFile(result['url'], file);
    }

    await _localInstallApk(path);
  }

  static Future<void> downloadFile(String url, File file) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    final bodyBytes = response.bodyBytes;
    // save apk to download folder
    await file.writeAsBytes(bodyBytes);
  }

  static Future<void> _localInstallApk(String path) async {
    await InstallPlugin.install(path);
  }
}
