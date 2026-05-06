import 'package:torino_mobility/models/gtt/pattern.dart';
import 'package:torino_mobility/models/gtt/route.dart';
import 'package:torino_mobility/models/gtt/stoptime.dart';
import 'package:torino_mobility/models/map/address.dart';
import 'package:latlong2/latlong.dart';

class FakeData {
  RouteWithDetails get fakeRouteWithDetails => RouteWithDetails(
        agencyId: fakeText(3),
        shortName: fakeText(3),
        longName: fakeText(10),
        type: 0,
        desc: fakeText(),
        gtfsId: fakeText(5),
        stoptimes: List.filled(4, fakeStoptime),
        alerts: [],
        pattern: fakePattern,
      );
  Pattern get fakePattern => Pattern(
        routeId: fakeText(3),
        code: fakeText(3),
        directionId: 0,
        headsign: fakeText(10),
        points: fakeText(10),
      );

  Stoptime get fakeStoptime => Stoptime(
        realtime: false,
        realtimeDeparture: DateTime(2024),
        scheduledDeparture: DateTime(2024),
      );

  AddressWithDetails get fakeAddressWithDetails => AddressWithDetails(
        street: fakeText(20),
        city: fakeText(5),
        state: fakeText(5),
        postalCode: fakeText(5),
        houseNumber: fakeText(5),
        position: const LatLng(0.0, 0.0),
        label: fakeText(20),
        province: fakeText(5),
        distanceInKm: 0.0,
      );

  String fakeText([int chars = 10]) {
    return 'f' * chars;
  }
}
