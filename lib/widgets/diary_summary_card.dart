// lib/widgets/diary_summary_card.dart
import 'dart:io';
import 'package:daily_mood/models/mood_type.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';

class DiarySummaryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback? onTap;
  final bool showDate;
  final bool isCompact;

  const DiarySummaryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.showDate = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          child: isCompact
              ? _buildCompactLayout(context)
              : _buildFullLayout(context),
        ),
      ),
    );
  }

  Widget _buildFullLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 12),
        _buildContent(context),
        if (entry.imagePath != null) ...[
          const SizedBox(height: 12),
          _buildImage(),
        ],
        if (entry.weather != null) ...[
          const SizedBox(height: 12),
          _buildWeatherInfo(context),
        ],
      ],
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 기분 아이콘
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: entry.mood.color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: entry.mood.color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(entry.mood.emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(width: 12),
        // 내용
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDate)
                Text(
                  DateFormat('M월 d일').format(entry.date),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              Text(
                entry.title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                entry.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // 첨부 표시
        if (entry.imagePath != null)
          Container(
            margin: const EdgeInsets.only(left: 8),
            child: Icon(Icons.image, size: 16, color: Colors.grey[500]),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // 기분 아이콘
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: entry.mood.color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: entry.mood.color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(entry.mood.emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(width: 12),
        // 제목 및 날짜
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  if (showDate) ...[
                    Text(
                      DateFormat('yyyy년 M월 d일').format(entry.date),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    entry.mood.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: entry.mood.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // 편집 아이콘
        Icon(Icons.chevron_right, color: Colors.grey[400]),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(
        entry.content,
        style: Theme.of(context).textTheme.bodyMedium,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: entry.imagePath != null
            ? Image.file(
                File(entry.imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 32,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '이미지를 불러올 수 없습니다',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(Icons.image, size: 32, color: Colors.grey[500]),
                ),
              ),
      ),
    );
  }

  Widget _buildWeatherInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getWeatherIcon(), size: 16, color: Colors.blue[600]),
          const SizedBox(width: 4),
          Text(
            '${entry.weather!.description} ${entry.weather!.temperatureString}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.blue[600]),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon() {
    final description = entry.weather?.description.toLowerCase() ?? '';

    if (description.contains('맑')) {
      return Icons.wb_sunny;
    } else if (description.contains('구름') || description.contains('흐림')) {
      return Icons.cloud;
    } else if (description.contains('비')) {
      return Icons.umbrella;
    } else if (description.contains('눈')) {
      return Icons.ac_unit;
    } else {
      return Icons.wb_cloudy;
    }
  }
}
