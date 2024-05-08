import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_gtt/models/gtt/favorite_stop.dart';
import 'package:flutter_gtt/models/gtt/stop.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:flutter_gtt/resources/globals.dart';
import 'package:flutter_gtt/resources/storage.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:flutter_gtt/widgets/home/color_picker.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  List<FavStop> fermate = [];
  late final Rx<TextEditingController> descriptionController;
  late Offset tapPosition;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  RelativeRect get relRectSize => RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        Get.size.width - tapPosition.dx,
        Get.size.height - tapPosition.dy,
      );

  void getPosition(TapDownDetails detail) {
    tapPosition = detail.globalPosition;
  }

  @override
  void onClose() {
    descriptionController.value.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    descriptionController = TextEditingController().obs;
    getStops();
  }

  void getStops() async {
    fermate = await DatabaseCommands.instance.favorites;
    update();
  }

  void moveOnTop(Stop stop) {
    DatabaseCommands.instance.updateStopWithSmallestDate(stop);
    getStops();
  }

  void updateStop(FavStop fermata) {
    DatabaseCommands.instance.updateStop(fermata);
    getStops();
  }

  void deleteStop(FavStop fermata) {
    DatabaseCommands.instance.deleteStop(fermata);
    getStops();
  }

  void updateFavorites() {
    var date = DateTime.now();

    fermate = fermate.map((fermata) {
      date = date.add(const Duration(seconds: 1));
      return fermata.copyWith(dateTime: date);
    }).toList();
    DatabaseCommands.instance.updateAllStops(fermate);
    update();
  }

  void switchAddDeleteFermata(Stop stop) async {
    if (fermate.contains(stop)) {
      DatabaseCommands.instance.deleteStop(stop);
      fermate.remove(stop);
    } else {
      DatabaseCommands.instance.insertStop(stop);
      if (stop is FavStop) {
        fermate.add(stop);
      } else {
        fermate.add(FavStop.fromStop(stop: stop));
      }
    }
    update();
  }

  void showContextMenu(FavStop fermata) {
    showMenu(
      //surfaceTintColor: Colors.red,
      context: Get.context!,
      position: relRectSize,
      items: [
        PopupMenuItem(
          child: const Text("Sposta in cima"),
          onTap: () => moveOnTop(fermata),
        ),
        PopupMenuItem(
          child: const Text("Cambia Descrizione"),
          onTap: () => _changeDescription(fermata),
        ),
        PopupMenuItem(
          child: const Text('Cambia Colore'),
          onTap: () => _changeColor(fermata),
        ),
        PopupMenuItem(
          child: const Text("Elimina"),
          onTap: () => _getDeleteConfirm(fermata),
        ),
      ],
    );
  }

  void _changeColor(FavStop fermata) {
    Color lastColor = fermata.color;
    Get.defaultDialog(
      title: 'Scegli un colore',
      content: BlockPicker(
        pickerColor: fermata.color,
        onColorChanged: (color) {
          fermata = fermata.copyWith(color: color);
          updateStop(fermata);
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
                children: [
                  for (Color color in colors) child(color),
                  Container(
                    margin: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      //border: Border.all(color: Utils.darken(lastColor)),
                      color: Utils.lighten(lastColor),
                      boxShadow: [
                        BoxShadow(
                          color: Utils.lighten(lastColor),
                          offset: const Offset(1, 2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          await Get.defaultDialog(
                              title: 'Scegli colore personalizzato',
                              textCancel: 'Annulla',
                              textConfirm: 'Conferma',
                              onConfirm: () {
                                fermata = fermata.copyWith(color: lastColor);
                                updateStop(fermata);
                                Get.back(closeOverlays: true);
                              },
                              content: ColorPicker(
                                pickerColor: lastColor,
                                onColorChanged: (color) {
                                  lastColor = color;
                                },
                              ));
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Icon(
                          Icons.add,
                          color: useWhiteForeground(Utils.lighten(lastColor))
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        itemBuilder: (color, isCurrentColor, changeColor) =>
            HomeColorPicker(color, isCurrentColor, changeColor),
      ),
      textCancel: 'Make Default',
      textConfirm: 'Chiudi',
      onConfirm: () => Get.back(),
      onCancel: () => Storage.instance.setColor(fermata.color),
    );
  }

  void _getDeleteConfirm(FavStop fermata) {
    Get.defaultDialog(
        title: "Elimina",
        middleText: "Vuoi eliminare la fermata ${fermata.toString()}?",
        textConfirm: "Elimina",
        textCancel: "Annulla",
        onConfirm: () {
          Get.back();
          deleteStop(fermata);
        });
  }

  void _changeDescription(FavStop fermata) {
    descriptionController.value.text = fermata.descrizione ?? '';
    Get.defaultDialog(
        title: "Elimina",
        content: Column(children: [
          const Text('Scrivi una breve descrizione'),
          Obx(
            () => TextField(
              maxLines: 2,
              controller: descriptionController.value,
            ),
          ),
        ]),
        textConfirm: "Conferma",
        textCancel: "Annulla",
        onConfirm: () {
          Get.back();

          updateStop(
              fermata.copyWith(descrizione: descriptionController.value.text));
        });
  }
}
