// lib/screens/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/mood_type.dart';
import '../providers/diary_provider.dart';
import '../widgets/mood_chart.dart';
import '../widgets/statistic_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final statsProvider = context.read<StatisticsProvider>();
    if (_tabController.index == 0) {
      statsProvider.loadMoodStatistics();
    } else {
      statsProvider.loadMoodStatisticsByMonth(
        _selectedMonth.year,
        _selectedMonth.month,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('통계', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => _loadData(),
          tabs: const [
            Tab(text: '전체 통계'),
            Tab(text: '월별 통계'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOverallStatistics(), _buildMonthlyStatistics()],
      ),
    );
  }

  Widget _buildOverallStatistics() {
    return Consumer2<StatisticsProvider, DiaryProvider>(
      builder: (context, statsProvider, diaryProvider, child) {
        if (statsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (statsProvider.error != null) {
          return _buildErrorWidget(statsProvider.error!, () {
            statsProvider.clearError();
            statsProvider.loadMoodStatistics();
          });
        }

        final moodStats = statsProvider.moodStatistics;
        final totalEntries = statsProvider.totalEntries;
        final mostFrequentMood = statsProvider.mostFrequentMood;

        if (totalEntries == 0) {
          return _buildEmptyState('아직 작성된 일기가 없습니다\n첫 번째 일기를 작성해보세요!');
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCards(totalEntries, mostFrequentMood),
              const SizedBox(height: 24),
              _buildSectionTitle('기분 분포'),
              const SizedBox(height: 16),
              MoodChart(moodData: moodStats),
              const SizedBox(height: 16),
              MoodLegend(moodData: moodStats),
              const SizedBox(height: 24),
              _buildSectionTitle('상세 통계'),
              const SizedBox(height: 16),
              _buildDetailedStats(moodStats, totalEntries),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthlyStatistics() {
    return Consumer<StatisticsProvider>(
      builder: (context, statsProvider, child) {
        return Column(
          children: [
            _buildMonthSelector(),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (statsProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (statsProvider.error != null) {
                    return _buildErrorWidget(statsProvider.error!, () {
                      statsProvider.clearError();
                      statsProvider.loadMoodStatisticsByMonth(
                        _selectedMonth.year,
                        _selectedMonth.month,
                      );
                    });
                  }

                  final moodStats = statsProvider.moodStatistics;
                  final totalEntries = statsProvider.totalEntries;

                  if (totalEntries == 0) {
                    return _buildEmptyState(
                      '${DateFormat('yyyy년 M월').format(_selectedMonth)}에\n작성된 일기가 없습니다',
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMonthlyOverview(totalEntries),
                        const SizedBox(height: 24),
                        _buildSectionTitle('이번 달 기분 분포'),
                        const SizedBox(height: 16),
                        MoodChart(moodData: moodStats),
                        const SizedBox(height: 16),
                        MoodLegend(moodData: moodStats),
                        const SizedBox(height: 24),
                        _buildMonthlyInsights(moodStats, totalEntries),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month - 1,
                );
              });
              _loadData();
            },
            icon: const Icon(Icons.chevron_left),
          ),
          InkWell(
            onTap: _showMonthPicker,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                DateFormat('yyyy년 M월').format(_selectedMonth),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              final nextMonth = DateTime(
                _selectedMonth.year,
                _selectedMonth.month + 1,
              );
              final now = DateTime.now();

              if (nextMonth.isBefore(DateTime(now.year, now.month + 1))) {
                setState(() {
                  _selectedMonth = nextMonth;
                });
                _loadData();
              }
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(int totalEntries, MoodType? mostFrequentMood) {
    return Row(
      children: [
        Expanded(
          child: StatisticsCard(
            title: '총 일기 수',
            value: '$totalEntries개',
            icon: Icons.book,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatisticsCard(
            title: '주요 기분',
            value: mostFrequentMood?.label ?? '-',
            icon: Icons.sentiment_satisfied,
            color: mostFrequentMood?.color ?? Colors.grey,
            emoji: mostFrequentMood?.emoji,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyOverview(int totalEntries) {
    final daysInMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    ).day;
    final completionRate = (totalEntries / daysInMonth * 100).round();

    return Row(
      children: [
        Expanded(
          child: StatisticsCard(
            title: '이번 달 일기',
            value: '$totalEntries개',
            icon: Icons.edit_calendar,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatisticsCard(
            title: '작성률',
            value: '$completionRate%',
            icon: Icons.pie_chart,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedStats(Map<MoodType, int> moodStats, int totalEntries) {
    return Column(
      children: MoodType.values.map((mood) {
        final count = moodStats[mood] ?? 0;
        final percentage = totalEntries > 0
            ? (count / totalEntries * 100)
            : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: StatisticsCard(
            title: mood.label,
            value: '${count}회 (${percentage.toStringAsFixed(1)}%)',
            color: mood.color,
            emoji: mood.emoji,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthlyInsights(Map<MoodType, int> moodStats, int totalEntries) {
    final sortedMoods = moodStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이번 달 인사이트',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (sortedMoods.isNotEmpty) ...[
              _buildInsightItem(
                '가장 많이 느낀 기분',
                '${sortedMoods.first.key.emoji} ${sortedMoods.first.key.label} (${sortedMoods.first.value}회)',
              ),
              if (sortedMoods.length > 1)
                _buildInsightItem(
                  '두 번째로 많이 느낀 기분',
                  '${sortedMoods[1].key.emoji} ${sortedMoods[1].key.label} (${sortedMoods[1].value}회)',
                ),
              _buildInsightItem('전체 평균 대비', _getComparisonText()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }

  Future<void> _showMonthPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
      _loadData();
    }
  }

  String _getComparisonText() {
    // 간단한 비교 텍스트 (실제로는 더 복잡한 로직 필요)
    return '이번 달은 평소보다 좋은 기분이었어요! 😊';
  }
}
