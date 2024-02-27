import 'package:flutter/material.dart';
import 'package:flutter_gtt/pages/nfc/nfc_page.dart';
import 'package:flutter_gtt/pages/route_list_page.dart';
import 'package:flutter_gtt/pages/settings_page.dart';
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
                  Hero(
                    tag: 'NFCPage',
                    flightShuttleBuilder: ((flightContext, animation,
                            flightDirection, fromHeroContext, toHeroContext) =>
                        Material(
                          type: MaterialType.transparency,
                          child: toHeroContext.widget,
                        )),
                    child: ListTile(
                      title: const Text('Leggi Biglietto/Carta'),
                      onTap: () => Get.to(() => NfcPage()),
                    ),
                  ),
                  const Divider(),
                  Hero(
                    tag: 'RouteListPage',
                    flightShuttleBuilder: ((flightContext, animation,
                            flightDirection, fromHeroContext, toHeroContext) =>
                        Material(
                          type: MaterialType.transparency,
                          child: toHeroContext.widget,
                        )),
                    child: ListTile(
                      title: const Text('Mappa Bus/Tram'),
                      onTap: () {
                        // open Bus list page
                        Get.to(() => RouteListPage());
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Impostazioni'),
                    onTap: () {
                      // open Settings page??
                      Get.to(() => SettingsPage());
                    },
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
