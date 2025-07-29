// lib/widgets/mood_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/mood_type.dart';

class MoodChart extends StatelessWidget {
  final Map<MoodType, int> moodData;
  final double height;

  const MoodChart({super.key, required this.moodData, this.height = 200});

  @override
  Widget build(BuildContext context) {
    if (moodData.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                '아직 통계 데이터가 없습니다',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: PieChart(
        PieChartData(
          sections: _createSections(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  List<PieChartSectionData> _createSections() {
    final total = moodData.values.fold(0, (sum, count) => sum + count);

    return moodData.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        color: entry.key.color,
        title: '${percentage.toStringAsFixed(1)}%',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 60,
      );
    }).toList();
  }
}

// lib/widgets/mood_legend.dart
class MoodLegend extends StatelessWidget {
  final Map<MoodType, int> moodData;

  const MoodLegend({super.key, required this.moodData});

  @override
  Widget build(BuildContext context) {
    if (moodData.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = moodData.values.fold(0, (sum, count) => sum + count);

    return Column(
      children: moodData.entries.map((entry) {
        final percentage = total > 0 ? (entry.value / total * 100) : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: entry.key.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(entry.key.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key.label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                '${entry.value}회 (${percentage.toStringAsFixed(1)}%)',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
