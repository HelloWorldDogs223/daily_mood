// lib/services/image_service.dart
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageService {
  static Future<String> saveImage(File imageFile) async {
    try {
      // 앱의 문서 디렉토리 가져오기
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');

      // images 폴더가 없으면 생성
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // 고유한 파일명 생성
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final savedImagePath = '${imagesDir.path}/$fileName';

      // 이미지 파일 복사
      final savedImage = await imageFile.copy(savedImagePath);

      return savedImage.path;
    } catch (e) {
      throw Exception('이미지 저장 실패: $e');
    }
  }

  static Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('이미지 삭제 실패: $e');
      return false;
    }
  }

  static Future<void> cleanupOldImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');

      if (await imagesDir.exists()) {
        final files = imagesDir.listSync();
        final now = DateTime.now();

        for (final file in files) {
          final stat = await file.stat();
          final daysDifference = now.difference(stat.modified).inDays;

          // 30일 이상 된 이미지 삭제
          if (daysDifference > 30) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('이미지 정리 실패: $e');
    }
  }
}

// lib/utils/date_utils.dart
class DateUtils {
  static String formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  static String formatDateShort(DateTime date) {
    return '${date.month}/${date.day}';
  }

  static String formatDateWithDay(DateTime date) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.month}월 ${date.day}일 ($weekday)';
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  static String getRelativeDateString(DateTime date) {
    if (isToday(date)) {
      return '오늘';
    } else if (isYesterday(date)) {
      return '어제';
    } else {
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference < 7) {
        return '${difference}일 전';
      } else if (difference < 30) {
        final weeks = (difference / 7).floor();
        return '${weeks}주 전';
      } else if (difference < 365) {
        final months = (difference / 30).floor();
        return '${months}개월 전';
      } else {
        final years = (difference / 365).floor();
        return '${years}년 전';
      }
    }
  }

  static List<DateTime> getDaysInMonth(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    return List.generate(
      lastDay.day,
      (index) => DateTime(year, month, index + 1),
    );
  }

  static int getWeekOfMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    return ((date.day + firstWeekday - 2) / 7).floor() + 1;
  }
}
