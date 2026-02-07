import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:torino_mobility/firebase_options.dart';
import 'package:torino_mobility/l10n/app_localizations.dart';
import 'package:torino_mobility/l10n/localization_service.dart';
import 'package:torino_mobility/resources/analytics.dart';
import 'package:torino_mobility/resources/database.dart';
import 'package:torino_mobility/resources/globals.dart';
import 'package:torino_mobility/resources/storage.dart';
import 'package:torino_mobility/resources/utils/utils.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.instance.loadSettings();

  await DatabaseCommands.instance.initialize();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  initializeDateFormatting('it_IT');
  await FMTCObjectBoxBackend().initialise(
    maxDatabaseSize: 256000000,
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await const FMTCStore(tileCacheName).manage.create();
  runApp(const MyApp());
  await Analytics.instance.logAppOpen();
  await FlutterDisplayMode.setHighRefreshRate();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      //debugShowCheckedModeBanner: false,
      builder: (context, child) {
        Get.put(LocalizationService(context));
        return child!;
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      initialRoute: '/',
      getPages: Utils.getPages(),
      supportedLocales: AppLocalizations.supportedLocales,
      title: 'Torino Mobility',
      localeResolutionCallback: (locale, locales) {
        Locale? newLocale;
        if (locales
            .map((l) => l.languageCode)
            .any((code) => code == locale?.languageCode)) {
          newLocale = locales.firstWhere(
            (element) => element.languageCode == locale!.languageCode,
          );
        } else
          newLocale ??= const Locale('en');

        return newLocale;
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        //brightness: Brightness.dark,
      ),
      themeMode: Storage.instance.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
