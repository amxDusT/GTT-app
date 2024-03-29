import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_gtt/pages/loading_page.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:flutter_gtt/resources/storage.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseCommands.init();
  Storage.loadSettings();

  //await DatabaseCommands.deleteTable();
  //await DatabaseCommands.createTable();
  runApp(const MyApp());
  await FlutterDisplayMode.setHighRefreshRate();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: const Locale('it'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      getPages: Utils.getPages(),
      supportedLocales: const [
        Locale('it', 'IT'),
        Locale('en', 'US'),
      ],
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      //initialRoute: ,
      home: LoadingPage(),

      //home: Testing(),
    );
  }
}
