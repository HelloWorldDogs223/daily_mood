// lib/models/mood_type.dart
import 'dart:ui';

import 'package:flutter/material.dart';

enum MoodType { veryHappy, happy, neutral, sad, verySad }

extension MoodTypeExtension on MoodType {
  String get emoji {
    switch (this) {
      case MoodType.veryHappy:
        return '😄';
      case MoodType.happy:
        return '😊';
      case MoodType.neutral:
        return '😐';
      case MoodType.sad:
        return '😢';
      case MoodType.verySad:
        return '😭';
    }
  }

  String get label {
    switch (this) {
      case MoodType.veryHappy:
        return '매우 좋음';
      case MoodType.happy:
        return '좋음';
      case MoodType.neutral:
        return '보통';
      case MoodType.sad:
        return '나쁨';
      case MoodType.verySad:
        return '매우 나쁨';
    }
  }

  Color get color {
    switch (this) {
      case MoodType.veryHappy:
        return Colors.green[400]!;
      case MoodType.happy:
        return Colors.lightGreen[300]!;
      case MoodType.neutral:
        return Colors.grey[400]!;
      case MoodType.sad:
        return Colors.orange[300]!;
      case MoodType.verySad:
        return Colors.red[300]!;
    }
  }
}
