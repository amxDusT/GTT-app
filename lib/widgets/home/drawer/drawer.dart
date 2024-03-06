import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/settings_controller.dart';
import 'package:flutter_gtt/widgets/home/drawer/drawer_tile.dart';
import 'package:get/get.dart';

class HomeDrawer extends StatelessWidget {
  final Map<String, dynamic> beta = {
    'Mappa Default': () => Get.toNamed('/map'),
  };
  final Map<String, dynamic> elements = {
    'Leggi Biglietto/Carta': () => Get.toNamed('/nfc'),
    'Mappa Bus/Tram': () => Get.toNamed('/routelist'),
    'Impostazioni': () => Get.toNamed('/settings'),
  };
  final _settingsController = Get.find<SettingsController>();
  HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
                          const Divider(),
                        ],
                      ),
                    ...elements.entries.expand(
                      (e) => [
                        DrawerTile(
                          title: e.key,
                          onTap: e.value,
                        ),
                        if (e.key != elements.keys.last) const Divider(),
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
