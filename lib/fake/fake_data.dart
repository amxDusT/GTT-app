import 'package:flutter_gtt/models/gtt/pattern.dart';
import 'package:flutter_gtt/models/gtt/route.dart';
import 'package:flutter_gtt/models/gtt/stoptime.dart';

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

  String fakeText([int chars = 10]) {
    return 'f' * chars;
  }
}
