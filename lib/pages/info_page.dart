import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';
import 'package:torino_mobility/controllers/info_controller.dart';
import 'package:torino_mobility/fake/fake_data.dart';
import 'package:torino_mobility/l10n/localization_service.dart';
import 'package:torino_mobility/models/gtt/route.dart';
import 'package:torino_mobility/models/gtt/stop.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/widgets/home/info_app_bar.dart';
import 'package:torino_mobility/widgets/info_widget.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:torino_mobility/resources/config/router.dart' as r;

class InfoPage extends StatelessWidget {
  final InfoController _infoController;
  final int stopCode = (Get.arguments['fermata'] as Stop).code;
  final now = DateTime.now();
  InfoPage({super.key})
      : _infoController =
            Get.find(tag: (Get.arguments['fermata'] as Stop).code.toString());

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (_infoController.isSelecting.isTrue)
          _infoController.switchSelecting();
        else if (!didPop) Get.back(closeOverlays: true);
      },
      child: Hero(
        tag: 'HeroTagFermata$stopCode',
        child: Scaffold(
          body: Stack(
            alignment: Alignment.topCenter,
            children: [
              RefreshIndicator(
                onRefresh: () async => _infoController.getFermata(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    StopSliverAppBar(
                      controller: _infoController,
                      stopCode: stopCode,
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 12)
                          .copyWith(bottom: 0),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'PROSSIMI PASSAGGI'.hc,
                          style: Fonts.subtitle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                            color: t.inkMute,
                          ),
                        ),
                      ),
                    ),
                    Obx(() {
                      final isLoading = _infoController.isLoading.isTrue;

                      final routes = isLoading
                          ? List.filled(5, FakeData().fakeRouteWithDetails)
                          : _infoController.fermata.value.vehicles;
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8)
                            .copyWith(top: 0),
                        sliver: Skeletonizer.sliver(
                          enabled: isLoading,
                          child: SliverList.builder(
                            itemCount: routes.length,
                            itemBuilder: (context, index) => InfoWidget(
                              stop: _infoController.fermata.value,
                              vehicle: routes[index] as RouteWithDetails,
                            ),
                          ),
                        ),
                      );
                    }),
                    Obx(
                      () {
                        final buttonHidden = !_infoController.canShowMap ||
                            _infoController.isLoading.isTrue ||
                            _infoController.selectedRoutes.isEmpty;
                        return SliverToBoxAdapter(
                          child: SizedBox(height: buttonHidden ? 10 : 100),
                        );
                      },
                    )
                  ],
                ),
              ),
              Obx(() {
                final buttonHidden = !_infoController.canShowMap ||
                    _infoController.isLoading.isTrue ||
                    _infoController.selectedRoutes.isEmpty;
                return AnimatedPositioned(
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 200),
                  bottom: buttonHidden ? 0 : 50,
                  left: 12,
                  right: 12,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: buttonHidden ? 0 : 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: t.accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        iconColor: t.bg,
                        fixedSize: const Size.fromHeight(50),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: () {
                        if (_infoController.isSelecting.isTrue &&
                            _infoController.selectedRoutes.isEmpty) {
                          return;
                        }

                        Get.toNamed(r.Router.mapBusRoute, arguments: {
                          'vehicles': _infoController.isSelecting.isTrue
                              ? _infoController.selectedRoutes
                              : _infoController.fermata.value.vehicles,
                          'multiple-patterns': true,
                          'fermata': _infoController.fermata.value,
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 8,
                        children: [
                          const Icon(Icons.map_outlined),
                          Expanded(
                            child: Text(
                              l10n.viewOnMap,
                              style: Fonts.title(
                                  fontSize: 16,
                                  color: t.bg,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: t.accent,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              '${_infoController.selectedRoutes.length} linee'
                                  .hc,
                              style: Fonts.subtitle(
                                  fontSize: 12,
                                  color: t.bg,
                                  fontWeight: FontWeight.w600),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
