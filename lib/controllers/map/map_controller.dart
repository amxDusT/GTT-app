import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:torino_mobility/controllers/app_status_controller.dart';
import 'package:torino_mobility/controllers/map/map_animation.dart';
import 'package:torino_mobility/controllers/map/map_location.dart';
import 'package:torino_mobility/exceptions/map_location_exception.dart';
import 'package:torino_mobility/models/gtt/pattern.dart' as gtt;
import 'package:torino_mobility/models/gtt/stop.dart';
import 'package:torino_mobility/models/marker.dart';
import 'package:torino_mobility/models/mqtt_data.dart';
import 'package:torino_mobility/models/gtt/route.dart' as gtt;
import 'package:torino_mobility/resources/analytics.dart';
import 'package:torino_mobility/resources/api/gtt_api.dart';
import 'package:torino_mobility/resources/api/mqtt_controller.dart';
import 'package:torino_mobility/resources/database.dart';
import 'package:torino_mobility/resources/globals.dart';
import 'package:torino_mobility/resources/storage.dart';
import 'package:torino_mobility/resources/utils/map_utils.dart';
import 'package:torino_mobility/resources/utils/utils.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:torino_mobility/l10n/localization_service.dart';

class MapPageController extends GetxController
    with GetTickerProviderStateMixin {
  static const double minZoom = 12;
  static const double maxZoom = 18;
  static const List colors = [
    Colors.blue,
    Colors.pinkAccent,
    Colors.brown,
    Colors.deepPurple,
    Colors.tealAccent,
    Colors.deepOrange,
  ];
  MapController mapController = MapController();
  PopupController popupController = PopupController();
  late MapAnimation _mapAnimation;
  late AppStatusController _appStatusController;
  // used for deleting animations that are not finished yet when closing the page
  final List<AnimationController> _activeAnimations = [];

  late RxList<FermataMarker> allStops;
  RxMap<int, Stop> stopsMap = <int, Stop>{}.obs;
  final RxMap<int, VehicleMarker> allVehicles = <int, VehicleMarker>{}.obs;
  final RxMap<String, gtt.RouteWithDetails> routes =
      <String, gtt.RouteWithDetails>{}.obs;

  final Map<String, int> routeIndex = {};

  /// Patterns fetched per route, populated lazily via [loadPatternsFor].
  final RxMap<String, RxList<gtt.Pattern>> patternsByRoute =
      <String, RxList<gtt.Pattern>>{}.obs;

  /// All stops for each pattern, keyed by pattern code. Populated alongside
  /// [patternsByRoute] in [loadPatternsFor] — we already fetch the stop
  /// list there to derive [firstStop], so we cache the full list too.
  final RxMap<String, RxList<Stop>> stopsByPattern =
      <String, RxList<Stop>>{}.obs;

  /// Which stop codes belong to each route's current pattern. Used to
  /// know which stops to remove when a route or pattern is swapped.
  final Map<String, Set<int>> _stopCodesByRoute = {};

  /// Patterns for the single-route case (kept as a getter for the
  /// existing dropdown in [RouteAppBarInfo]). Empty when there is more
  /// than one route on the map.
  List<gtt.Pattern> get routePatterns {
    if (routes.length != 1) return const [];
    return patternsByRoute[routes.keys.first] ?? const [];
  }

  //live bus
  final MqttController _mqttController = MqttController();

  final RxMap<String, RxMap<int, MqttVehicle>> mqttInformation =
      <String, RxMap<int, MqttVehicle>>{}.obs;

  Marker? lastOpenedMarker;
  late Timer _timer;
  final MapLocation userLocation = Get.find();
  final RxBool isLocationLoading = false.obs;

  final RxBool isPatternInitialized = false.obs;
  // for single route, for showing the direction
  final Map<String, Stop> firstStop = {};

  // save last view
  late MapCamera lastView;

  // map event related
  double lastZoom = 0.0;

  /// Current integer zoom level. Polyline offsets are recomputed only when
  /// this changes (i.e. when crossing a zoom-level boundary), keeping the
  /// on-screen gap between parallel routes roughly constant in pixels without
  /// paying a recompute on every fractional zoom step. Reactive so the
  /// polyline/arrow layers rebuild on a level crossing.
  final RxInt zoomLevel = 0.obs;

  // follow vehicle
  final RxInt followVehicle = 0.obs; // <= 0 = not following

  RxList<VehicleMarker> get allVehiclesInDirection => allVehicles.values
      .where(
        (vehicle) =>
            vehicle.mqttData.direction ==
            routes[vehicle.mqttData.gtfsId]?.pattern.directionId,
      )
      .toList()
      .obs;
  late final Route<dynamic>? currentRoute;

  double get offsetPx {
    switch (routes.length) {
      case 1:
        return 0;
      case 2:
        return 8;
      case 3:
        return 7;
      default:
        return 6;
    }
  }

  double _pixelsToDegrees(double px, int zoom, double lat) {
    final worldSize = 256 * math.pow(2, zoom);
    return px * 360 * math.cos(lat * math.pi / 180) / worldSize;
  }

  final Map<String, List<LatLng>> _offsetPolylineCache = {};

  void _clearOffsetCache() => _offsetPolylineCache.clear();

  List<LatLng> offsetPolylineFor(gtt.RouteWithDetails route, int index) {
    final n = routes.length;
    if (n <= 1 || offsetPx == 0) return route.pattern.polylinePoints;

    final zoom = zoomLevel.value;
    final lat = mapController.camera.center.latitude;
    final spacing = _pixelsToDegrees(offsetPx, zoom, lat);
    final offset = (index - (n - 1) / 2) * spacing;
    if (offset == 0) return route.pattern.polylinePoints;

    final key = '${route.gtfsId}:${route.pattern.code}:$index:$n:$zoom';
    return _offsetPolylineCache[key] ??=
        MapUtils.polylineOffset(route.pattern.polylinePoints, offset);
  }

  Color polylineColorFor(gtt.RouteWithDetails route) {
    if (routes.length == 1) return Colors.red;
    return Utils.lighten(
      colors[(routeIndex[route.gtfsId] ?? 0) % colors.length],
      20,
    );
  }

  Color stopBorderColor(int stopCode) {
    for (final entry in _stopCodesByRoute.entries) {
      if (entry.value.contains(stopCode)) {
        final route = routes[entry.key];
        if (route != null) return polylineColorFor(route);
      }
    }
    return FermataMarker.defaultColor;
  }

  /// isCap
  bool isTerminalStop(int stopCode) {
    for (final route in routes.values) {
      final stops = stopsByPattern[route.pattern.code];
      if (stops == null || stops.isEmpty) continue;
      if (stops.first.code == stopCode || stops.last.code == stopCode) {
        return true;
      }
    }
    return false;
  }

  void _refreshStopMarkers() {
    if (allStops.isEmpty) return;
    allStops.value = allStops.map((m) {
      final highlighted = m.color == Colors.green;
      return m.copyWith(
        color: highlighted ? Colors.green : stopBorderColor(m.fermata.code),
        isTerminal: isTerminalStop(m.fermata.code),
      );
    }).toList();
    allStops.refresh();
  }

  @override
  void onClose() async {
    for (var element in _activeAnimations) {
      element.dispose();
    }
    _timer.cancel();
    await _mqttController.dispose();
    _mapAnimation.dispose();
    mapController.dispose();
    popupController.dispose();
    userLocation.onMapDispose();

    super.onClose();
  }

  void _removeOldVehicles() {
    allVehicles.removeWhere((key, vehicle) {
      if (vehicle.mqttData.lastUpdate
          .isBefore(DateTime.now().subtract(const Duration(minutes: 2)))) {
        if (followVehicle.value != 0 &&
            vehicle.mqttData.vehicleNum == followVehicle.value) {
          stopFollowingVehicle();
          Utils.showSnackBar(l10n.followedVehicleRemoved);
        }
        if (lastOpenedMarker != null &&
            lastOpenedMarker is VehicleMarker &&
            (lastOpenedMarker as VehicleMarker).mqttData.vehicleNum ==
                vehicle.mqttData.vehicleNum) {
          popupController.hideAllPopups();
        }
        return true;
      }
      return false;
    });
  }

  void onMapEvent(MapEvent mapEvent) {
    if (lastZoom != mapEvent.camera.zoom && isPatternInitialized.isTrue) {
      lastZoom = mapEvent.camera.zoom;

      zoomLevel.value = mapEvent.camera.zoom.round();

      List<FermataMarker> list = allStops
          .map((marker) => marker.copyWith(zoom: mapEvent.camera.zoom))
          .toList();
      allStops.value = list;
      allStops.refresh();
    }
  }

  @override
  void onInit() {
    super.onInit();
    currentRoute = Get.rawRoute;
    _mapAnimation = MapAnimation(controller: mapController, vsync: this);
    _appStatusController = Get.find<AppStatusController>();

    _appStatusController.simpleLifecycleStateStream.listen((state) {
      if (state == SimpleLifecycleState.paused && _mqttController.connected) {
        _mqttController.disconnect();
      } else if (state == SimpleLifecycleState.resumed) {
        if (!_mqttController.connected) {
          _mqttController.connect();
        }
      }
    });
    _onMapReady();
  }

  void _onMapReady() async {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _removeOldVehicles();
    });
    //_mqttController = MqttController();
    List<gtt.Route> routeValues = Get.arguments['vehicles'];
    final Stop? initialStop = Get.arguments['fermata'];

    final bool showMultiplePatterns =
        Get.arguments['multiple-patterns'] ?? false;
    final bool isOneRoute = routeValues.length == 1;
    Analytics.instance.logEvent(name: 'open_map_page', parameters: {
      'number_of_routes': routeValues.length,
      'routes': routeValues.map((e) => e.shortName).join(','),
    });
    // if opened from bus list
    if (isOneRoute) {
      if (showMultiplePatterns || routeValues.first is gtt.RouteWithDetails) {
        isAppBarExpanded.value = false;
      }
      final loaded =
          await DatabaseCommands.instance.getPatterns(routeValues.first);
      for (var pattern in loaded) {
        final patternStops =
            await DatabaseCommands.instance.getStopsFromPattern(pattern);
        stopsByPattern[pattern.code] = patternStops.obs;
        if (patternStops.isNotEmpty) {
          firstStop.putIfAbsent(pattern.code, () => patternStops.first);
        }
      }
      patternsByRoute[routeValues.first.gtfsId] = loaded.obs;

      if (routeValues.first is! gtt.RouteWithDetails) {
        routeValues = [
          gtt.RouteWithDetails.fromData(
              route: routeValues.first, stoptimes: [], pattern: loaded.first)
        ];
      }
    }

    int routeCount = 0; // limit to 'maxRoutesInMap' routes
    stopsMap = <int, Stop>{}.obs;
    for (gtt.Route route in routeValues) {
      if (showMultiplePatterns &&
          !Storage.instance.isRouteWithoutPassagesShowing &&
          (route as gtt.RouteWithDetails).stoptimes.isEmpty) continue;

      _mqttController.addSubscription((route as gtt.RouteWithDetails).gtfsId);
      var tempStops =
          await DatabaseCommands.instance.getStopsFromPattern(route.pattern);

      if (tempStops.isEmpty) {
        tempStops = await GttApi.getStopsFromPattern(route.pattern);
      }
      _stopCodesByRoute[route.gtfsId] = tempStops.map((s) => s.code).toSet();
      for (final stop in tempStops) {
        stopsMap.putIfAbsent(stop.code, () => stop);
      }
      stopsByPattern.putIfAbsent(route.pattern.code, () => tempStops.obs);
      if (tempStops.isNotEmpty) {
        firstStop.putIfAbsent(route.pattern.code, () => tempStops.first);
      }

      routes.putIfAbsent(route.gtfsId, () => route);
      routeIndex.putIfAbsent(route.gtfsId, () => routeIndex.length);

      if (++routeCount >= maxRoutesInMap) break;
    }
    allStops = stopsMap.values
        .map((stop) => FermataMarker(
              fermata: stop,
              color: stopBorderColor(stop.code),
              isTerminal: isTerminalStop(stop.code),
            ))
        .toList()
        .obs;

    _mqttController.connect();
    if (initialStop != null) {
      if (Storage.instance.isFermataShowing)
        popupController.togglePopup(FermataMarker(fermata: initialStop));
      if (Storage.instance.isInitialHighlighted)
        setHighlightedStop(initialStop.code, false);
    }

    for (final route in routes.values) {
      final highlightedStops = MapUtils.getSignedStops(route.gtfsId);
      for (final stop in highlightedStops) {
        if (Storage.instance.isFermataShowing &&
            initialStop != null &&
            stop == initialStop.code) continue;
        final isHighlighted = isStopHighlighted(stopCode: stop);
        if (!isHighlighted) setHighlightedStop(stop, false);
      }
    }

    isPatternInitialized.value = true;
    _listenData();
    await Future.delayed(const Duration(milliseconds: 250));
    lastView = _getCenterBounds();
    centerBounds();
  }

  void onMapReady() async {
    zoomLevel.value = mapController.camera.zoom.round();
    if (routes.values.isNotEmpty) {
      lastView = _getCenterBounds();
      centerBounds();
    }
  }

  void centerBounds() {
    final constrained = _getCenterBounds();

    if (nearEqual(constrained.zoom, mapController.camera.zoom, 0.0001) &&
        nearEqual(constrained.center.latitude,
            mapController.camera.center.latitude, 0.0001) &&
        nearEqual(constrained.center.longitude,
            mapController.camera.center.longitude, 0.0001)) {
      _mapAnimation.animate(lastView.center, zoom: lastView.zoom);
    } else {
      lastView = mapController.camera;

      _mapAnimation.animate(constrained.center, zoom: constrained.zoom);
    }
  }

  MapCamera _getCenterBounds() {
    final points = <LatLng>[
      for (final route in routes.values) ...route.pattern.polylinePoints,
    ];
    if (points.isEmpty) return mapController.camera;
    return CameraFit.coordinates(
      coordinates: points,
      padding: const EdgeInsets.all(20.0),
    ).fit(mapController.camera);
  }

  void _animatedMarkerMove(MqttVehicle payload) {
    final latTween = Tween<double>(
        begin: allVehicles[payload.vehicleNum]!.mqttData.position.latitude,
        end: payload.position.latitude);
    final lngTween = Tween<double>(
        begin: allVehicles[payload.vehicleNum]!.mqttData.position.longitude,
        end: payload.position.longitude);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _activeAnimations.add(controller);
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    controller.addListener(() {
      final newLat = latTween.evaluate(animation);
      final newLng = lngTween.evaluate(animation);

      if (allVehicles[payload.vehicleNum]!.mqttData.position.latitude !=
              newLat ||
          allVehicles[payload.vehicleNum]!.mqttData.position.longitude !=
              newLng) {
        allVehicles.update(
          payload.vehicleNum,
          (value) => allVehicles[payload.vehicleNum]!.copyWith(
            mqttData: allVehicles[payload.vehicleNum]!.mqttData.copyWith(
                  position: LatLng(newLat, newLng),
                  rotation: payload.rotation,
                  speed: payload.speed,
                  tripId: payload.tripId,
                  direction: payload.direction,
                  isFull: payload.isFull,
                  nextStop: payload.nextStop,
                  lastUpdate: payload.lastUpdate,
                ),
          ),
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

    // popup following marker
    VehicleMarker oldMarker = allVehicles[payload.vehicleNum]!;
    if (lastOpenedMarker != null &&
        lastOpenedMarker is VehicleMarker &&
        (lastOpenedMarker as VehicleMarker).mqttData.vehicleNum ==
            oldMarker.mqttData.vehicleNum) {
      lastOpenedMarker = oldMarker.copyWith(mqttData: payload);
      popupController.showPopupsOnlyFor([lastOpenedMarker!]);
    }
    //follow vehicle
    if (followVehicle.value == payload.vehicleNum) {
      _mapAnimation.animate(payload.position, zoom: mapController.camera.zoom);
    }
    controller.forward();
  }

  void _listenData() async {
    _mqttController.payloadStream.listen((MqttVehicle payload) {
      if (allVehicles.containsKey(payload.vehicleNum)) {
        _animatedMarkerMove(payload);
      } else {
        allVehicles.putIfAbsent(
          payload.vehicleNum,
          () => VehicleMarker(
            mqttData: payload,
            color: routes.length == 1
                ? null
                : Utils.darken(
                    colors[(routeIndex[payload.gtfsId] ?? 0) % colors.length],
                    30),
            internalColor: routes[payload.gtfsId]?.type == 0 &&
                    !MapUtils.isTram(payload.vehicleNum)
                ? Colors.white
                : null,
          ),
        );
      }
      //}
    });
  }

  void zoomIn() => _mapAnimation.animateZoom(isZoomIn: true);

  void zoomOut() => _mapAnimation.animateZoom(isZoomIn: false);

  void panMapByPixels(
    double dx,
    double dy, {
    Duration duration = const Duration(milliseconds: 350),
  }) {
    if (dx.abs() < 1 && dy.abs() < 1) return;
    final camera = mapController.camera;
    final centerPoint = camera.latLngToScreenPoint(camera.center);
    final newCenter = camera.pointToLatLng(
      math.Point(centerPoint.x - dx, centerPoint.y - dy),
    );
    _mapAnimation.animate(newCenter, zoom: camera.zoom, duration: duration);
  }

  void centerMarkerBiasedDown(LatLng point, {double biasY = 0.7}) {
    final camera = mapController.camera;
    final size = camera.nonRotatedSize;
    final markerScreen = camera.latLngToScreenPoint(point);
    panMapByPixels(
      size.x / 2 - markerScreen.x,
      size.y * biasY - markerScreen.y,
      duration: const Duration(milliseconds: 500),
    );
  }

  void setCurrentPattern(String gtfsId, gtt.Pattern newPattern) async {
    final route = routes[gtfsId];
    if (route == null || route.pattern == newPattern) return;

    // If we were following a vehicle from this route, stop — the new
    // pattern may not contain it.
    final followed = allVehicles[followVehicle.value];
    if (followed != null && followed.mqttData.gtfsId == gtfsId) {
      stopFollowingVehicle();
    }

    var newStops =
        await DatabaseCommands.instance.getStopsFromPattern(newPattern);
    if (newStops.isEmpty) {
      newStops = await GttApi.getStopsFromPattern(newPattern);
    }

    stopsByPattern.putIfAbsent(newPattern.code, () => newStops.obs);
    if (newStops.isNotEmpty) {
      firstStop.putIfAbsent(newPattern.code, () => newStops.first);
    }

    final oldCodes = _stopCodesByRoute[gtfsId] ?? <int>{};
    final newCodes = newStops.map((s) => s.code).toSet();
    _stopCodesByRoute[gtfsId] = newCodes;

    // Stops that no remaining route's current pattern still uses.
    final stillUsed = <int>{};
    for (final codes in _stopCodesByRoute.values) {
      stillUsed.addAll(codes);
    }
    final toRemove = oldCodes.difference(stillUsed);
    if (toRemove.isNotEmpty) {
      allStops.removeWhere((m) => toRemove.contains(m.fermata.code));
      for (final code in toRemove) {
        stopsMap.remove(code);
      }
    }

    // Add stops that weren't on the map yet.
    final currentZoom = mapController.camera.zoom;
    for (final stop in newStops) {
      if (!stopsMap.containsKey(stop.code)) {
        stopsMap[stop.code] = stop;
        allStops.add(FermataMarker(
            fermata: stop,
            zoom: currentZoom,
            color: stopBorderColor(stop.code),
            isTerminal: isTerminalStop(stop.code)));
      }
    }

    routes[gtfsId] = route.copyWith(pattern: newPattern);
    _clearOffsetCache();
    _refreshStopMarkers();
    popupController.hideAllPopups();
    lastOpenedMarker = null;

    final highlightedStops = MapUtils.getSignedStops(gtfsId);
    for (final stopCode in highlightedStops) {
      if (!isStopHighlighted(stopCode: stopCode)) {
        setHighlightedStop(stopCode, false);
      }
    }

    centerBounds();
  }

  Future<List<gtt.Pattern>> loadPatternsFor(String gtfsId) async {
    final route = routes[gtfsId];
    if (route == null) return const [];

    // Ensure pattern list is cached.
    List<gtt.Pattern> loaded;
    final cached = patternsByRoute[gtfsId];
    if (cached != null) {
      loaded = cached;
    } else {
      loaded = await DatabaseCommands.instance.getPatterns(route);
      patternsByRoute[gtfsId] = loaded.obs;
    }

    for (final pattern in loaded) {
      if (stopsByPattern.containsKey(pattern.code)) continue;
      final stops =
          await DatabaseCommands.instance.getStopsFromPattern(pattern);
      stopsByPattern[pattern.code] = stops.obs;
      if (stops.isNotEmpty) {
        firstStop.putIfAbsent(pattern.code, () => stops.first);
      }
    }
    return loaded;
  }

  Future<void> addRoute(gtt.Route route) async {
    if (routes.containsKey(route.gtfsId)) return;
    if (routes.length >= maxRoutesInMap) {
      Utils.showSnackBar(l10n.selectMaxVehicles(maxRoutesInMap));
      return;
    }

    gtt.Pattern pattern;
    if (route is gtt.RouteWithDetails) {
      pattern = route.pattern;
    } else {
      final fetched = await DatabaseCommands.instance.getPatterns(route);
      if (fetched.isEmpty) return;
      pattern = fetched.first;
      patternsByRoute[route.gtfsId] = fetched.obs;
    }

    final routeWithDetails = route is gtt.RouteWithDetails
        ? route
        : gtt.RouteWithDetails.fromData(
            route: route, stoptimes: const [], pattern: pattern);

    var stops = await DatabaseCommands.instance.getStopsFromPattern(pattern);
    if (stops.isEmpty) {
      stops = await GttApi.getStopsFromPattern(pattern);
    }

    stopsByPattern.putIfAbsent(pattern.code, () => stops.obs);
    if (stops.isNotEmpty) {
      firstStop.putIfAbsent(pattern.code, () => stops.first);
    }

    routes[routeWithDetails.gtfsId] = routeWithDetails;
    _clearOffsetCache();
    routeIndex.putIfAbsent(routeWithDetails.gtfsId, () => routeIndex.length);
    _stopCodesByRoute[routeWithDetails.gtfsId] =
        stops.map((s) => s.code).toSet();

    final currentZoom = mapController.camera.zoom;
    for (final stop in stops) {
      if (!stopsMap.containsKey(stop.code)) {
        stopsMap[stop.code] = stop;
        allStops.add(FermataMarker(
            fermata: stop,
            zoom: currentZoom,
            color: stopBorderColor(stop.code),
            isTerminal: isTerminalStop(stop.code)));
      }
    }
    _refreshStopMarkers();

    _mqttController.addSubscription(routeWithDetails.gtfsId);

    final highlightedStops = MapUtils.getSignedStops(routeWithDetails.gtfsId);
    for (final stopCode in highlightedStops) {
      if (!isStopHighlighted(stopCode: stopCode)) {
        setHighlightedStop(stopCode, false);
      }
    }

    centerBounds();
  }

  void removeRoute(String gtfsId) {
    if (routes.length <= 1) return;
    if (!routes.containsKey(gtfsId)) return;

    _mqttController.removeSubscription(gtfsId);

    final removedVehicleNums = <int>{};
    allVehicles.removeWhere((key, vehicle) {
      if (vehicle.mqttData.gtfsId == gtfsId) {
        removedVehicleNums.add(vehicle.mqttData.vehicleNum);
        return true;
      }
      return false;
    });

    if (followVehicle.value != 0 &&
        removedVehicleNums.contains(followVehicle.value)) {
      stopFollowingVehicle();
    }

    if (lastOpenedMarker is VehicleMarker &&
        removedVehicleNums.contains(
            (lastOpenedMarker as VehicleMarker).mqttData.vehicleNum)) {
      popupController.hideAllPopups();
      lastOpenedMarker = null;
    }

    final ownedStops = _stopCodesByRoute.remove(gtfsId) ?? <int>{};
    final stillUsed = <int>{};
    for (final codes in _stopCodesByRoute.values) {
      stillUsed.addAll(codes);
    }
    final toRemove = ownedStops.difference(stillUsed);
    if (toRemove.isNotEmpty) {
      if (lastOpenedMarker is FermataMarker &&
          toRemove.contains((lastOpenedMarker as FermataMarker).fermata.code)) {
        popupController.hideAllPopups();
        lastOpenedMarker = null;
      }
      allStops.removeWhere((m) => toRemove.contains(m.fermata.code));
      for (final code in toRemove) {
        stopsMap.remove(code);
      }
    }

    routes.remove(gtfsId);
    patternsByRoute.remove(gtfsId);
    _clearOffsetCache();
    _refreshStopMarkers();

    // After removal, if a single route remains, load its patterns
    // so the appbar dropdown can render right away.
    if (routes.length == 1) {
      loadPatternsFor(routes.keys.first);
    }

    if (routes.isNotEmpty) centerBounds();
  }

  void centerUser() async {
    isLocationLoading.value = true;
    try {
      if (userLocation.isLocationInitialized.isTrue) {
        _mapAnimation.animate(
            MapLocation.getLatLngFromPosition(userLocation.userPosition.first),
            zoom: 16);
      } else {
        _mapAnimation.animate(
            MapLocation.getLatLngFromPosition(await userLocation.userLocation),
            zoom: 16);
      }
    } on MapLocationException catch (e) {
      userLocation.locationShowing = false;
      if (e.locationPermission != null &&
          e.locationPermission == LocationPermission.deniedForever) {
        Utils.showSnackBar(e.message,
            closePrevious: true,
            duration: const Duration(seconds: 5),
            mainButton: TextButton(
              onPressed: () async {
                await Geolocator.openAppSettings();
              },
              child: Text(l10n.settings),
            ));
      } else {
        Utils.showSnackBar(
          e.message,
          closePrevious: true,
          duration: const Duration(seconds: 5),
        );
      }
    }

    isLocationLoading.value = false;
  }

  void stopFollowingVehicle() {
    followVehicle.value = 0;
  }

  void followVehicleMarker(MqttVehicle vehicle) {
    followVehicle.value = vehicle.vehicleNum;
    _mapAnimation.animate(vehicle.position);
  }

  void moveToFollowed() {
    if (followVehicle.value != 0) {
      _mapAnimation
          .animate(allVehicles[followVehicle.value]!.mqttData.position);
    }
  }

  RxBool isAppBarExpanded = true.obs;
  void toggleAppBar() => isAppBarExpanded.toggle();

  /// check if a stop is highlighted
  /// either pass the stop or the stop code
  bool isStopHighlighted({FermataMarker? stop, int? stopCode}) {
    assert(
        (stop != null || stopCode != null) &&
            (stop == null || stopCode == null),
        'O stop o stopCode bro');
    if (stop != null) {
      return stop.color == Colors.green;
    } else {
      final element = allStops
          .firstWhereOrNull((element) => element.fermata.code == stopCode);
      return element == null ? false : element.color == Colors.green;
    }
  }

  void setHighlightedStop(int stopCode, [bool addToGlobal = true]) {
    // change color with copyWith
    final element = allStops
        .firstWhereOrNull((element) => element.fermata.code == stopCode);

    if (element == null) return;

    final isHighlighted = isStopHighlighted(stop: element);
    allStops[allStops.indexOf(element)] = element.copyWith(
      color: isHighlighted ? stopBorderColor(stopCode) : Colors.green,
    );
    if (addToGlobal) {
      for (final route in routes.values) {
        isHighlighted
            ? MapUtils.removeSignedStop(route.gtfsId, stopCode)
            : MapUtils.addSignedStop(route.gtfsId, stopCode);
      }
    }
  }
}
