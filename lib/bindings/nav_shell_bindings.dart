import 'package:get/get.dart';
import 'package:torino_mobility/bindings/home_bindings.dart';

class NavShellBindings extends Bindings {
  @override
  void dependencies() {
    HomeBindings().dependencies();
  }
}
