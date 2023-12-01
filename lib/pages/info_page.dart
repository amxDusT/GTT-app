import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/info_controller.dart';
import 'package:flutter_gtt/models/gtt_models.dart';
import 'package:flutter_gtt/pages/map/map_page.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:flutter_gtt/widgets/info_widget.dart';
import 'package:get/get.dart';

class InfoPage extends StatelessWidget {
  final InfoController _infoController;
  InfoPage({super.key})
      : _infoController = Get.put(InfoController(), tag: key?.toString());

  final now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'HeroTagFermata${_infoController.fermata.value.code}',
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Obx(
            () => Text(
              "Fermata ${_infoController.fermata.value.name}",
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
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  child: Obx(
                    () => ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: _infoController.isLoading.isTrue
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              itemCount: _infoController
                                      .fermata.value.vehicles.length +
                                  1,
                              itemBuilder: (context, index) {
                                if (index ==
                                    _infoController
                                        .fermata.value.vehicles.length) {
                                  return Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 60),
                                    child: Text(
                                      'Ultimo aggiornamento: ${Utils.dateToHourString(_infoController.lastUpdate.value)}',
                                    ),
                                  );
                                }
                                return InfoWidget(
                                    stop: _infoController.fermata.value,
                                    vehicle: (_infoController.fermata.value
                                        .vehicles[index] as RouteWithDetails));
                              },
                            ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  child: Opacity(
                    opacity: 0.9,
                    child: ElevatedButton(
                      onPressed: () => Get.to(() => MapPage(), arguments: {
                        'vehicles': _infoController.fermata.value.vehicles,
                        'multiple-patterns': true,
                        'fermata': _infoController.fermata.value,
                      }),
                      child: const Text('Guarda sulla mappa'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
