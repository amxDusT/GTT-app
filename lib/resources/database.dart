import 'package:flutter_gtt/models/gtt_models.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseCommands {
  static Future<Database>? database;
  static const _databaseName = 'flutter_gtt';
  static const _favoritesTable = 'favorites_table';

  static const _agencyTable = 'agencies';
  static const _routesTable = "routes";
  static const _patternsTable = "patterns";
  static const _stopsTable = "stops";
  static const _patternStopsTable = "pattern_stops";

  static Future<Database> get instance => database ?? init();

  static Future<Database> init() async {
    database = openDatabase(
      join(await getDatabasesPath(), '$_databaseName.db'),
      onCreate: (db, version) {
        return createTable(db: db);
      },
      version: 5,
    );
    return database!;
  }

  // test
  static Future<void> deleteTable() async {
    final db = await instance;
    await db.execute('DROP TABLE $_favoritesTable');
    await db.execute('DROP TABLE $_stopsTable');
    await db.execute('DROP TABLE $_agencyTable');
    await db.execute('DROP TABLE $_routesTable');
    await db.execute('DROP TABLE $_patternsTable');
    await db.execute('DROP TABLE $_stopsTable');
    await db.execute('DROP TABLE $_patternStopsTable');
  }

  static Future<void> createTable({Database? db}) async {
    db ??= await instance;
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
    await batch.commit();
  }

  static Future<void> insertStop(Stop fermata) async {
    Database db = await instance;
    final FavStop fermataFav =
        (fermata is FavStop) ? fermata : FavStop.fromStop(stop: fermata);
    await db.insert(
      _favoritesTable,
      fermataFav.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> updateStop(FavStop fermata) async {
    Database db = await instance;

    await db.insert(
      _favoritesTable,
      fermata.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<FavStop>> getFermate() async {
    Database db = await instance;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT $_stopsTable.*, $_favoritesTable.*
      FROM $_stopsTable
      JOIN $_favoritesTable ON $_stopsTable.gtfsId = $_favoritesTable.stopId
      ORDER BY $_favoritesTable.date DESC;
      ''',
    );

    return List.generate(result.length, (i) {
      return FavStop.fromJson(result[i]);
    });
  }

  static Future<bool> hasStop(Stop fermata) async {
    Database db = await instance;

    final List<Map<String, dynamic>> result = await db.query(
      _favoritesTable,
      where: 'stopId = ?',
      whereArgs: [fermata.gtfsId],
    );
    return result.isNotEmpty;
  }

  static Future<void> deleteStop(Stop fermata) async {
    Database db = await instance;

    await db.delete(
      _favoritesTable,
      where: 'stopId = ?',
      whereArgs: [fermata.gtfsId],
    );
  }

  /*
    ------------------------------------------------------------------------
  */

  static Future<List<Agency>> get agencies async {
    final db = await instance;
    final results = await db.query(
      _agencyTable,
      orderBy: 'gtfsId DESC',
    );

    //return results.map((agency) => Agency.fromJson(agency)).toList();
    return List.generate(results.length, (i) {
      return Agency.fromJson(results[i]);
    });
  }

  static Future<List<Route>> get routes async {
    final db = await instance;
    final results = await db.query(
      _routesTable,
    );
    return List.generate(results.length, (i) {
      return Route.fromJson(results[i]);
    });
  }

  static Future<List<Pattern>> getPatterns(Route route) async {
    final db = await instance;
    final results = await db.query(
      _patternsTable,
      where: 'routeId = ?',
      whereArgs: [route.gtfsId],
      orderBy: 'directionId, code ASC',
    );
    return List.generate(results.length, (i) {
      return Pattern.fromJson(results[i]);
    });
  }

  static Future<void> transaction(List<dynamic> elements) async {
    if (elements.isEmpty) {
      return;
    }
    String? table;

    if (elements[0] is Route) {
      table = _routesTable;
    } else if (elements[0] is Pattern) {
      table = _patternsTable;
    } else if (elements[0] is Stop) {
      table = _stopsTable;
    } else if (elements[0] is PatternStop) {
      table = _patternStopsTable;
    } else if (elements[0] is Agency) {
      table = _agencyTable;
    }

    if (table == null) {
      throw 'Error, Object not found';
    }
    final db = await instance;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (var element in elements) {
        batch.insert(
          table!,
          element.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit();
      print("finished $table");
    });
  }

  static Future<Stop?> getStop(int stopNum) async {
    final db = await instance;
    final List<Map<String, dynamic>> result = await db.query(
      _stopsTable,
      where: 'code = ?',
      whereArgs: [stopNum],
    );
    if (result.isNotEmpty) {
      print('hello');
      return Stop.fromJson(result.first);
    }
    print('oh no');
    return null;
  }

  static Future<List<Stop>> getStopsFromPattern(Pattern pattern) async {
    final db = await instance;
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

  static Future<List<Route>> getRouteFromStop(Stop stop) async {
    final db = await instance;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT DISTINCT $_routesTable.*
      FROM $_routesTable
      JOIN $_patternsTable ON $_routesTable.gtfsId = $_patternsTable.routeId
      JOIN $_patternStopsTable ON $_patternsTable.code = $_patternStopsTable.patternCode
      JOIN $_stopsTable ON $_patternStopsTable.stopId = $_stopsTable.gtfsId
      WHERE $_stopsTable.gtfsId = ?
      ''', [stop.gtfsId]);
    return List.generate(result.length, (i) {
      return Route.fromJson(result[i]);
    });
  }

  static Future<Pattern> getPatternFromCode(String code) async {
    final db = await instance;
    final List<Map<String, dynamic>> result = await db.query(
      _patternsTable,
      where: 'code = ?',
      whereArgs: [code],
    );
    return Pattern.fromJson(result.first);
  }

  // test
  static Future<void> clearTables() async {
    final db = await instance;
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
  }
}


/*


*/