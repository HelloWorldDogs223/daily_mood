// lib/widgets/mood_trend_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/mood_type.dart';

class MoodTrendChart extends StatelessWidget {
  final List<MoodTrendData> data;
  final double height;

  const MoodTrendChart({super.key, required this.data, this.height = 200});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            '트렌드 데이터가 없습니다',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() < data.length) {
                    return Text(
                      '${data[value.toInt()].date.day}',
                      style: const TextStyle(fontSize: 12),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text('😭', style: TextStyle(fontSize: 16));
                    case 1:
                      return const Text('😢', style: TextStyle(fontSize: 16));
                    case 2:
                      return const Text('😐', style: TextStyle(fontSize: 16));
                    case 3:
                      return const Text('😊', style: TextStyle(fontSize: 16));
                    case 4:
                      return const Text('😄', style: TextStyle(fontSize: 16));
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey[300]!),
          ),
          minX: 0,
          maxX: data.length.toDouble() - 1,
          minY: 0,
          maxY: 4,
          lineBarsData: [
            LineChartBarData(
              spots: data
                  .asMap()
                  .entries
                  .map(
                    (entry) => FlSpot(
                      entry.key.toDouble(),
                      entry.value.moodValue.toDouble(),
                    ),
                  )
                  .toList(),
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: data[index].mood.color,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoodTrendData {
  final DateTime date;
  final MoodType mood;
  final int moodValue;

  MoodTrendData({required this.date, required this.mood})
    : moodValue = mood.index;
}
