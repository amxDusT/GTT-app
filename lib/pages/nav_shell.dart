import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torino_mobility/controllers/nav_shell_controller.dart';
import 'package:torino_mobility/pages/home_page.dart';
import 'package:torino_mobility/pages/nfc/nfc_page.dart';
import 'package:torino_mobility/pages/route_list_page.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/widgets/floating_nav_pill.dart';

class NavShell extends StatelessWidget {
  NavShell({super.key});

  final _controller = Get.put(NavShellController());
  static const homeIndex = 0;
  static const routeListIndex = 1;
  static const nfcIndex = 2;

  static void goTo(int index) {
    Get.find<NavShellController>().changeIndex(index);
  }

  static final _items = [
    NavPillItem(icon: Icons.home_outlined, label: 'Home'.hc),
    NavPillItem(icon: Icons.directions_bus_outlined, label: 'Linee'.hc),
    NavPillItem(icon: Icons.nfc_outlined, label: 'NFC'.hc),
  ];

  static final _pages = <Widget>[
    HomePage(),
    const RouteListPage(),
    const NfcPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = List<Widget>.generate(_pages.length, (i) => _pages[i]);
    return Scaffold(
      body: Obx(() {
        return NavBackInterceptor(
          overrideBack: _controller.currentIndex.value != homeIndex,
          child: Stack(
            children: [
              IndexedStack(
                index: _controller.currentIndex.value,
                children: pages,
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: SafeArea(
                  child: Center(
                    child: FloatingNavPill(
                      items: _items,
                      currentIndex: _controller.currentIndex.value,
                      onChanged: _controller.changeIndex,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class NavBackInterceptor extends StatelessWidget {
  const NavBackInterceptor({
    this.overrideBack = true,
    required this.child,
    super.key,
  });
  final bool overrideBack;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !overrideBack,
      onPopInvokedWithResult: (bool didPop, _) {
        if (!didPop) NavShell.goTo(NavShell.homeIndex);
      },
      child: child,
    );
  }
}
