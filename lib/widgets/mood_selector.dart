// lib/widgets/mood_selector.dart
import 'package:flutter/material.dart';
import '../models/mood_type.dart';

class MoodSelector extends StatefulWidget {
  final MoodType selectedMood;
  final ValueChanged<MoodType> onMoodChanged;
  final bool isCompact;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodChanged,
    this.isCompact = false,
  });

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCompact) {
      return _buildCompactSelector();
    }
    return _buildFullSelector();
  }

  Widget _buildFullSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: MoodType.values
                  .map(
                    (mood) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildMoodItem(mood),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.selectedMood.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.selectedMood.color.withOpacity(0.3),
              ),
            ),
            child: Text(
              widget.selectedMood.label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.selectedMood.color.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: MoodType.values
            .map(
              (mood) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildMoodItem(mood, isCompact: true),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildMoodItem(MoodType mood, {bool isCompact = false}) {
    final isSelected = widget.selectedMood == mood;
    final size = isCompact ? 40.0 : 60.0;
    final emojiSize = isCompact ? 20.0 : 28.0;

    return GestureDetector(
      onTap: () {
        widget.onMoodChanged(mood);
        if (isSelected) {
          _animationController.forward().then((_) {
            _animationController.reverse();
          });
        }
        _triggerHapticFeedback();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? _scaleAnimation.value : 1.0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? mood.color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? mood.color : Colors.grey[300]!,
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: mood.color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(mood.emoji, style: TextStyle(fontSize: emojiSize)),
              ),
            ),
          );
        },
      ),
    );
  }

  void _triggerHapticFeedback() {
    // HapticFeedback.lightImpact(); // 필요시 주석 해제
  }
}
