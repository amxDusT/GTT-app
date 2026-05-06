import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/loading_controller.dart';
import 'package:get/get.dart';
import 'package:torino_mobility/l10n/localization_service.dart';

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
          Center(
            child: Text(
              l10n.appTitle,
              style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(l10n.loadingFirstDownload),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
