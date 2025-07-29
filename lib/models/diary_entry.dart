// lib/models/diary_entry.dart
import 'package:daily_mood/models/weather_info.dart';

import 'mood_type.dart';

class DiaryEntry {
  final int? id;
  final String title;
  final String content;
  final DateTime date;
  final MoodType mood;
  final String? imagePath;
  final WeatherInfo? weather;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiaryEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    this.imagePath,
    this.weather,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.millisecondsSinceEpoch,
      'mood': mood.index,
      'imagePath': imagePath,
      'weatherData': weather?.toJson(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      mood: MoodType.values[map['mood']],
      imagePath: map['imagePath'],
      weather: map['weatherData'] != null
          ? WeatherInfo.fromJson(map['weatherData'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  DiaryEntry copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? date,
    MoodType? mood,
    String? imagePath,
    WeatherInfo? weather,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      imagePath: imagePath ?? this.imagePath,
      weather: weather ?? this.weather,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
