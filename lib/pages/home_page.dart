import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_gtt/controllers/home_controller.dart';
import 'package:flutter_gtt/models/fermata.dart';
import 'package:flutter_gtt/pages/info_page.dart';
import 'package:flutter_gtt/pages/map/map_point_page.dart';
import 'package:flutter_gtt/pages/nfc/nfc_page.dart';
import 'package:flutter_gtt/resources/globals.dart';
import 'package:flutter_gtt/resources/storage.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final _homeController = Get.put(HomeController());
  void _onSubmitted() {
    final state = _homeController.key.currentState!;

    if (state.validate()) {
      _homeController.searchStop();
    }
  }

  void _showContextMenu(Fermata fermata) {
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

  void _changeColor(Fermata fermata) {
    Get.defaultDialog(
        title: 'Scegli un colore',
        // actions: [
        //   ElevatedButton(
        //     onPressed: () {},
        //     child: Text('Make Default'),
        //   ),
        // ],
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
                //height: 10.0 + (100 * (colors.length / 3).ceil()),
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
          print('setting new color');
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
        // shape: color.value == Storage.chosenColor.value
        //     ? CircleBorder(side: BorderSide(color: Colors.red, width: 5))
        //     : null,
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

  void _moveOnTop(Fermata fermata) {
    //_homeController.deleteStop(fermata);
    _homeController.updateStop(fermata.copyWith(dateTime: DateTime.now()));
  }

  void _getDeleteConfirm(Fermata fermata) {
    Get.defaultDialog(
        title: "Elimina",
        middleText: "Vuoi eliminare la fermata ${fermata.stopNum}?",
        textConfirm: "Elimina",
        textCancel: "Annulla",
        onConfirm: () {
          Get.back();
          _homeController.deleteStop(fermata);
        });
  }

  void _changeDescription(Fermata fermata) {
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

  Widget _getDrawer() {
    return Drawer(
      //backgroundColor: Colors.grey,
      width: Get.size.width * 0.6,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  SizedBox(
                    height: Get.size.height * 0.5,
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
                  ListTile(
                    title: const Text('Mappa Bus/Tram'),
                    onTap: () {
                      // open Bus list page
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Impostazioni'),
                    onTap: () {
                      // open Settings page??
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
      endDrawer: _getDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Gtt Fermate"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 18.0),
            child: Form(
              key: _homeController.key,
              autovalidateMode: AutovalidateMode.disabled,
              child: Obx(
                () => TextFormField(
                  controller: _homeController.searchController.value,
                  canRequestFocus: true,
                  focusNode: _homeController.focusNode.value,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: Divider.createBorderSide(context)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    filled: true,
                    labelText: 'Cerca numero fermata...',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Non puoi lasciare il campo vuoto";
                    }
                    if (!value.isNumericOnly) {
                      return "La fermata può essere solo un valore numerico";
                    }
                    if (value.length > 4) {
                      return "La fermata non esiste";
                    }
                    int num = int.parse(value);
                    if (num <= 0 && num >= 7000) {
                      // boh
                      return "La fermata non esiste";
                    }
                    return null;
                  },
                  onFieldSubmitted: (val) => _onSubmitted(),
                ),
              ),
            ),
          ),
          Expanded(
            child: GetBuilder<HomeController>(
              builder: (controller) {
                return GridView.count(
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  padding: const EdgeInsets.all(20),
                  crossAxisCount: 2,
                  children: [
                    ...controller.fermate.map((e) => Column(
                          children: [
                            Hero(
                              tag: 'HeroTagFermata${e.stopNum}',
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
                                onLongPress: () => _showContextMenu(e),
                                onTap: () => Get.to(() => InfoPage(),
                                    arguments: {'fermata': e}),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    color: Utils.lighten(e.color),
                                  ),
                                  height: 115,
                                  padding: const EdgeInsets.all(8),
                                  //color: Utils.lighten(e.color),
                                  child: Column(
                                    children: [
                                      Text(e.toString()),
                                      const Divider(),
                                      Text(e.descrizione ?? ''),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => Get.to(() => MapPointPage(),
                                  arguments: {'fermata': e}),
                              //MapUtils.openMap(e.latitude, e.longitude),
                              child: Ink(
                                width: double.maxFinite,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(12),
                                  ),
                                  color: Utils.lighten(e.color, 70),
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
                if (_homeController.focusNode.value.hasFocus) {
                  _onSubmitted();
                } else {
                  _homeController.focusNode.value.requestFocus();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
