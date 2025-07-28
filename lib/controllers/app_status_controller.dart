import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

enum SimpleLifecycleState {
  resumed,
  paused,
}

class AppStatusController extends GetxController with WidgetsBindingObserver {
  AppStatusController() {
    WidgetsBinding.instance.addObserver(this);
  }
  final StreamController<AppLifecycleState> _appLifecycleStateController =
      StreamController<AppLifecycleState>.broadcast();

  Stream<AppLifecycleState> get appLifecycleStateStream =>
      _appLifecycleStateController.stream;

  final StreamController<SimpleLifecycleState> _simpleLifecycleStateController =
      StreamController<SimpleLifecycleState>.broadcast();

  Stream<SimpleLifecycleState> get simpleLifecycleStateStream =>
      _simpleLifecycleStateController.stream;
  bool _paused = false;

  bool get paused => _paused;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_paused && state == AppLifecycleState.paused) {
      _paused = true;
      _simpleLifecycleStateController.add(SimpleLifecycleState.paused);
    } else if (_paused && state == AppLifecycleState.resumed) {
      _paused = false;
      _simpleLifecycleStateController.add(SimpleLifecycleState.resumed);
    }
    _appLifecycleStateController.add(state);
    super.didChangeAppLifecycleState(state);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _appLifecycleStateController.close();
    super.onClose();
  }
}
