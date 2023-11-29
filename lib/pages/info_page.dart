import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/info_controller.dart';
import 'package:flutter_gtt/models/gtt_models.dart';
import 'package:flutter_gtt/pages/map/map_page.dart';
import 'package:flutter_gtt/widgets/info_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class InfoPage extends StatelessWidget {
  InfoPage({super.key});

  final now = DateTime.now();
  final InfoController _infoController = Get.put(InfoController());
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'HeroTagFermata${_infoController.fermata.code}',
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Obx(
            () => Text(
              "Fermata ${_infoController.fermataName.value}",
            ),
          ),
          actions: [
            Obx(
              () => IconButton(
                onPressed: () {
                  _infoController.switchAddDeleteFermata();
                },
                icon: Icon(_infoController.isSaved.isTrue
                    ? Icons.star
                    : Icons.star_outline),
              ),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) => RefreshIndicator(
            onRefresh: () async => _infoController.getFermata(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              child: Obx(
                () => ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: _infoController.isLoading.isTrue
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : GetBuilder<InfoController>(
                          builder: (controller) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              itemCount: controller.fermata.vehicles.length + 2,
                              itemBuilder: (context, index) {
                                if (index ==
                                    controller.fermata.vehicles.length) {
                                  return Center(
                                    child: Text(
                                        "Ultimo aggiornamento: ${DateFormat.Hms(Get.locale?.languageCode).format(_infoController.lastUpdate.value)}"),
                                  );
                                } else if (index ==
                                    controller.fermata.vehicles.length + 1) {
                                  return ElevatedButton(
                                    onPressed: () =>
                                        Get.to(() => MapPage(), arguments: {
                                      'vehicles': controller.fermata.vehicles,
                                      'multiple-patterns': true,
                                      'fermata': controller.fermata,
                                    }),
                                    child: const Text('Guarda sulla mappa'),
                                  );
                                }
                                return InfoWidget(
                                    stop: controller.fermata,
                                    vehicle: (controller.fermata.vehicles[index]
                                        as RouteWithDetails));
                              },
                            );
                          },
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
