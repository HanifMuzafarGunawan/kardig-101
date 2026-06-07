import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:kardig/models/card_model.dart';

class DatabaseHelper {
  static const String _databaseName = 'kardig.db';
  static const String _tableName = 'cards';
  static const int _databaseVersion = 1;

  static final DatabaseHelper _instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        qrCode TEXT NOT NULL,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        firstHourRate INTEGER NOT NULL,
        afterFirstHourRate INTEGER NOT NULL,
        maxRate INTEGER,
        color INTEGER NOT NULL
        
      )
    ''');
  }

  // Create
  Future<int> insertCard(CardData card) async {
    final Database db = await database;
    return await db.insert(_tableName, card.toMap());
  }

  // Read all
  Future<List<CardData>> getAllCards() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) => CardData.fromMap(maps[i]));
  }

  // Read by ID
  Future<CardData?> getCardById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return CardData.fromMap(maps.first);
    }
    return null;
  }

  // Update
  Future<int> updateCard(CardData card) async {
    final Database db = await database;
    return await db.update(
      _tableName,
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  // Delete
  Future<int> deleteCard(int id) async {
    final Database db = await database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  // Delete all
  Future<int> deleteAllCards() async {
    final Database db = await database;
    return await db.delete(_tableName);
  }

  // Close database
  Future<void> closeDatabase() async {
    final Database db = await database;
    await db.close();
  }
}
