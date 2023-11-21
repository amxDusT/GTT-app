import 'package:flutter_gtt/models/fermata.dart';
import 'package:flutter_gtt/resources/storage.dart';
import 'package:flutter_gtt/testing/testing_gtt_feeds.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseCommands {
  static Future<Database>? database;
  static const _databaseName = 'flutter_gtt';
  static const stopTable = 'gtt_stops';
  static const agencyTable = 'gtt_agency';
  static const vehiclesTable = 'gtt_vehicles';
  static Future<Database> get dbase => database ?? init();

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

  static void deleteTable() async {
    final db = await dbase;
    await db.execute('DROP TABLE $stopTable');
  }

  static void createTable({Database? db}) async {
    db ??= await dbase;
    await db.execute(
      'CREATE TABLE IF NOT EXISTS $stopTable(id INTEGER PRIMARY KEY AUTOINCREMENT, stopNum INTEGER UNIQUE, nome TEXT, descrizione TEXT, latitude REAL, longitude REAL, date INTEGER, color TEXT)',
    );

    await db.execute(
      'CREATE TABLE IF NOT EXISTS $agencyTable(id INTEGER PRIMARY KEY AUTOINCREMENT, gtfsId TEXT UNIQUE, name TEXT, url TEXT, fareUrl TEXT, phone TEXT)',
    );

    // await db.execute(
    //   'CREATE TABLE $vehiclesTable(id INTEGER PRIMARY KEY AUTOINCREMENT, )',
    // );
  }

  static Future<void> insertStop(Fermata fermata) async {
    Database db = await dbase;
    await db.insert(
      stopTable,
      fermata.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> updateStop(Fermata fermata) async {
    Database db = await dbase;

    await db.insert(
      stopTable,
      fermata.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Fermata>> getFermate() async {
    Database db = await dbase;
    final List<Map<String, dynamic>> maps = await db.query(
      stopTable,
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return Fermata(
        stopNum: maps[i]['stopNum'] as int,
        nome: maps[i]['nome'] as String,
        descrizione: maps[i]['descrizione'] as String?,
        latitude: maps[i]['latitude'] as double,
        longitude: maps[i]['longitude'] as double,
        vehicles: const [],
        dateTime: DateTime.fromMillisecondsSinceEpoch(
            (maps[i]['date'] as int) * 1000),
        color: Storage.stringToColor(maps[i]['color'] as String)!,
      );
    });
  }

  static Future<bool> hasStop(Fermata fermata) async {
    Database db = await dbase;

    final List<Map<String, dynamic>> result = await db.query(
      stopTable,
      where: 'stopNum = ?',
      whereArgs: [fermata.stopNum],
    );
    return result.isNotEmpty;
  }

  static Future<void> deleteStop(Fermata fermata) async {
    Database db = await dbase;

    await db.delete(
      stopTable,
      where: 'stopNum = ?',
      whereArgs: [fermata.stopNum],
    );
  }

  static Future<void> insertAgency(GttType agency) async {
    Database db = await dbase;
    //print('here');
    await db.insert(
      agencyTable,
      agency.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<List<GttType>> getAgencies() async {
    Database db = await dbase;
    final List<Map<String, dynamic>> maps = await db.query(
      agencyTable,
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) {
      return GttType.fromJson(maps[i]);
    });
  }

  static Future<void> deleteTableAgency() async {
    final db = await dbase;
    await db.execute('DROP TABLE $agencyTable');
  }
}


/*


*/