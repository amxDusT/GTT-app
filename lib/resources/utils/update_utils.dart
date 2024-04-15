import 'package:flutter/foundation.dart';
import 'package:flutter_gtt/models/gtt/agency.dart';
import 'package:flutter_gtt/models/gtt/route.dart';
import 'package:flutter_gtt/models/gtt/pattern.dart';
import 'package:flutter_gtt/models/gtt/stop.dart';
import 'package:flutter_gtt/resources/database.dart';

class UpdateUtils {
  static Future<void> update(List<dynamic> elements) async {
    List<dynamic> allElements;
    switch (elements[0].runtimeType) {
      case const (Route):
        allElements = await DatabaseCommands.instance.routes;
        break;
      case const (Pattern):
        allElements = await DatabaseCommands.instance.allPatterns;
        break;
      case const (Stop):
        allElements = await DatabaseCommands.instance.allStops;
        break;
      case const (PatternStop):
        allElements = await DatabaseCommands.instance.allPatternStops;
        break;
      case const (Agency):
        allElements = await DatabaseCommands.instance.agencies;
        break;
      default:
        throw 'Error, Object not found';
    }
    Set<dynamic> apiSet = elements.toSet();
    Set<dynamic> dbSet = allElements.toSet();

    List<dynamic> toInsertOrUpdate = apiSet.difference(dbSet).toList();
    List<dynamic> toDelete = dbSet.difference(apiSet).toList();

    DatabaseCommands.instance.bulkDelete(toDelete);
    DatabaseCommands.instance.bulkInsert(toInsertOrUpdate);
    debugPrint(
        'Elements updates in table ${elements[0].runtimeType}: ${toInsertOrUpdate.length}');
    debugPrint(
        'Elements deleted in table ${elements[0].runtimeType}: ${toDelete.length}');
  }

  /* static void _updateAll(
      SendPort port, List<dynamic> apiElements, List<dynamic> dbElements) {
    Set<dynamic> apiSet = apiElements.toSet();
    Set<dynamic> dbSet = dbElements.toSet();

    List<dynamic> toInsertOrUpdate = apiSet.difference(dbSet).toList();
    List<dynamic> toDelete = dbSet.difference(apiSet).toList();
    port.send('done');
  }

  static VoidCallback _createIsolateFunction(
      SendPort sendPort, List<dynamic> apiElements, List<dynamic> dbElements) {
    return () {
      _updateAll(sendPort, apiElements, dbElements);
    };
  }

  static Future<void> _runIsolate(
      List<dynamic> apiElements, List<dynamic> dbElements) async {
    final receivePort = ReceivePort();
    final closure =
        _createIsolateFunction(receivePort.sendPort, apiElements, apiElements);

    await Isolate.run(closure);

    receivePort.listen((message) {
      print('Received: $message');
      if (message == 'done') {
        receivePort.close();
      }
    });
  } */
}
