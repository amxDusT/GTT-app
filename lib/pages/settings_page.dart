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
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title:
                      const Text('Mostra secondi dall\'ultimo aggiornamento'),
                  trailing: Obx(() => Switch(
                        value: _settingsController.showSecondsInUpdates.value,
                        onChanged: (value) =>
                            _settingsController.switchShowSecondsInUpdates(),
                      )),
                ),
                ListTile(
                  title: const Text('Mostra fermata nella mappa'),
                  subtitle: const Text(
                      'Mostra popup della fermata iniziale nella mappa'),
                  trailing: Obx(() => Switch(
                        value: _settingsController.isFermataShowing.value,
                        onChanged: (value) =>
                            _settingsController.switchFermataShowing(),
                      )),
                ),
                ListTile(
                  title: const Text('Visualizza tratte senza passaggi'),
                  subtitle: const Text(
                      'Mostra tratte senza passaggi da \'Guarda sulla mappa\''),
                  trailing: Obx(() => Switch(
                        value: _settingsController
                            .isRouteWithoutPassagesShowing.value,
                        onChanged: (value) => _settingsController
                            .switchRouteWithoutPassagesShowing(),
                      )),
                ),
                ListTile(
                  title: const Text('Aggiorna dati GTT'),
                  onTap: () {
                    _settingsController.resetData();
                  },
                ),
                ListTile(
                  title: const Text('Informazioni app'),
                  onTap: () {
                    _settingsController.infoApp();
                  },
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
            child: Obx(
              () => Text('Versione: ${_settingsController.version}'),
            ),
          )
        ],
      ),
    );
  }
}
