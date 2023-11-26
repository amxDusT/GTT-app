import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/settings_controller.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});
  final _settingsController = Get.put(SettingsController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Rimuovi dati GTT'),
            onTap: () {
              _settingsController.removeData();
            },
          ),
          ListTile(
            title: const Text('Resetta dati GTT'),
            onTap: () {
              _settingsController.resetData();
            },
          )
        ],
      ),
    );
  }
}
