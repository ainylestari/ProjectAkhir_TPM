import 'dart:io';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance =
      DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  /// =========================
  /// HASH PASSWORD
  /// =========================
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// =========================
  /// GET DATABASE
  /// =========================
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('mood_planner.db');
    return _database!;
  }

  /// =========================
  /// INIT DATABASE
  /// =========================
  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory =
        await getApplicationDocumentsDirectory();

    String path = join(
      documentsDirectory.path,
      filePath,
    );

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// =========================
  /// CREATE TABLES
  /// =========================
  Future<void> _createDB(
    Database db,
    int version,
  ) async {
    /// USERS
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        image TEXT,
        phone INTEGER,
        location TEXT
      )
    ''');

    /// JOURNALS
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

    /// PLANNERS
    await db.execute('''
      CREATE TABLE planners (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        timezone TEXT NOT NULL,
        period TEXT NOT NULL,
        budget TEXT,
        currency TEXT,
        user_id INTEGER,
        FOREIGN KEY (user_id)
        REFERENCES users (id)
      )
    ''');

    /// explore
    await db.execute('''
      CREATE TABLE explore (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        lat REAL NOT NULL,
        lng REAL NOT NULL,
        imagePath TEXT NOT NULL,
        description TEXT
      )
    ''');

    /*dummy
    await db.insert('explore', {
      'name': 'Ethikopia',
      'category': 'Cafe',
      'lat': -7.740338,
      'lng': 110.358367,
      'imagePath': 'https://example.com/kopi.jpg',
      'description': 'Kopi'
    });*/

    /// chat history
    await db.execute('''
    CREATE TABLE chat_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT NOT NULL, 
      role TEXT NOT NULL,
      message TEXT NOT NULL,
      timestamp TEXT NOT NULL
    )
  ''');
  }

  /// =====================================================
  /// USER SECTION
  /// =====================================================

  /// REGISTER USER
  Future<int> registerUser(
    Map<String, dynamic> user,
  ) async {
    final db = await database;

    var userWithHash =
        Map<String, dynamic>.from(user);

    userWithHash['password'] =
        _hashPassword(user['password']);

    return await db.insert(
      'users',
      userWithHash,
    );
  }

  /// LOGIN USER
  Future<Map<String, dynamic>?> loginUser(
    String email,
    String password,
  ) async {
    final db = await database;

    String hashedInput =
        _hashPassword(password);

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [
        email,
        hashedInput,
      ],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  /// GET ALL USERS
  Future<List<Map<String, dynamic>>>
      getUsers() async {
    final db = await database;

    return await db.query(
      'users',
      orderBy: 'id DESC',
    );
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  /// UPDATE USER
  Future<int> updateUser(int id,Map<String, dynamic> user,) async {
    final db = await instance.database;

    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// =====================================================
  /// JOURNAL SECTION
  /// =====================================================

  /// ADD JOURNAL
  Future<int> insertJournal(
    Map<String, dynamic> journal,
  ) async {
    final db = await database;

    return await db.insert(
      'journals',
      journal,
    );
  }

  /// GET ALL JOURNALS
  Future<List<Map<String, dynamic>>>
      getJournals() async {
    final db = await database;

    return await db.query(
      'journals',
      orderBy: 'id DESC',
    );
  }

  /// GET JOURNAL BY ID
  Future<Map<String, dynamic>?>
      getJournalById(int id) async {
    final db = await database;

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

  /// UPDATE JOURNAL
  Future<int> updateJournal(
    int id,
    Map<String, dynamic> journal,
  ) async {
    final db = await database;

    return await db.update(
      'journals',
      journal,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// DELETE JOURNAL
  Future<int> deleteJournal(int id) async {
    final db = await database;

    return await db.delete(
      'journals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// =====================================================
  /// PLANNER SECTION
  /// =====================================================

  /// ADD PLANNER
  Future<int> insertPlanner(
    Map<String, dynamic> planner,
  ) async {
    final db = await database;

    return await db.insert(
      'planners',
      planner,
    );
  }

  /// GET ALL PLANNERS
  Future<List<Map<String, dynamic>>>
      getPlanners() async {
    final db = await database;

    return await db.query(
      'planners',
      orderBy: 'id DESC',
    );
  }

  /// GET PLANNER BY ID
  Future<Map<String, dynamic>?>
      getPlannerById(int id) async {
    final db = await database;

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

  /// UPDATE PLANNER
  Future<int> updatePlanner(
    int id,
    Map<String, dynamic> planner,
  ) async {
    final db = await database;

    return await db.update(
      'planners',
      planner,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// DELETE PLANNER
  Future<int> deletePlanner(int id) async {
    final db = await database;

    return await db.delete(
      'planners',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getPlannerByDate(
    String date,
  ) async {
    final db = await database;

    return await db.query(
      'planners',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'time ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllPlanner(
    int userId,
  ) async {
    final db = await database;

    return await db.query(
      'planners',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date ASC, time ASC',
    );
  }

  /// =====================================================
  /// EXPLORE SECTION
  /// =====================================================

  Future<List<Map<String, dynamic>>> getExplore() async {
    final db = await database;

    return await db.query(
      'explore',
      orderBy: 'id DESC',
    );
  }

  Future<int> insertExplore(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('explore', row);
  }

  /// =====================================================
  /// CHAT HISTORY SECTION
  /// =====================================================

  // save chat
  Future<int> insertChat(Map<String, dynamic> chat) async {
    final db = await database;
    return await db.insert('chat_history', chat);
  }

  /// fetch history
  Future<List<Map<String, dynamic>>> getChatHistory(String email) async {
    final db = await database;
    return await db.query(
      'chat_history',
      where: 'email = ?',
      whereArgs: [email],
      orderBy: 'timestamp ASC', // urut dari terlama ke terbaru
    );
  }

  /// hapus semua chat
  Future<int> clearChat(String email) async {
    final db = await database;
    return await db.delete(
      'chat_history',
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // ====================
  // buat debug
  Future<void> printAllDatabase() async {
    final db = await database;

    /// USERS
    final users = await db.query(
      'users',
      orderBy: 'id DESC',
    );

    print("===== USERS =====");
    print(users);
    print("=================\n");

    /// JOURNALS
    final journals = await db.query(
      'journals',
      orderBy: 'id DESC',
    );

    print("===== JOURNALS =====");
    print(journals);
    print("====================\n");

    /// PLANNERS
    final planners = await db.query(
      'planners',
      orderBy: 'id DESC',
    );

    print("===== PLANNERS =====");
    print(planners);
    print("====================\n");

    /// EXPLORE
    final explore = await db.query(
      'explore',
      orderBy: 'id DESC',
    );

    print("===== EXPLORE =====");
    print(explore);
    print("====================\n");
  }

  /// =====================================================
  /// CLOSE DATABASE
  /// =====================================================

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}