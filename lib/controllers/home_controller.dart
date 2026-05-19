import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:torino_mobility/l10n/localization_service.dart';
import 'package:torino_mobility/models/gtt/favorite_stop.dart';
import 'package:torino_mobility/models/gtt/route.dart' as gtt;
import 'package:torino_mobility/models/gtt/stop.dart';
import 'package:torino_mobility/resources/analytics.dart';
import 'package:torino_mobility/resources/database.dart';
import 'package:torino_mobility/resources/globals.dart';
import 'package:torino_mobility/resources/storage.dart';
import 'package:torino_mobility/resources/utils/color_utils.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/resources/utils/utils.dart';
import 'package:torino_mobility/widgets/home/color_picker.dart';
import 'package:get/get.dart';
import 'package:torino_mobility/widgets/map/menu_item.dart';

class HomeController extends GetxController {
  List<FavStop> fermate = [];
  Map<String, List<gtt.Route>> favoriteRoutes = {};
  late final Rx<TextEditingController> descriptionController;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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
    final List<dynamic> results = await Future.wait([
      DatabaseCommands.instance.favorites,
      DatabaseCommands.instance.routesForFavoriteStops,
    ]);

    fermate = results[0];
    favoriteRoutes = results[1];

    favoriteRoutes.forEach((key, routes) {
      Utils.sort(routes);
    });

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
    Analytics.instance.logEvent(
      name: 'delete_favorite_stop',
      parameters: {
        'stop_id': fermata.code,
      },
    );
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
      favoriteRoutes.remove(stop.gtfsId);
    } else {
      DatabaseCommands.instance.insertStop(stop);

      if (stop is FavStop) {
        fermate.add(stop);
      } else {
        Analytics.instance.logEvent(
          name: 'add_favorite_stop',
          parameters: {
            'stop_id': stop.code,
          },
        );
        fermate.add(FavStop.fromStop(stop: stop));
      }
      final routes = await DatabaseCommands.instance.getRouteFromStop(stop);
      favoriteRoutes[stop.gtfsId] = routes;
    }
    update();
  }

  void showContextMenu(FavStop fermata, GlobalKey anchorKey) {
    final BuildContext? anchorContext = anchorKey.currentContext;
    if (anchorContext == null) return;

    final RenderBox button = anchorContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(anchorContext).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(button.size.bottomLeft(Offset.zero),
            ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: anchorContext,
      position: position,
      color: const Color(0xff241e18).withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Colors.grey, width: .2)),
      items: [
        MenuItem(
            label: l10n.moveToTop,
            leadingIcon: Icons.arrow_upward,
            onTap: () => moveOnTop(fermata)),
        MenuItem(
            label: l10n.changeDescription,
            leadingIcon: Icons.edit,
            onTap: () => _changeDescription(anchorContext, fermata)),
        MenuItem(
            label: l10n.changeColor,
            leadingIcon: Icons.color_lens,
            onTap: () => _changeColor(fermata)),
        MenuDivider(),
        MenuItem(
            label: l10n.delete,
            leadingIcon: Icons.close,
            onTap: () => _getDeleteConfirm(fermata),
            dangerous: true),
      ],
    );
  }

  void _changeColor(FavStop fermata) {
    Color lastColor = fermata.color;
    Get.defaultDialog(
      title: l10n.chooseColorTitle,
      content: BlockPicker(
        pickerColor: fermata.color,
        onColorChanged: (color) {
          fermata = fermata.copyWith(color: color);
          updateStop(fermata);
        },
        availableColors: const [
          initialColor,
          ...ColorUtils.defaultColors,
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
                      color: Storage.instance.isDarkMode
                          ? Utils.darken(lastColor, 30)
                          : Utils.lighten(lastColor),
                      boxShadow: [
                        BoxShadow(
                          color: Storage.instance.isDarkMode
                              ? Utils.darken(lastColor, 30)
                              : Utils.lighten(lastColor),
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
                              title: l10n.chooseColorTitle,
                              textCancel: l10n.cancel,
                              textConfirm: l10n.confirm,
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
      textCancel: l10n.makeDefault,
      textConfirm: l10n.close,
      onConfirm: () => Get.back(),
      onCancel: () => Storage.instance.setColor(fermata.color),
    );
  }

  void _getDeleteConfirm(FavStop fermata) {
    Get.defaultDialog(
        title: l10n.delete,
        middleText: l10n.deleteStopQuestion(fermata.toString()),
        textConfirm: l10n.delete,
        textCancel: l10n.cancel,
        onConfirm: () {
          Get.back();
          deleteStop(fermata);
        });
  }

  void _changeDescription(BuildContext context, FavStop fermata) async {
    descriptionController.value.text = fermata.descrizione ?? '';
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xff241e18).withValues(alpha: .9),
            title: Text('DESCRIZIONE'.hc),
            content: TextField(
              controller: descriptionController.value,
              minLines: 1,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'ciao',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(l10n.cancel.capitalizeFirst!,
                    style: Fonts.title(
                        color: const Color(0xff6e6555),
                        fontWeight: FontWeight.w400,
                        height: .9)),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xfff3ede0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                onPressed: () {
                  Get.back();
                  updateStop(fermata.copyWith(
                      descrizione: descriptionController.value.text));
                },
                child:
                    Text(l10n.confirm.capitalizeFirst!, style: Fonts.title()),
              ),
            ],
          );
        });
  }
}
