import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/loading_controller.dart';
import 'package:get/get.dart';

class LoadingPage extends StatelessWidget {
  LoadingPage({super.key});
  final LoadingController _loadingController = Get.put(LoadingController());
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
            width: MediaQuery.sizeOf(context).width * 0.7,
            child: const LinearProgressIndicator(),
          ),
          Flexible(flex: 2, child: Container()),
          Obx(
            () => Visibility(
              visible: _loadingController.isShowingMessage.isTrue,
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Scarico i dati GTT per la prima volta..'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
