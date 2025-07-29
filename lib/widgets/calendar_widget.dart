// lib/widgets/calendar_widget.dart
import 'package:daily_mood/models/mood_type.dart';
import 'package:flutter/material.dart';

import '../models/diary_entry.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final List<DiaryEntry> diaryEntries;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;

  const CalendarWidget({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.diaryEntries,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildWeekdayHeaders(context),
            const SizedBox(height: 8),
            _buildCalendarGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];

    return Row(
      children: weekdays.map((weekday) {
        return Expanded(
          child: Center(
            child: Text(
              weekday,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(
      focusedMonth.year,
      focusedMonth.month + 1,
      0,
    );
    final firstDayWeekday = firstDayOfMonth.weekday;

    // 달력에 표시할 날짜들 생성
    final dates = <DateTime?>[];

    // 이전 달의 마지막 날들 (빈 공간)
    for (int i = 1; i < firstDayWeekday; i++) {
      dates.add(null);
    }

    // 현재 달의 날들
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      dates.add(DateTime(focusedMonth.year, focusedMonth.month, day));
    }

    // 6주 * 7일 = 42칸이 되도록 맞춤
    while (dates.length < 42) {
      dates.add(null);
    }

    return Column(
      children: List.generate(6, (weekIndex) {
        return Row(
          children: List.generate(7, (dayIndex) {
            final dateIndex = weekIndex * 7 + dayIndex;
            final date = dates[dateIndex];

            if (date == null) {
              return const Expanded(child: SizedBox(height: 48));
            }

            return Expanded(child: _buildDateCell(context, date));
          }),
        );
      }),
    );
  }

  Widget _buildDateCell(BuildContext context, DateTime date) {
    final isSelected = _isSameDay(date, selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    final entry = _getEntryForDate(date);
    final hasEntry = entry != null;
    final isCurrentMonth = date.month == focusedMonth.month;

    return GestureDetector(
      onTap: isCurrentMonth ? () => onDateSelected(date) : null,
      child: Container(
        height: 48,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : isToday
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isSelected
              ? Border.all(color: Theme.of(context).colorScheme.primary)
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isCurrentMonth
                      ? null
                      : Colors.grey[400],
                  fontWeight: isToday ? FontWeight.bold : null,
                ),
              ),
            ),
            if (hasEntry)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : entry.mood.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  DiaryEntry? _getEntryForDate(DateTime date) {
    try {
      return diaryEntries.firstWhere((entry) => _isSameDay(entry.date, date));
    } catch (e) {
      return null;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
