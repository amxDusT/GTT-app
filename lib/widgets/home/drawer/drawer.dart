import 'package:flutter/material.dart';
import 'package:flutter_gtt/pages/map/map_global.dart';
import 'package:flutter_gtt/pages/nfc/nfc_page.dart';
import 'package:flutter_gtt/pages/route_list_page.dart';
import 'package:flutter_gtt/pages/settings_page.dart';
import 'package:flutter_gtt/widgets/home/drawer/drawer_tile.dart';
import 'package:get/get.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

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
                    height: context.height * 0.5,
                  ),
                  DrawerTile(
                    title: 'Mappa Default',
                    onTap: () => Get.to(() => MapGlobal()),
                    //heroTag: 'NFCPage',
                  ),
                  DrawerTile(
                      title: 'Leggi Biglietto/Carta',
                      onTap: () => Get.to(() => NfcPage()),
                      heroTag: 'NFCPage'),
                  const Divider(),
                  DrawerTile(
                    title: 'Mappa Bus/Tram',
                    onTap: () => Get.to(() => RouteListPage()),
                    heroTag: 'RouteListPage',
                  ),
                  const Divider(),
                  DrawerTile(
                    title: 'Impostazioni',
                    onTap: () => Get.to(
                      () => SettingsPage(),
                    ),
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
