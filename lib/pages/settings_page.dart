import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/loading_controller.dart';
import 'package:flutter_gtt/controllers/settings_controller.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});
  final _settingsController = Get.find<SettingsController>();

  List<Widget> getList() {
    return [
      ListTile(
        title: const Text('Mostra linee preferite nella pagina iniziale'),
        trailing: Obx(() => Switch(
              value: _settingsController.isFavoritesRoutesShowing.value,
              onChanged: (value) =>
                  _settingsController.switchFavoritesRoutesShowing(),
            )),
      ),
      ListTile(
        title: const Text('Mostra secondi dall\'ultimo aggiornamento'),
        trailing: Obx(() => Switch(
              value: _settingsController.showSecondsInUpdates.value,
              onChanged: (value) =>
                  _settingsController.switchShowSecondsInUpdates(),
            )),
      ),
      ListTile(
        title: const Text('Mostra fermata nella mappa'),
        subtitle: const Text('Mostra popup della fermata iniziale nella mappa'),
        trailing: Obx(() => Switch(
              value: _settingsController.isFermataShowing.value,
              onChanged: (value) => _settingsController.switchFermataShowing(),
            )),
      ),
      ListTile(
        title: const Text('Visualizza tratte senza passaggi'),
        subtitle: const Text(
            'Mostra tratte senza passaggi da \'Guarda sulla mappa\''),
        trailing: Obx(() => Switch(
              value: _settingsController.isRouteWithoutPassagesShowing.value,
              onChanged: (value) =>
                  _settingsController.switchRouteWithoutPassagesShowing(),
            )),
      ),
      if (kDebugMode)
        ListTile(
          title: const Text('Beta features'),
          subtitle: const Text('Clicca per informazioni'),
          onTap: () => _settingsController.betaFeaturesInfo(),
          trailing: Obx(() => Switch(
                value: _settingsController.showBetaFeatures.value,
                onChanged: (value) => _settingsController.switchBetaFeatures(),
              )),
        ),
      ListTile(
        title: const Text('Mostra tutorial'),
        onTap: () => _settingsController.showTutorial(),
      ),
      ListTile(
        title: const Text('Aggiorna dati GTT'),
        onTap: () => _settingsController.resetData(),
      ),
      if (kDebugMode)
        ListTile(
          title: const Text('Download release'),
          onTap: () async => await Get.find<LoadingController>().checkVersion(),
        ),
      ListTile(
        title: const Text('Backup locale preferiti'),
        onTap: () => _settingsController.exportFavorites(),
      ),
      ListTile(
        title: const Text('Ripristina preferiti'),
        onTap: () => _settingsController.importFavorites(),
      ),
      ListTile(
        title: const Text('Condividi app'),
        onTap: () => _settingsController.shareApp(),
      ),
      ListTile(
        title: const Text('Informazioni app'),
        onTap: () => _settingsController.infoApp(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView(shrinkWrap: true, children: [
              ...getList().expand(
                (element) => [
                  element,
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 15,
                    endIndent: 15,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(top: 20, bottom: 4),
                alignment: Alignment.center,
                child: Obx(
                  () => Text('Versione: ${_settingsController.version}'),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
