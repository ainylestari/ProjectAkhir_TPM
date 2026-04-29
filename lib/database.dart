import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // =========================
  // GET DATABASE
  // =========================
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('mood_planner.db');
    return _database!;
  }

  // =========================
  // INIT DATABASE
  // =========================
  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory =
        await getApplicationDocumentsDirectory();

    String path = join(documentsDirectory.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // =========================
  // CREATE TABLES
  // =========================
  Future _createDB(Database db, int version) async {
    // TABLE USER
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // TABLE JOURNAL
    await db.execute('''
      CREATE TABLE journals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        image TEXT,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // TABLE PLANNER
    await db.execute('''
      CREATE TABLE planners (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        destination TEXT NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        budget TEXT,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // =====================================================
  // USER SECTION
  // =====================================================

  // REGISTER USER
  Future<int> registerUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert('users', user);
  }

  // LOGIN USER
  Future<Map<String, dynamic>?> loginUser(
      String email,
      String password) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // GET ALL USERS
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await instance.database;
    return await db.query('users');
  }

  // =====================================================
  // JOURNAL SECTION
  // =====================================================

  // ADD JOURNAL
  Future<int> insertJournal(Map<String, dynamic> journal) async {
    final db = await instance.database;
    return await db.insert('journals', journal);
  }

  // GET ALL JOURNALS
  Future<List<Map<String, dynamic>>> getJournals() async {
    final db = await instance.database;
    return await db.query(
      'journals',
      orderBy: 'id DESC',
    );
  }

  // GET JOURNAL BY ID
  Future<Map<String, dynamic>?> getJournalById(int id) async {
    final db = await instance.database;

    final result = await db.query(
      'journals',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // UPDATE JOURNAL
  Future<int> updateJournal(
      int id,
      Map<String, dynamic> journal) async {
    final db = await instance.database;

    return await db.update(
      'journals',
      journal,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE JOURNAL
  Future<int> deleteJournal(int id) async {
    final db = await instance.database;

    return await db.delete(
      'journals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =====================================================
  // PLANNER SECTION
  // =====================================================

  // ADD PLANNER
  Future<int> insertPlanner(Map<String, dynamic> planner) async {
    final db = await instance.database;
    return await db.insert('planners', planner);
  }

  // GET ALL PLANNERS
  Future<List<Map<String, dynamic>>> getPlanners() async {
    final db = await instance.database;

    return await db.query(
      'planners',
      orderBy: 'id DESC',
    );
  }

  // GET PLANNER BY ID
  Future<Map<String, dynamic>?> getPlannerById(int id) async {
    final db = await instance.database;

    final result = await db.query(
      'planners',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // UPDATE PLANNER
  Future<int> updatePlanner(
      int id,
      Map<String, dynamic> planner) async {
    final db = await instance.database;

    return await db.update(
      'planners',
      planner,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE PLANNER
  Future<int> deletePlanner(int id) async {
    final db = await instance.database;

    return await db.delete(
      'planners',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =====================================================
  // CLOSE DATABASE
  // =====================================================

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}