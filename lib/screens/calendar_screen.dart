// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../models/mood_type.dart';
import '../providers/diary_provider.dart';
import '../screens/write_diary_screen.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/diary_summary_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMonthData();
    });
  }

  void _loadMonthData() {
    context.read<DiaryProvider>().loadDiaryEntriesByMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat('yyyy년 M월').format(_focusedMonth),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              final today = DateTime.now();
              setState(() {
                _selectedDate = today;
                _focusedMonth = DateTime(today.year, today.month);
              });
              _loadMonthData();
            },
          ),
        ],
      ),
      body: Consumer<DiaryProvider>(
        builder: (context, diaryProvider, child) {
          if (diaryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildMonthNavigation(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CalendarWidget(
                        focusedMonth: _focusedMonth,
                        selectedDate: _selectedDate,
                        diaryEntries: diaryProvider.diaryEntries,
                        onDateSelected: (date) {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                        onMonthChanged: (date) {
                          setState(() {
                            _focusedMonth = date;
                          });
                          _loadMonthData();
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildSelectedDateSection(diaryProvider),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WriteDiaryScreen(
                // 선택된 날짜로 일기 작성
                entryToEdit: _getEntryForDate(_selectedDate),
              ),
            ),
          ).then((_) => _loadMonthData());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                );
              });
              _loadMonthData();
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            DateFormat('yyyy년 M월').format(_focusedMonth),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () {
              final nextMonth = DateTime(
                _focusedMonth.year,
                _focusedMonth.month + 1,
              );
              final now = DateTime.now();

              // 미래 월로는 이동하지 않음
              if (nextMonth.isBefore(DateTime(now.year, now.month + 1))) {
                setState(() {
                  _focusedMonth = nextMonth;
                });
                _loadMonthData();
              }
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateSection(DiaryProvider provider) {
    final entry = _getEntryForDate(_selectedDate);
    final isToday = _isToday(_selectedDate);
    final isPast = _selectedDate.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isToday ? Icons.today : Icons.calendar_today,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                _formatSelectedDate(),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (entry != null) ...[
            DiarySummaryCard(
              entry: entry,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WriteDiaryScreen(entryToEdit: entry),
                  ),
                ).then((_) => _loadMonthData());
              },
            ),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.edit_note_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isToday
                          ? '오늘의 일기를 작성해보세요!'
                          : isPast
                          ? '이 날의 일기가 없습니다'
                          : '미래의 일기는 작성할 수 없습니다',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    if (isToday || isPast) ...[
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WriteDiaryScreen(),
                            ),
                          ).then((_) => _loadMonthData());
                        },
                        child: Text(isToday ? '오늘 일기 쓰기' : '일기 쓰기'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  DiaryEntry? _getEntryForDate(DateTime date) {
    final provider = context.read<DiaryProvider>();
    try {
      return provider.diaryEntries.firstWhere(
        (entry) => _isSameDay(entry.date, date),
      );
    } catch (e) {
      return null;
    }
  }

  String _formatSelectedDate() {
    final now = DateTime.now();

    if (_isSameDay(_selectedDate, now)) {
      return '오늘 (${DateFormat('M월 d일').format(_selectedDate)})';
    } else if (_isSameDay(
      _selectedDate,
      now.subtract(const Duration(days: 1)),
    )) {
      return '어제 (${DateFormat('M월 d일').format(_selectedDate)})';
    } else {
      final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
      final weekday = weekdays[_selectedDate.weekday - 1];
      return '${DateFormat('M월 d일').format(_selectedDate)} ($weekday)';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isToday(DateTime date) {
    return _isSameDay(date, DateTime.now());
  }
}
