import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:torino_mobility/models/gtt/agency.dart';
import 'package:torino_mobility/models/gtt/favorite_stop.dart';
import 'package:torino_mobility/models/gtt/route.dart';
import 'package:torino_mobility/models/gtt/stop.dart';
import 'package:torino_mobility/models/gtt/pattern.dart';
import 'package:torino_mobility/resources/globals.dart';
import 'package:torino_mobility/resources/storage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseCommands {
  static DatabaseCommands? _instance;
  Future<Database>? database;
  static const _databaseName = 'flutter_gtt';
  static const _favoritesTable = 'favorites_table';

  static const _agencyTable = 'agencies';
  static const _routesTable = 'routes';
  static const _patternsTable = 'patterns';
  static const _stopsTable = 'stops';
  static const _patternStopsTable = 'pattern_stops';
  static const _favoritesVehiclesTable = 'favorites_vehicles';

  FutureOr<Database> get _dbInstance async => database ??= _init();
  DatabaseCommands._();

  static DatabaseCommands get instance {
    _instance ??= DatabaseCommands._();
    return _instance!;
  }

  Future<void> initialize() async {
    await _init();
  }

  Future<Database> _init() async {
    database = openDatabase(
      join(await getDatabasesPath(), '$_databaseName.db'),
      onCreate: (db, version) {
        return createTable(db: db);
      },
      version: 9,
      onUpgrade: (db, oldVersion, newVersion) async {
        createTable(db: db);
      },
    );
    return database!;
  }

  Future<void> createTable({Database? db}) async {
    db ??= await _dbInstance;
    final Batch batch = db.batch();
    batch.execute(
      '''CREATE TABLE IF NOT EXISTS $_agencyTable (
          gtfsId	TEXT,
          name	TEXT,
          url	TEXT,
          fareUrl	TEXT,
          phone	TEXT,
          PRIMARY KEY(gtfsId)
        )''',
    );

    batch.execute(
      '''CREATE TABLE IF NOT EXISTS $_routesTable (
          gtfsId	TEXT,
          agencyId	TEXT,
          shortName	TEXT,
          longName	TEXT,
          type	INTEGER,
          desc	TEXT,
          PRIMARY KEY(gtfsId),
          FOREIGN KEY(agencyId) REFERENCES $_agencyTable(gtfsId)
        )''',
    );

    batch.execute(
      '''CREATE TABLE IF NOT EXISTS $_patternsTable (
          code	TEXT PRIMARY KEY,
          routeId	TEXT,
          directionId	INTEGER,
          headsign	TEXT,
          points TEXT,
          FOREIGN KEY(routeId) REFERENCES $_routesTable(gtfsId)
        )''',
    );

    batch.execute(
      '''CREATE TABLE IF NOT EXISTS $_stopsTable (
            gtfsId TEXT PRIMARY KEY,
            code INTEGER,
            name TEXT,
            lat REAL,
            lon REAL
        )''',
    );
    batch.execute(
      '''CREATE TABLE IF NOT EXISTS $_patternStopsTable (
            patternCode TEXT,
            stopId TEXT,
            stopOrder INTEGER,
            PRIMARY KEY (patternCode, stopId),
            FOREIGN KEY (patternCode) REFERENCES $_patternsTable(patternCode),
            FOREIGN KEY (stopId) REFERENCES $_stopsTable(gtfsId)
        )''',
    );
    batch.execute(
      '''CREATE TABLE IF NOT EXISTS $_favoritesTable(
        stopId TEXT UNIQUE,
        descrizione TEXT,
        date INTEGER,
        color TEXT,
        FOREIGN KEY (stopId) REFERENCES $_stopsTable(gtfsId)
      )''',
    );
    // favorite vehicles from route list
    batch.execute(
      '''
      CREATE TABLE IF NOT EXISTS $_favoritesVehiclesTable(
        routeId TEXT UNIQUE,
        date INTEGER,
        FOREIGN KEY (routeId) REFERENCES $_routesTable(gtfsId)
      )
      ''',
    );
    await batch.commit();
  }

  Future<void> insertStop(Stop fermata) async {
    final Database db = await _dbInstance;
    final FavStop fermataFav = (fermata is FavStop)
        ? fermata
        : FavStop.fromStop(
            stop: fermata,
          );
    await db.insert(
      _favoritesTable,
      fermataFav.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertStopRaw(Map<String, dynamic> json) async {
    final Database db = await _dbInstance;
    await db.insert(
      _favoritesTable,
      json,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> updateAllStops(List<FavStop> fermate) async {
    final Database db = await _dbInstance;
    final batch = db.batch();
    for (var fermata in fermate) {
      batch.insert(
        _favoritesTable,
        fermata.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  Future<void> updateStop(FavStop fermata) async {
    final Database db = await _dbInstance;

    await db.insert(
      _favoritesTable,
      fermata.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateStopWithSmallestDate(Stop stop) async {
    final Database db = await _dbInstance;

    await db.rawUpdate('''
      UPDATE $_favoritesTable
      SET date = (SELECT MIN(date) FROM $_favoritesTable)-1
      WHERE stopId = ?;
    ''', [stop.gtfsId]);
  }

  Future<bool> hasStop(Stop fermata) async {
    final Database db = await _dbInstance;

    final List<Map<String, dynamic>> result = await db.query(
      _favoritesTable,
      where: 'stopId = ?',
      whereArgs: [fermata.gtfsId],
    );
    return result.isNotEmpty;
  }

  /// Remove stop from favorites
  Future<void> deleteStop(Stop fermata) async {
    final Database db = await _dbInstance;

    await db.delete(
      _favoritesTable,
      where: 'stopId = ?',
      whereArgs: [fermata.gtfsId],
    );
  }

  Future<void> addFavoriteRoute(Route route) async {
    final Database db = await _dbInstance;
    await db.insert(
      _favoritesVehiclesTable,
      {
        'routeId': route.gtfsId,
        'date': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeFavoriteRoute(Route route) async {
    final Database db = await _dbInstance;
    await db.delete(
      _favoritesVehiclesTable,
      where: 'routeId = ?',
      whereArgs: [route.gtfsId],
    );
  }

  Future<void> removeAllFromFavorites() async {
    final Database db = await _dbInstance;
    await db.delete(_favoritesVehiclesTable);
  }
  /*
    ------------------------------------------------------------------------
  */

  Future<List<Route>> get favoriteRoutes async {
    final Database db = await _dbInstance;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT $_routesTable.*, $_favoritesVehiclesTable.date
      FROM $_routesTable
      JOIN $_favoritesVehiclesTable ON $_routesTable.gtfsId = $_favoritesVehiclesTable.routeId
      ORDER BY $_favoritesVehiclesTable.date ASC;
      ''',
    );

    return List.generate(result.length, (i) {
      return Route.fromJson(result[i]);
    });
  }

  Future<List<FavStop>> get favorites async {
    final Database db = await _dbInstance;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT $_stopsTable.*, $_favoritesTable.*
      FROM $_stopsTable
      JOIN $_favoritesTable ON $_stopsTable.gtfsId = $_favoritesTable.stopId
      ORDER BY $_favoritesTable.date ASC;
      ''',
    );

    return List.generate(result.length, (i) {
      return FavStop.fromJson(result[i]);
    });
  }

  Future<String> get exportFavorites async {
    final Database db = await _dbInstance;

    var result = await db.query(_favoritesTable);
    return json.encode(result);
  }

  Future<void> importFavorites(List<dynamic> favoritesJson) async {
    final Database db = await _dbInstance;

    final batch = db.batch();

    for (var fermata in favoritesJson) {
      String? stopId = fermata['stopId'];
      if (stopId == null) {
        continue;
      }
      var result = await db.query(
        _stopsTable,
        where: 'gtfsId = ?',
        whereArgs: [stopId],
      );
      // check if stop exists
      if (result.isEmpty) {
        continue;
      }
      final Stop stop = Stop.fromJson(result.first);
      String? colorString = fermata['color'];
      int? date = fermata['date'];
      String? description = fermata['descrizione'];
      Color? color = Storage.stringToColor(colorString);
      if (color == null) {
        colorString = Storage.colorToString(initialColor);
        color = initialColor;
      }

      {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (date == null || date < 0 || date > now) {
          date = now;
        }
      }

      if (description != null && description.length > 128) {
        description = description.toString().substring(0, 128);
      }

      final favStop = FavStop.fromStop(
        stop: stop,
        dateTime: DateTime.fromMillisecondsSinceEpoch(date * 1000),
        color: color,
        descrizione: description,
      );
      batch.insert(
        _favoritesTable,
        favStop.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit();
  }

  Future<List<Agency>> get agencies async {
    final db = await _dbInstance;
    final results = await db.query(
      _agencyTable,
      orderBy: 'gtfsId DESC',
    );

    //return results.map((agency) => Agency.fromJson(agency)).toList();
    return List.generate(results.length, (i) {
      return Agency.fromJson(results[i]);
    });
  }

  Future<List<Route>> get routes async {
    final db = await _dbInstance;
    final results = await db.query(
      _routesTable,
      orderBy: 'type ASC',
    );
    return List.generate(results.length, (i) {
      return Route.fromJson(results[i]);
    });
  }

  //  Future<List<Pattern>> getPatterns(Route route) async {
  //   final db = await _dbInstance;
  //   final results = await db.query(
  //     _patternsTable,
  //     where: 'routeId = ?',
  //     whereArgs: [route.gtfsId],
  //     orderBy: 'directionId, code ASC',
  //   );
  //   return List.generate(results.length, (i) {
  //     return Pattern.fromJson(results[i]);
  //   });
  // }
  Future<List<Pattern>> getPatterns(Route route) async {
    final db = await _dbInstance;
    final results = await db.rawQuery('''
    SELECT $_patternsTable.*, COUNT($_patternStopsTable.stopId) AS numStops
    FROM $_patternsTable
    LEFT JOIN $_patternStopsTable ON $_patternsTable.code = $_patternStopsTable.patternCode
    WHERE $_patternsTable.routeId = ?
    GROUP BY $_patternsTable.code
    ORDER BY $_patternsTable.directionId ASC, numStops DESC
  ''', [route.gtfsId]);
    return List.generate(results.length, (i) {
      return Pattern.fromJson(results[i]);
    });
  }

  Future<void> bulkDelete(List<dynamic> elements) async {
    if (elements.isEmpty) {
      return;
    }
    late String table;
    switch (elements[0].runtimeType) {
      case const (Route):
        table = _routesTable;
        break;
      case const (Pattern):
        table = _patternsTable;
        break;
      case const (Stop):
        table = _stopsTable;
        break;
      case const (PatternStop):
        table = _patternStopsTable;
        break;
      case const (Agency):
        table = _agencyTable;
        break;
      default:
        throw 'Error, Object not found';
    }

    final db = await _dbInstance;

    await db.transaction((txn) async {
      final batch = txn.batch();
      for (var element in elements) {
        if (table == _patternsTable) {
          batch.delete(
            table,
            where: 'code = ?',
            whereArgs: [element.code],
          );
        } else if (table == _patternStopsTable) {
          batch.delete(
            table,
            where: 'patternCode = ? AND stopId = ?',
            whereArgs: [element.patternCode, element.stopId],
          );
        } else {
          batch.delete(
            table,
            where: 'gtfsId = ?',
            whereArgs: [element.gtfsId],
          );
        }
      }
      await batch.commit(noResult: true);
      if (kDebugMode) print('finished $table');
    });
  }

  Future<void> bulkInsert(List<dynamic> elements) async {
    if (elements.isEmpty) {
      return;
    }
    late String table;
    switch (elements[0].runtimeType) {
      case const (Route):
        table = _routesTable;
        break;
      case const (Pattern):
        table = _patternsTable;
        break;
      case const (Stop):
        table = _stopsTable;
        break;
      case const (PatternStop):
        table = _patternStopsTable;
        break;
      case const (Agency):
        table = _agencyTable;
        break;
      default:
        throw 'Error, Object not found';
    }

    final db = await _dbInstance;

    await db.transaction((txn) async {
      final batch = txn.batch();
      //batch.delete(table!);
      for (var element in elements) {
        batch.insert(
          table,
          element.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
      if (kDebugMode) print('finished $table');
    });
  }

  Future<Stop?> getStop(int stopNum) async {
    final db = await _dbInstance;
    final List<Map<String, dynamic>> result = await db.query(
      _stopsTable,
      where: 'code = ?',
      whereArgs: [stopNum],
    );
    if (result.isNotEmpty) {
      return Stop.fromJson(result.first);
    }
    if (kDebugMode) print('oh no');
    return null;
  }

  Future<List<Stop>> getStopsFromPattern(Pattern pattern) async {
    final db = await _dbInstance;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT $_stopsTable.* 
      FROM $_stopsTable 
      JOIN $_patternStopsTable ON $_stopsTable.gtfsId = $_patternStopsTable.stopId 
      WHERE $_patternStopsTable.patternCode = ?
      ORDER BY $_patternStopsTable.stopOrder ASC
      ''',
      [pattern.code],
    );
    return List.generate(result.length, (i) {
      return Stop.fromJson(result[i]);
    });
  }

  Future<List<Route>> getRouteFromStop(Stop stop) async {
    final db = await _dbInstance;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT DISTINCT $_routesTable.*
      FROM $_routesTable
      JOIN $_patternsTable ON $_routesTable.gtfsId = $_patternsTable.routeId
      JOIN $_patternStopsTable ON $_patternsTable.code = $_patternStopsTable.patternCode
      JOIN $_stopsTable ON $_patternStopsTable.stopId = $_stopsTable.gtfsId
      WHERE $_stopsTable.gtfsId = ?
      ORDER BY $_routesTable.type ASC, $_routesTable.shortName ASC
      ''', [stop.gtfsId]);
    return List.generate(result.length, (i) {
      return Route.fromJson(result[i]);
    });
  }

  Future<Pattern> getPatternFromCode(String code) async {
    final db = await _dbInstance;
    final List<Map<String, dynamic>> result = await db.query(
      _patternsTable,
      where: 'code = ?',
      whereArgs: [code],
    );
    return Pattern.fromJson(result.first);
  }

  Future<List<Stop>> getStopsFromCode(int code, [limit = 25]) async {
    final db = await _dbInstance;
    final List<Map<String, dynamic>> result = await db.query(
      _stopsTable,
      where: 'code LIKE ?',
      whereArgs: ['$code%'],
      orderBy: 'code ASC',
      limit: limit,
    );
    return List.generate(result.length, (i) {
      return Stop.fromJson(result[i]);
    });
  }

  Future<List<Stop>> getStopsFromName(String name, [limit = 25]) async {
    final db = await _dbInstance;
    final List<Map<String, dynamic>> result = await db.query(
      _stopsTable,
      where: 'name LIKE ?',
      whereArgs: ['$name%'],
      orderBy: 'code ASC',
      limit: limit,
    );
    return List.generate(result.length, (i) {
      return Stop.fromJson(result[i]);
    });
  }

  Future<List<PatternStop>> get allPatternStops async {
    final db = await _dbInstance;
    final results = await db.query(_patternStopsTable);
    return List.generate(results.length, (i) {
      return PatternStop.fromJson(results[i]);
    });
  }

  Future<List<Pattern>> get allPatterns async {
    final db = await _dbInstance;
    final results = await db.query(_patternsTable);
    return List.generate(results.length, (i) {
      return Pattern.fromJson(results[i]);
    });
  }

  Future<List<Stop>> get allStops async {
    final db = await _dbInstance;
    final results = await db.query(_stopsTable);
    return List.generate(results.length, (i) {
      return Stop.fromJson(results[i]);
    });
  }

  // --------- test -----------
  Future<Route> getRoute(String routeId) async {
    final db = await _dbInstance;
    final List<Map<String, dynamic>> result = await db.query(
      _routesTable,
      where: 'gtfsId = ?',
      whereArgs: [routeId],
    );
    return Route.fromJson(result.first);
  }

  /* Future<void> removePattern(Pattern pattern) async {
    final db = await _dbInstance;
    await db.delete(
      _patternsTable,
      where: 'code = ?',
      whereArgs: [pattern.code],
    );

    await db.delete(
      _patternStopsTable,
      where: 'patternCode = ?',
      whereArgs: [pattern.code],
    );
  } */

  // test
  /* Future<void> clearTables() async {
    final db = await _dbInstance;
    await db.transaction((txn) async {
      final batch = txn.batch();
      batch.delete(_patternStopsTable);
      batch.delete(_stopsTable);
      batch.delete(_patternsTable);
      batch.delete(_routesTable);
      batch.delete(_agencyTable);
      batch.delete(_favoritesTable);
      await batch.commit();
    });
  } */
}
