import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gtt/resources/globals.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapAnimation {
  final Set<AnimationController> _activeAnimations = {};
  final MapController controller;
  final TickerProvider vsync;
  MapAnimation({required this.controller, required this.vsync});

  void animate(LatLng location, double zoom,
      [Duration duration = const Duration(milliseconds: 1000)]) {
    final camera = controller.camera;
    final latTween =
        Tween<double>(begin: camera.center.latitude, end: location.latitude);
    final lngTween =
        Tween<double>(begin: camera.center.longitude, end: location.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: zoom);

    final animationController =
        AnimationController(duration: duration, vsync: vsync);
    _activeAnimations.add(animationController);
    final Animation<double> animation = CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn);

    animationController.addListener(() {
      controller.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _activeAnimations.remove(animationController);
        animationController.dispose();
      }
    });

    animationController.forward();
  }

  void animateZoom({
    bool? isZoomIn,
    double? zoom,
    Duration duration = const Duration(milliseconds: 300),
  }) async {
    assert(isZoomIn != null || zoom != null);
    final animationController = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    _activeAnimations.add(animationController);
    final currentZoom = controller.camera.zoom;
    double destZoom = clampDouble(
        zoom ?? currentZoom - (isZoomIn! ? -1 : 1), mapMinZoom, mapMaxZoom);
    //double destZoom = clampDouble(
    //    currentZoom + (isZoomIn ? 1 : (-1)), mapMinZoom, mapMaxZoom);
    final zoomTween = Tween<double>(begin: currentZoom, end: destZoom);
    final Animation<double> animation = CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn);
    animationController.addListener(() {
      controller.move(
        controller.camera.center,
        zoomTween.evaluate(animation),
      );
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _activeAnimations.remove(animationController);
        animationController.dispose();
      }
    });
    animationController.forward();
  }

  void dispose() {
    for (final animation in _activeAnimations) {
      animation.dispose();
    }
  }
}
