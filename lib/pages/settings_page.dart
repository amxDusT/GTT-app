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
            title: const Text('Mostra fermata nella mappa'),
            subtitle:
                const Text('Mostra popup della fermata iniziale nella mappa'),
            trailing: Obx(() => Switch(
                  value: _settingsController.isFermataShowing.value,
                  onChanged: (value) =>
                      _settingsController.switchFermataShowing(),
                )),
            onTap: () {
              _settingsController.resetData();
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
