import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/info_controller.dart';
import 'package:flutter_gtt/fake/fake_data.dart';
import 'package:flutter_gtt/models/gtt/route.dart';
import 'package:flutter_gtt/models/gtt/stop.dart';
import 'package:flutter_gtt/resources/globals.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:flutter_gtt/widgets/info_widget.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class InfoPage extends StatelessWidget {
  final InfoController _infoController;
  final int stopCode = (Get.arguments['fermata'] as Stop).code;
  final now = DateTime.now();
  InfoPage({super.key})
      : _infoController =
            Get.find(tag: (Get.arguments['fermata'] as Stop).code.toString());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (_infoController.isSelecting.isTrue) {
          _infoController.switchSelecting();
        } else {
          Future.delayed(Duration.zero, () {
            if (!didPop) Get.back(closeOverlays: true);
          });
        }
      },
      child: Hero(
        tag: 'HeroTagFermata$stopCode',
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            scrolledUnderElevation: 0,
            title: Obx(
              () => Text(
                _infoController.isSelecting.isTrue
                    ? '${_infoController.selectedRoutes.length} / ${maxRoutesInMap > _infoController.fermata.value.vehicles.length ? _infoController.fermata.value.vehicles.length : maxRoutesInMap}  selezionate'
                    : _infoController.fermata.value.toString(),
              ),
            ),
            actions: [
              Obx(
                () => IconButton(
                  onPressed: () {
                    _infoController.switchSelecting();
                  },
                  icon: Icon(_infoController.isSelecting.isTrue
                      ? Icons.close
                      : Icons.select_all),
                  tooltip: _infoController.isSelecting.isTrue
                      ? 'Annulla'
                      : 'Seleziona linee',
                ),
              ),
              Obx(
                () => IconButton(
                  onPressed: () {
                    _infoController.switchAddDeleteFermata();
                  },
                  icon: Icon(_infoController.isSaved.isTrue
                      ? Icons.star
                      : Icons.star_outline),
                  tooltip: _infoController.isSaved.isTrue
                      ? 'Rimuovi dalla home'
                      : 'Salva in home',
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
                      () {
                        final routes = _infoController.isLoading.isTrue
                            ? List.filled(5, FakeData().fakeRouteWithDetails)
                            : _infoController.fermata.value.vehicles;
                        return ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraints.maxHeight),
                          child: Skeletonizer(
                            enabled: _infoController.isLoading.isTrue,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              itemCount: routes.length + 1,
                              itemBuilder: (context, index) {
                                if (index == routes.length) {
                                  return Skeleton.ignore(
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.only(
                                        top: 10,
                                        bottom: 60,
                                      ),
                                      child: Text(
                                        'Ultimo aggiornamento: ${Utils.dateToHourString(_infoController.lastUpdate.value)}',
                                      ),
                                    ),
                                  );
                                }
                                return InfoWidget(
                                  stop: _infoController.fermata.value,
                                  vehicle: (routes[index] as RouteWithDetails),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    child: Obx(
                      () {
                        if (!_infoController.canShowMap ||
                            _infoController.isLoading.isTrue) {
                          return const SizedBox();
                        }

                        return Opacity(
                          opacity: 0.9,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _infoController.isSelecting.isTrue
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                      : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              if (_infoController.isSelecting.isTrue &&
                                  _infoController.selectedRoutes.isEmpty) {
                                return;
                              }

                              Get.toNamed('/mapBus', arguments: {
                                'vehicles': _infoController.isSelecting.isTrue
                                    ? _infoController.selectedRoutes
                                    : _infoController.fermata.value.vehicles,
                                'multiple-patterns': true,
                                'fermata': _infoController.fermata.value,
                              });
                            },
                            child: const Text('Guarda sulla mappa'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
