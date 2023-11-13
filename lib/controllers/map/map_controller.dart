import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gtt/models/fermata.dart';
import 'package:flutter_gtt/resources/api.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MapPageController extends GetxController
    with GetTickerProviderStateMixin {
  final double minZoom = 10;
  final double maxZoom = 18;
  final Vehicle _vehicle = Get.arguments['vehicle'];
  late final Rx<PatternDetails> patternDetails;
  MapController mapController = MapController();
  PopupController stopsPopupController = PopupController();
  PopupController vehiclesPopupController = PopupController();
  late MqttController _mqttController;
  final RxMap<int, MqttData> mqttData = <int, MqttData>{}.obs;
  final List<AnimationController> _activeAnimations = [];

  @override
  void onInit() async {
    patternDetails = PatternDetails.empty().copyWith(vehicle: _vehicle).obs;
    _vehicle.directionId;
    _mqttController = MqttController(_vehicle.shortName);
    super.onInit();
  }

  @override
  void onClose() {
    for (var element in _activeAnimations) {
      element.dispose();
    }
    _mqttController.dispose();
    mapController.dispose();
    stopsPopupController.dispose();
    vehiclesPopupController.dispose();
    super.onClose();
  }

  Future<void> getPatternDetails() async {
    patternDetails.value = await Api.getPatternDetails(_vehicle.patternCode);
  }

  void onMapReady() async {
    await getPatternDetails();
    _listenData();
    _centerBounds();
  }

  void _centerBounds() {
    final constrained = CameraFit.coordinates(
      coordinates: patternDetails.value.stopPoints,
      padding: const EdgeInsets.all(20.0),
    ).fit(mapController.camera);
    _animatedMapMove(constrained.center, constrained.zoom);
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = mapController.camera;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _activeAnimations.add(controller);
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _activeAnimations.remove(controller);
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _animatedMarkerMove(MqttData payload) {
    final latTween = Tween<double>(
        begin: mqttData[payload.vehicleNum]!.position.latitude,
        end: payload.position.latitude);
    final lngTween = Tween<double>(
        begin: mqttData[payload.vehicleNum]!.position.longitude,
        end: payload.position.longitude);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _activeAnimations.add(controller);
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    controller.addListener(() {
      final newLat = latTween.evaluate(animation);
      final newLng = lngTween.evaluate(animation);

      if (mqttData[payload.vehicleNum]!.position.latitude != newLat ||
          mqttData[payload.vehicleNum]!.position.longitude != newLng) {
        mqttData.update(
          payload.vehicleNum,
          (value) => payload.copyWith(position: LatLng(newLat, newLng)),
        );
      }
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _activeAnimations.remove(controller);
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _listenData() async {
    _mqttController.payloadStream.listen((MqttData payload) {
      print("${payload.vehicleNum} - ${payload.position.toString()}");
      if (_vehicle.directionId == payload.direction) {
        if (mqttData.containsKey(payload.vehicleNum)) {
          _animatedMarkerMove(payload);
        } else {
          mqttData.putIfAbsent(payload.vehicleNum, () => payload);
        }
      } else {
        print(
            "is in other direction: ${payload.vehicleNum} - ${payload.position.toString()}");
      }
    });
  }

  void zoomIn() => _zoomAnimation(true);

  void zoomOut() => _zoomAnimation(false);

  Future<void> _zoomAnimation(bool isZoomIn) async {
    final animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _activeAnimations.add(animController);
    final currentZoom = mapController.camera.zoom;
    double destZoom =
        clampDouble(currentZoom + (isZoomIn ? 1 : (-1)), minZoom, maxZoom);
    final zoomTween = Tween<double>(begin: currentZoom, end: destZoom);
    final Animation<double> animation =
        CurvedAnimation(parent: animController, curve: Curves.fastOutSlowIn);
    animController.addListener(() {
      mapController.move(
        mapController.camera.center,
        zoomTween.evaluate(animation),
      );
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _activeAnimations.remove(animController);
        animController.dispose();
      }
    });
    animController.forward();
  }
}
