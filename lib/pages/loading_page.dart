import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/route_list_controller.dart';
import 'package:flutter_gtt/pages/home_page.dart';
import 'package:get/get.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool _isShowingMessage = false;

  @override
  void initState() {
    super.initState();

    checkAndLoad();
  }

  void checkAndLoad() async {
    final routeListController = Get.put(RouteListController());
    await routeListController.getAgencies();
    Duration duration = const Duration(milliseconds: 1000);
    if (routeListController.agencies.isEmpty) {
      setState(() {
        _isShowingMessage = true;
      });
      await routeListController.loadFromApi();
      duration = const Duration(milliseconds: 1);
    }
    await Future.delayed(duration);
    Get.off(() => HomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(flex: 2, child: Container()),
          const Center(
            child: Text(
              'GTT APP',
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: const LinearProgressIndicator(),
          ),
          Flexible(flex: 2, child: Container()),
          Visibility(
            visible: _isShowingMessage,
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('Scarico i dati GTT per la prima volta..'),
            ),
          )
        ],
      ),
    );
  }
}
