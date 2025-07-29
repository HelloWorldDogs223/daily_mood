// lib/services/database_service.dart
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/diary_entry.dart';
import '../models/mood_type.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'dailymood.db');

    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE diary_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date INTEGER NOT NULL,
        mood INTEGER NOT NULL,
        imagePath TEXT,
        weatherData TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');
  }

  // CRUD 작업들
  Future<int> insertDiaryEntry(DiaryEntry entry) async {
    final db = await database;
    final map = entry.toMap();

    // weatherData를 JSON 문자열로 변환
    if (map['weatherData'] != null) {
      map['weatherData'] = jsonEncode(map['weatherData']);
    }

    return await db.insert('diary_entries', map);
  }

  Future<List<DiaryEntry>> getAllDiaryEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_entries',
      orderBy: 'date DESC',
    );

    return maps.map((map) {
      // weatherData JSON 문자열을 다시 Map으로 변환
      if (map['weatherData'] != null) {
        map['weatherData'] = jsonDecode(map['weatherData']);
      }
      return DiaryEntry.fromMap(map);
    }).toList();
  }

  Future<DiaryEntry?> getDiaryEntry(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      if (map['weatherData'] != null) {
        map['weatherData'] = jsonDecode(map['weatherData']);
      }
      return DiaryEntry.fromMap(map);
    }
    return null;
  }

  Future<List<DiaryEntry>> getDiaryEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_entries',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'date DESC',
    );

    return maps.map((map) {
      if (map['weatherData'] != null) {
        map['weatherData'] = jsonDecode(map['weatherData']);
      }
      return DiaryEntry.fromMap(map);
    }).toList();
  }

  Future<List<DiaryEntry>> getDiaryEntriesByMonth(int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    return await getDiaryEntriesByDateRange(startDate, endDate);
  }

  Future<int> updateDiaryEntry(DiaryEntry entry) async {
    final db = await database;
    final map = entry.toMap();

    if (map['weatherData'] != null) {
      map['weatherData'] = jsonEncode(map['weatherData']);
    }

    return await db.update(
      'diary_entries',
      map,
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteDiaryEntry(int id) async {
    final db = await database;
    return await db.delete('diary_entries', where: 'id = ?', whereArgs: [id]);
  }

  // 통계를 위한 메서드들
  Future<Map<MoodType, int>> getMoodStatistics() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT mood, COUNT(*) as count 
      FROM diary_entries 
      GROUP BY mood
    ''');

    Map<MoodType, int> stats = {};
    for (var row in result) {
      final moodType = MoodType.values[row['mood']];
      stats[moodType] = row['count'];
    }

    return stats;
  }

  Future<Map<MoodType, int>> getMoodStatisticsByMonth(
    int year,
    int month,
  ) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT mood, COUNT(*) as count 
      FROM diary_entries 
      WHERE date BETWEEN ? AND ?
      GROUP BY mood
    ''',
      [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
    );

    Map<MoodType, int> stats = {};
    for (var row in result) {
      final moodType = MoodType.values[row['mood']];
      stats[moodType] = row['count'];
    }

    return stats;
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
