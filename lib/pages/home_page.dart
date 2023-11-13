import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/home_controller.dart';
import 'package:flutter_gtt/models/fermata.dart';
import 'package:flutter_gtt/pages/info_page.dart';
import 'package:flutter_gtt/pages/nfc/nfc_page.dart';
import 'package:flutter_gtt/resources/utils/maps.dart';
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

  void showOverlay() {
    Get.showOverlay(
        asyncFunction: () => Future.error("error"),
        loadingWidget: const CircularProgressIndicator());
    // final context = Get.context!;
    // final child = Center(child: CircularProgressIndicator());
    // OverlayEntry entry = OverlayEntry(builder: (context) => child);
    // Overlay.of(context).insert(entry);
    // // remove the entry
    // Future.delayed(Duration(seconds: 2)).whenComplete(() => entry.remove());
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
        const PopupMenuItem(child: Text("Sposta in cima")),
      ],
    );
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
          fermata.descrizione =
              _homeController.descriptionController.value.text;
          _homeController.updateStop(fermata);
          //print(_homeController.descriptionController.value.text);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            InkWell(
                              onTapDown: _homeController.getPosition,
                              onLongPress: () => _showContextMenu(e),
                              onTap: () => Get.to(() => InfoPage(),
                                  arguments: {'fermata': e}),
                              child: Ink(
                                height: 115,
                                padding: const EdgeInsets.all(8),
                                color: Colors.teal[200],
                                child: Column(
                                  children: [
                                    Text(e.toString()),
                                    const Divider(),
                                    Text(e.descrizione ?? ''),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () =>
                                  MapUtils.openMap(e.latitude, e.longitude),
                              child: Ink(
                                width: double.maxFinite,
                                padding: const EdgeInsets.all(8),
                                color: Colors.teal[100],
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'NFC',
              child: const Icon(Icons.nfc),
              onPressed: () {
                Get.to(() => NfcPage());
              },
            ),
            FloatingActionButton(
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
