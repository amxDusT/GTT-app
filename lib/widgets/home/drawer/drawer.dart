import 'package:flutter/material.dart';
import 'package:flutter_gtt/pages/map/map_global.dart';
import 'package:flutter_gtt/pages/nfc/nfc_page.dart';
import 'package:flutter_gtt/pages/route_list_page.dart';
import 'package:flutter_gtt/pages/settings_page.dart';
import 'package:flutter_gtt/widgets/home/drawer/drawer_tile.dart';
import 'package:get/get.dart';

class HomeDrawer extends StatelessWidget {
  final Map<String, dynamic> elements = {
    'Mappa Default': () => Get.to(() => MapGlobal()),
    'Leggi Biglietto/Carta': () => Get.to(() => NfcPage()),
    'Mappa Bus/Tram': () => Get.to(() => RouteListPage()),
    'Impostazioni': () => Get.to(() => SettingsPage()),
  };

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
              child: ListView(
                shrinkWrap: true,
                children: [
                  SizedBox(
                    height: context.height * (0.65 - 0.05 * elements.length),
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
