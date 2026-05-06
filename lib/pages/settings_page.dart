import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/settings_controller.dart';
import 'package:get/get.dart';
import 'package:torino_mobility/l10n/localization_service.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});
  final _settingsController = Get.find<SettingsController>();

  List<Widget> getList(BuildContext context) {
    return [
      ListTile(
        title: Text(l10n.settingsDarkThemeTitle),
        trailing: Obx(() => Switch(
              value: _settingsController.isDarkMode.value,
              onChanged: (value) => _settingsController.switchDarkMode(),
            )),
      ),
      ListTile(
        title: Text(l10n.settingsShowFavoriteRoutesTitle),
        trailing: Obx(() => Switch(
              value: _settingsController.isFavoritesRoutesShowing.value,
              onChanged: (value) =>
                  _settingsController.switchFavoritesRoutesShowing(),
            )),
      ),
      ListTile(
        title: Text(l10n.settingsShowSecondsTitle),
        trailing: Obx(() => Switch(
              value: _settingsController.showSecondsInUpdates.value,
              onChanged: (value) =>
                  _settingsController.switchShowSecondsInUpdates(),
            )),
      ),
      ListTile(
        title: Text(l10n.settingsShowStopOnMapTitle),
        subtitle: Text(l10n.settingsShowStopOnMapSubtitle),
        trailing: Obx(() => Switch(
              value: _settingsController.isFermataShowing.value,
              onChanged: (value) => _settingsController.switchFermataShowing(),
            )),
      ),
      ListTile(
        title: Text(l10n.settingsHighlightInitialStopTitle),
        subtitle: Text(l10n.settingsHighlightInitialStopSubtitle),
        trailing: Obx(() => Switch(
              value: _settingsController.isInitialHighlighted.value,
              onChanged: (value) =>
                  _settingsController.switchInitialHighlighted(),
            )),
      ),
      ListTile(
        title: Text(l10n.settingsShowRoutesWithoutPassagesTitle),
        subtitle: Text(l10n.settingsShowRoutesWithoutPassagesSubtitle),
        trailing: Obx(() => Switch(
              value: _settingsController.isRouteWithoutPassagesShowing.value,
              onChanged: (value) =>
                  _settingsController.switchRouteWithoutPassagesShowing(),
            )),
      ),
      if (kDebugMode)
        ListTile(
          title: Text(l10n.settingsBetaFeaturesTitle),
          subtitle: Text(l10n.settingsBetaFeaturesSubtitle),
          onTap: () => _settingsController.betaFeaturesInfo(),
          trailing: Obx(() => Switch(
                value: _settingsController.showBetaFeatures.value,
                onChanged: (value) => _settingsController.switchBetaFeatures(),
              )),
        ),
      ListTile(
        title: Text(l10n.settingsShowTutorialTitle),
        onTap: () => _settingsController.showTutorial(),
      ),
      ListTile(
        title: Text(l10n.settingsRefreshDataTitle),
        onTap: () => _settingsController.resetData(),
      ),
      ListTile(
        title: Text(l10n.settingsBackupFavoritesTitle),
        onTap: () => _settingsController.exportFavorites(),
      ),
      ListTile(
        title: Text(l10n.settingsRestoreFavoritesTitle),
        onTap: () => _settingsController.importFavorites(),
      ),
      ListTile(
        title: Text(l10n.settingsShareAppTitle),
        onTap: () => _settingsController.shareApp(),
      ),
      ListTile(
        title: Text(l10n.settingsInfoTitle),
        onTap: () => _settingsController.infoApp(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsPageTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView(shrinkWrap: true, children: [
              ...getList(context).expand(
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
                  () => Text(
                      l10n.settingsVersion(_settingsController.version.value)),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
