import 'package:flutter_gtt/models/fermata.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseCommands {
  static Future<Database>? database;
  static const stopTable = "gtt_stops";
  static Future<Database> get dbase => database ?? init();

  static Future<Database> init() async {
    database = openDatabase(
      join(await getDatabasesPath(), '$stopTable.db'),
      onCreate: (db, version) {
        return createTable(db: db);
      },
      version: 5,
    );
    return database!;
  }

  static void deleteTable() async {
    final db = await dbase;
    await db.execute("DROP TABLE $stopTable");
  }

  static void createTable({Database? db}) async {
    db ??= await dbase;
    await db.execute(
      'CREATE TABLE $stopTable(id INTEGER PRIMARY KEY, nome TEXT, descrizione TEXT, latitude REAL, longitude REAL)',
    );
  }

  static Future<void> insertStop(Fermata fermata) async {
    Database db = await dbase;
    await db.insert(
      stopTable,
      fermata.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> updateStop(Fermata fermata) async {
    Database db = await dbase;
    await db.insert(
      stopTable,
      fermata.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Fermata>> getFermate() async {
    Database db = await dbase;
    final List<Map<String, dynamic>> maps = await db.query(stopTable);
    return List.generate(maps.length, (i) {
      return Fermata(
        stopNum: maps[i]['id'] as int,
        nome: maps[i]['nome'] as String,
        descrizione: maps[i]['descrizione'] as String?,
        latitude: maps[i]['latitude'] as double,
        longitude: maps[i]['longitude'] as double,
        vehicles: [],
      );
    });
  }

  static Future<bool> hasStop(int stopNum) async {
    Database db = await dbase;

    final List<Map<String, dynamic>> result = await db.query(
      stopTable,
      where: 'id = ?',
      whereArgs: [stopNum],
    );
    return result.isNotEmpty;
  }

  static Future<List<int>> getStopNums() async {
    Database db = await dbase;
    final List<Map<String, dynamic>> maps = await db.query(stopTable);
    return List.generate(maps.length, (i) {
      return maps[i]['id'] as int;
    });
  }

  static Future<void> deleteStop(Fermata fermata) async {
    Database db = await dbase;
    await db.delete(
      stopTable,
      where: 'id = ?',
      whereArgs: [fermata.stopNum],
    );
  }
}
