// lib/screens/write_diary_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/diary_entry.dart';
import '../models/mood_type.dart';
import '../providers/diary_provider.dart';
import '../services/weather_service.dart';
import '../services/image_service.dart';
import '../widgets/mood_selector.dart';

class WriteDiaryScreen extends StatefulWidget {
  final DiaryEntry? entryToEdit;

  const WriteDiaryScreen({super.key, this.entryToEdit});

  @override
  State<WriteDiaryScreen> createState() => _WriteDiaryScreenState();
}

class _WriteDiaryScreenState extends State<WriteDiaryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imagePicker = ImagePicker();

  MoodType _selectedMood = MoodType.neutral;
  File? _selectedImage;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isLoadingWeather = false;

  bool get _isEditing => widget.entryToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _initializeForEditing();
    }
    _loadWeatherData();
  }

  void _initializeForEditing() {
    final entry = widget.entryToEdit!;
    _titleController.text = entry.title;
    _contentController.text = entry.content;
    _selectedMood = entry.mood;
    _selectedDate = entry.date;

    if (entry.imagePath != null) {
      _selectedImage = File(entry.imagePath!);
    }
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoadingWeather = true;
    });

    try {
      // WeatherService로 날씨 데이터 로드 (구현 예정)
      // 현재는 더미 데이터 사용
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      // 날씨 로드 실패는 무시 (선택적 기능)
    } finally {
      setState(() {
        _isLoadingWeather = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '일기 수정' : '일기 쓰기'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteDialog,
            ),
          TextButton(
            onPressed: _isLoading ? null : _saveDiary,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('저장'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateSelector(),
                const SizedBox(height: 20),
                _buildTitleField(),
                const SizedBox(height: 20),
                _buildMoodSelector(),
                const SizedBox(height: 20),
                _buildContentField(),
                const SizedBox(height: 20),
                _buildImageSection(),
                const SizedBox(height: 20),
                _buildWeatherSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: const Text('날짜'),
        subtitle: Text(
          '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: _selectDate,
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: '제목',
        hintText: '오늘 하루를 한 줄로 표현해보세요',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '제목을 입력해주세요';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 기분',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        MoodSelector(
          selectedMood: _selectedMood,
          onMoodChanged: (mood) {
            setState(() {
              _selectedMood = mood;
            });
          },
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      decoration: const InputDecoration(
        labelText: '내용',
        hintText: '오늘 있었던 일이나 느낀 점을 자유롭게 적어보세요',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: 8,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '내용을 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사진',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_selectedImage != null) ...[
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: FileImage(_selectedImage!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.edit),
                  label: const Text('사진 변경'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('사진 삭제'),
                ),
              ),
            ],
          ),
        ] else ...[
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
              color: Colors.grey[50],
            ),
            child: InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '사진 추가',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWeatherSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.wb_sunny_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '날씨 정보',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (_isLoadingWeather)
                    const Text('날씨 정보를 불러오는 중...')
                  else
                    const Text('맑음, 22°C'), // 더미 데이터
                ],
              ),
            ),
            IconButton(
              onPressed: _isLoadingWeather ? null : _loadWeatherData,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이미지를 선택할 수 없습니다: $e')));
    }
  }

  Future<void> _saveDiary() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      String? imagePath;

      // 새로운 이미지가 선택되었다면 저장
      if (_selectedImage != null) {
        // 기존 이미지와 다른 경우에만 새로 저장
        if (!_isEditing ||
            widget.entryToEdit!.imagePath != _selectedImage!.path) {
          imagePath = await ImageService.saveImage(_selectedImage!);
        } else {
          imagePath = _selectedImage!.path;
        }
      }

      // 기존 이미지 삭제 (편집 시 이미지가 변경된 경우)
      if (_isEditing &&
          widget.entryToEdit!.imagePath != null &&
          widget.entryToEdit!.imagePath != imagePath) {
        await ImageService.deleteImage(widget.entryToEdit!.imagePath!);
      }

      final entry = DiaryEntry(
        id: _isEditing ? widget.entryToEdit!.id : null,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        date: _selectedDate,
        mood: _selectedMood,
        imagePath: imagePath,
        weather: null, // WeatherService 구현 후 추가
        createdAt: _isEditing ? widget.entryToEdit!.createdAt : now,
        updatedAt: now,
      );

      final diaryProvider = context.read<DiaryProvider>();
      bool success;

      if (_isEditing) {
        success = await diaryProvider.updateDiaryEntry(entry);
      } else {
        success = await diaryProvider.addDiaryEntry(entry);
      }

      if (success) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_isEditing ? '일기가 수정되었습니다' : '일기가 저장되었습니다')),
          );
        }
      } else {
        // 저장 실패 시 새로 저장한 이미지 삭제
        if (imagePath != null && !_isEditing) {
          await ImageService.deleteImage(imagePath);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(diaryProvider.error ?? '저장 중 오류가 발생했습니다'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showDeleteDialog() async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일기 삭제'),
        content: const Text('정말로 이 일기를 삭제하시겠습니까?\n삭제된 일기는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() {
        _isLoading = true;
      });

      final success = await context.read<DiaryProvider>().deleteDiaryEntry(
        widget.entryToEdit!.id!,
      );

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('일기가 삭제되었습니다')));
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('삭제 중 오류가 발생했습니다'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
