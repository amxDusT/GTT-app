import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/settings_controller.dart';
import 'package:torino_mobility/l10n/localization_service.dart';
import 'package:torino_mobility/widgets/home/drawer/drawer_tile.dart';
import 'package:get/get.dart';

class HomeDrawer extends StatelessWidget {
  final _divider = const Divider(
    height: 8,
    indent: 5,
    endIndent: 5,
  );
  final _settingsController = Get.find<SettingsController>();
  HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> beta = {
      l10n.defaultMap: () => Get.toNamed('/map'),
    };
    final Map<String, dynamic> elements = {
      l10n.readTicketOrCard: () => Get.toNamed('/nfc'),
      l10n.routesTitle: () => Get.toNamed('/routelist'),
      l10n.settings: () => Get.toNamed('/settings'),
    };
    return Drawer(
      //backgroundColor: Colors.grey,
      width: context.width * 0.6,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Obx(
                () => ListView(
                  shrinkWrap: true,
                  children: [
                    SizedBox(
                      height: context.height *
                          (0.65 -
                              0.05 *
                                  (elements.length +
                                      (_settingsController
                                              .showBetaFeatures.isTrue
                                          ? beta.length
                                          : 0))),
                    ),
                    if (_settingsController.showBetaFeatures.isTrue)
                      ...beta.entries.expand(
                        (e) => [
                          DrawerTile(
                            title: e.key,
                            onTap: e.value,
                          ),
                          _divider,
                        ],
                      ),
                    ...elements.entries.expand(
                      (e) => [
                        DrawerTile(
                          title: e.key,
                          onTap: e.value,
                        ),
                        if (e.key != elements.keys.last) _divider,
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomRight,
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
              child: const Text('amxDusT'),
            )
          ],
        ),
      ),
    );
  }
}
