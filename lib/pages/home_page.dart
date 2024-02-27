import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_gtt/controllers/home_controller.dart';
import 'package:flutter_gtt/controllers/route_list_controller.dart';
import 'package:flutter_gtt/controllers/search/home_search_controller.dart';
import 'package:flutter_gtt/controllers/settings_controller.dart';
import 'package:flutter_gtt/models/gtt/stop.dart';
import 'package:flutter_gtt/pages/info_page.dart';
import 'package:flutter_gtt/pages/map/map_point_page.dart';
import 'package:flutter_gtt/pages/nfc/nfc_page.dart';
import 'package:flutter_gtt/pages/route_list_page.dart';
import 'package:flutter_gtt/pages/search/home_search_page.dart';
import 'package:flutter_gtt/pages/settings_page.dart';
import 'package:flutter_gtt/resources/globals.dart';
import 'package:flutter_gtt/resources/storage.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:flutter_gtt/widgets/route_list_favorite_widget.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final _homeController = Get.put(HomeController());
  final _searchController = Get.put(SearchStopsController());
  final _settingsController = Get.put(SettingsController());

  void _showContextMenu(FavStop fermata) {
    showMenu(
      //surfaceTintColor: Colors.red,
      context: Get.context!,
      position: _homeController.relRectSize,
      items: [
        PopupMenuItem(
          child: const Text("Elimina"),
          onTap: () => _getDeleteConfirm(fermata),
        ),
        PopupMenuItem(
          child: const Text("Cambia Descrizione"),
          onTap: () => _changeDescription(fermata),
        ),
        PopupMenuItem(
          child: const Text("Sposta in cima"),
          onTap: () => _moveOnTop(fermata),
        ),
        PopupMenuItem(
          child: const Text('Cambia Colore'),
          onTap: () => _changeColor(fermata),
        )
      ],
    );
  }

  void _changeColor(FavStop fermata) {
    Get.defaultDialog(
        title: 'Scegli un colore',
        content: BlockPicker(
          pickerColor: fermata.color,
          onColorChanged: (color) {
            fermata = fermata.copyWith(color: color);
            _homeController.updateStop(fermata);
          },
          availableColors: const [
            initialColor,
            Colors.red,
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.amber,
            Colors.cyan
          ],
          layoutBuilder: (context, colors, child) {
            return Flexible(
              child: SizedBox(
                width: Get.size.width * 0.8,
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  children: [for (Color color in colors) child(color)],
                ),
              ),
            );
          },
          itemBuilder: _pickerItemBuilder,
        ),
        textCancel: 'Make Default',
        textConfirm: 'Chiudi',
        onConfirm: () => Get.back(),
        onCancel: () {
          //print('setting new color');
          Storage.setParam(
              StorageParam.color, Storage.colorToString(fermata.color));
        });
  }

  Widget _pickerItemBuilder(
      Color color, bool isCurrentColor, void Function() changeColor) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: color.value == Storage.chosenColor.value
            ? Border.all(
                color: Utils.darken(color, 30),
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside)
            : null,
        borderRadius: BorderRadius.circular(50),
        color: color,
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.8),
              offset: const Offset(1, 2),
              blurRadius: 5)
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: changeColor,
          borderRadius: BorderRadius.circular(50),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: isCurrentColor ? 1 : 0,
            child: Icon(
              Icons.done,
              size: 24,
              color: useWhiteForeground(color) ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void _moveOnTop(FavStop fermata) {
    //_homeController.deleteStop(fermata);
    _homeController.moveOnTop(fermata);
    //_homeController.updateStop(fermata.copyWith(dateTime: DateTime.now()));
  }

  void _getDeleteConfirm(FavStop fermata) {
    Get.defaultDialog(
        title: "Elimina",
        middleText: "Vuoi eliminare la fermata ${fermata.code}?",
        textConfirm: "Elimina",
        textCancel: "Annulla",
        onConfirm: () {
          Get.back();
          _homeController.deleteStop(fermata);
        });
  }

  void _changeDescription(FavStop fermata) {
    _homeController.descriptionController.value.text =
        fermata.descrizione ?? '';
    Get.defaultDialog(
        title: "Elimina",
        content: Column(children: [
          const Text('Scrivi una breve descrizione'),
          Obx(
            () => TextField(
              maxLines: 2,
              controller: _homeController.descriptionController.value,
            ),
          ),
        ]),
        textConfirm: "Conferma",
        textCancel: "Annulla",
        onConfirm: () {
          Get.back();

          _homeController.updateStop(fermata.copyWith(
              descrizione: _homeController.descriptionController.value.text));
          //print(_homeController.descriptionController.value.text);
        });
  }

  Widget _getDrawer(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _homeController.scaffoldKey,
      endDrawer: _getDrawer(context),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Gtt Fermate"),
      ),
      body: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SearchPage(),
            if (_settingsController.isFavoritesRoutesShowing.value)
              GetBuilder<RouteListController>(
                  builder: (controller) => Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(
                            indent: 10,
                            endIndent: 10,
                          ),
                          SingleChildScrollView(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...controller.favorites
                                    .map((route) => RouteListFavorite(
                                          route: route,
                                          controller: controller,
                                          hasRemoveIcon: false,
                                        )),
                              ],
                            ),
                          ),
                          const Divider(
                            indent: 10,
                            endIndent: 10,
                          ),
                        ],
                      )),
            Expanded(
              child: GetBuilder<HomeController>(
                builder: (controller) {
                  return GridView.count(
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    padding: const EdgeInsets.all(20),
                    crossAxisCount: 2,
                    children: [
                      ...controller.fermate.map((fermata) => Column(
                            children: [
                              Hero(
                                tag: 'HeroTagFermata${fermata.code}',
                                flightShuttleBuilder: ((flightContext,
                                        animation,
                                        flightDirection,
                                        fromHeroContext,
                                        toHeroContext) =>
                                    Material(
                                      type: MaterialType.transparency,
                                      child: toHeroContext.widget,
                                    )),
                                child: InkWell(
                                  onTapDown: _homeController.getPosition,
                                  onLongPress: () => _showContextMenu(fermata),
                                  onTap: () => Get.to(
                                    () => InfoPage(),
                                    arguments: {'fermata': fermata},
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      color: Utils.lighten(fermata.color),
                                    ),
                                    height: 115,
                                    padding: const EdgeInsets.all(8),
                                    //color: Utils.lighten(e.color),
                                    child: Column(
                                      children: [
                                        Text(fermata.toString()),
                                        const Divider(),
                                        Text(fermata.descrizione ?? ''),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => Get.to(() => MapPointPage(),
                                    arguments: {'fermata': fermata}),
                                //MapUtils.openMap(e.latitude, e.longitude),
                                child: Ink(
                                  width: double.maxFinite,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(12),
                                    ),
                                    color: Utils.lighten(fermata.color, 70),
                                  ),
                                  child: const Center(child: Text('Posizione')),
                                ),
                              ),
                            ],
                          )),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              elevation: 2,
              heroTag: '___Menu',
              child: const Icon(Icons.menu),
              onPressed: () {
                _homeController.scaffoldKey.currentState?.openEndDrawer();
              },
            ),
            const SizedBox(
              height: 5,
            ),
            FloatingActionButton(
              elevation: 2,
              child: const Icon(Icons.search),
              onPressed: () {
                _searchController.searchButton();
              },
            ),
          ],
        ),
      ),
    );
  }
}
