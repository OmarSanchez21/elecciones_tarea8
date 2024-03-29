import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'event.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async{
    if(_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async{
    String path = join(await getDatabasesPath(), 'event_database.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async{
    await db.execute('''CREATE TABLE events(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      descripcion TEXT,
      date TEXT,
      photoPath TEXT,
      audioPath TEXT)''');
  }

  Future<int> insertEvent(Event event) async{
    final Database db = await instance.database;
    return await db.insert('events', event.toMap());
  }

  Future<List<Event>> getAllEvents() async{
    final Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('events');
    return List.generate(maps.length, (index) {
      return Event(
        id: maps[index]['id'],
        title: maps[index]['title'],
        descripcion: maps[index]['descripcion'],
        date: DateTime.parse(maps[index]['date']),
        photoPath: maps[index]['photoPath'],
        audioPath: maps[index]['audioPath']
      );
    });
  }

  Future<void> deleteAllEvents() async{
    final Database db = await instance.database;
    await db.delete('events');
  }
}