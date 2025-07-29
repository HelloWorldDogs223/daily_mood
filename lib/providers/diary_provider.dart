// lib/providers/diary_provider.dart
import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../models/mood_type.dart';
import '../services/database_service.dart';

class DiaryProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<DiaryEntry> _diaryEntries = [];
  bool _isLoading = false;
  String? _error;

  List<DiaryEntry> get diaryEntries => List.unmodifiable(_diaryEntries);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 최근 일기 가져오기 (홈 화면용)
  List<DiaryEntry> get recentEntries => _diaryEntries.take(5).toList();

  // 오늘 일기가 있는지 확인
  bool get hasTodayEntry {
    final today = DateTime.now();
    return _diaryEntries.any(
      (entry) =>
          entry.date.year == today.year &&
          entry.date.month == today.month &&
          entry.date.day == today.day,
    );
  }

  // 오늘의 일기 가져오기
  DiaryEntry? get todayEntry {
    final today = DateTime.now();
    try {
      return _diaryEntries.firstWhere(
        (entry) =>
            entry.date.year == today.year &&
            entry.date.month == today.month &&
            entry.date.day == today.day,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> loadDiaryEntries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _diaryEntries = await _databaseService.getAllDiaryEntries();
    } catch (e) {
      _error = '일기를 불러오는 중 오류가 발생했습니다: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDiaryEntriesByMonth(int year, int month) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _diaryEntries = await _databaseService.getDiaryEntriesByMonth(
        year,
        month,
      );
    } catch (e) {
      _error = '일기를 불러오는 중 오류가 발생했습니다: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addDiaryEntry(DiaryEntry entry) async {
    try {
      final id = await _databaseService.insertDiaryEntry(entry);
      final newEntry = entry.copyWith(id: id);

      _diaryEntries.insert(0, newEntry);
      notifyListeners();
      return true;
    } catch (e) {
      _error = '일기 저장 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDiaryEntry(DiaryEntry entry) async {
    try {
      await _databaseService.updateDiaryEntry(entry);

      final index = _diaryEntries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _diaryEntries[index] = entry;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = '일기 수정 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDiaryEntry(int id) async {
    try {
      await _databaseService.deleteDiaryEntry(id);

      _diaryEntries.removeWhere((entry) => entry.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = '일기 삭제 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// lib/providers/statistics_provider.dart
class StatisticsProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  Map<MoodType, int> _moodStatistics = {};
  bool _isLoading = false;
  String? _error;

  Map<MoodType, int> get moodStatistics => Map.unmodifiable(_moodStatistics);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 가장 많이 선택된 기분
  MoodType? get mostFrequentMood {
    if (_moodStatistics.isEmpty) return null;

    var maxEntry = _moodStatistics.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    return maxEntry.key;
  }

  // 전체 일기 수
  int get totalEntries => _moodStatistics.values.fold(0, (a, b) => a + b);

  Future<void> loadMoodStatistics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _moodStatistics = await _databaseService.getMoodStatistics();
    } catch (e) {
      _error = '통계를 불러오는 중 오류가 발생했습니다: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoodStatisticsByMonth(int year, int month) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _moodStatistics = await _databaseService.getMoodStatisticsByMonth(
        year,
        month,
      );
    } catch (e) {
      _error = '통계를 불러오는 중 오류가 발생했습니다: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
