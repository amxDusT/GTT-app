import 'package:get/get.dart';
import 'package:torino_mobility/bindings/home_bindings.dart';
import 'package:torino_mobility/bindings/map_global_bindings.dart';

class NavShellBindings extends Bindings {
  @override
  void dependencies() {
    HomeBindings().dependencies();
    MapGlobalBindings().dependencies();
  }
}
