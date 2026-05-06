import 'package:get/get.dart';
import 'package:torino_mobility/bindings/info_bindings.dart';
import 'package:torino_mobility/bindings/intro_bindings.dart';
import 'package:torino_mobility/bindings/loading_bindings.dart';
import 'package:torino_mobility/bindings/map_global_bindings.dart';
import 'package:torino_mobility/bindings/map_page_bindings.dart';
import 'package:torino_mobility/bindings/nav_shell_bindings.dart';
import 'package:torino_mobility/pages/info_page.dart';
import 'package:torino_mobility/pages/intro/intro_page.dart';
import 'package:torino_mobility/pages/loading_page.dart';
import 'package:torino_mobility/pages/map/map_global.dart';
import 'package:torino_mobility/pages/map/map_page.dart';
import 'package:torino_mobility/pages/nav_shell.dart';
import 'package:torino_mobility/pages/nfc/nfc_page.dart';
import 'package:torino_mobility/pages/route_list_page.dart';
import 'package:torino_mobility/pages/settings_page.dart';

class Router {
  static const String initialRoute = '/';
  static const String homeRoute = '/home';
  static const String mapRoute = '/map';
  static const String routeListRoute = '/routelist';
  static const String settingsRoute = '/settings';
  static const String nfcRoute = '/nfc';
  static const String infoRoute = '/info';
  static const String mapBusRoute = '/mapBus';
  static const String introRoute = '/intro';
  static get pages => [
        GetPage(
          name: initialRoute,
          page: () => LoadingPage(),
          binding: LoadingBindings(),
        ),
        GetPage(
          name: homeRoute,
          page: () => NavShell(),
          binding: NavShellBindings(),
        ),
        GetPage(
          name: mapRoute,
          page: () => MapGlobal(),
          binding: MapGlobalBindings(),
        ),
        GetPage(
          name: routeListRoute,
          page: () => RouteListPage(),
        ),
        GetPage(
          name: settingsRoute,
          page: () => SettingsPage(),
        ),
        GetPage(
          name: nfcRoute,
          page: () => NfcPage(),
        ),
        GetPage(
          name: infoRoute,
          page: () => InfoPage(),
          binding: InfoBindings(),
        ),
        GetPage(
          name: mapBusRoute,
          page: () => MapPage(),
          binding: MapPageBindings(),
        ),
        GetPage(
          name: introRoute,
          page: () => const IntroPage(),
          binding: IntroBindings(),
        ),
      ];
}
