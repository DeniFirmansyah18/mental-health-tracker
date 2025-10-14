import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'package:intl/intl.dart';

class MoodProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _moodHistory = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get moodHistory => _moodHistory;

  static const List<Map<String, dynamic>> moodOptions = [
    {'level': 5, 'emoji': '😄', 'label': 'Sangat Baik', 'color': Color(0xFF4CAF50)},
    {'level': 4, 'emoji': '😊', 'label': 'Baik', 'color': Color(0xFF8BC34A)},
    {'level': 3, 'emoji': '😐', 'label': 'Normal', 'color': Color(0xFFFFEB3B)},
    {'level': 2, 'emoji': '😔', 'label': 'Kurang Baik', 'color': Color(0xFFFF9800)},
    {'level': 1, 'emoji': '😢', 'label': 'Buruk', 'color': Color(0xFFF44336)},
  ];

  Future<void> submitMood(String userId, int moodLevel, String moodEmoji, String? notes) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final entry = {
        'user_id': userId,
        'date': DateFormat('yyyy-MM-dd').format(now),
        'mood_level': moodLevel,
        'mood_emoji': moodEmoji,
        'notes': notes ?? '',
        'timestamp': now.toIso8601String(),
      };

      await DatabaseHelper.instance.insertMoodEntry(entry);
      await loadMoodHistory(userId);

    } catch (e) {
      _errorMessage = 'Error menyimpan mood: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoodHistory(String userId, {int? limit}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _moodHistory = await DatabaseHelper.instance.getMoodEntries(userId, limit: limit);
    } catch (e) {
      _errorMessage = 'Error loading mood: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Map<String, dynamic> getMoodStats(List<Map<String, dynamic>> moods) {
    if (moods.isEmpty) {
      return {
        'average': 0.0,
        'mostFrequent': null,
        'trend': 'stable',
      };
    }

    // Calculate average
    final average = moods.map((m) => m['mood_level'] as int).reduce((a, b) => a + b) / moods.length;

    // Find most frequent mood
    final moodCounts = <int, int>{};
    for (var mood in moods) {
      final level = mood['mood_level'] as int;
      moodCounts[level] = (moodCounts[level] ?? 0) + 1;
    }
    final mostFrequent = moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Calculate trend (comparing first half vs second half)
    String trend = 'stable';
    if (moods.length >= 4) {
      final half = moods.length ~/ 2;
      final firstHalf = moods.sublist(0, half).map((m) => m['mood_level'] as int).reduce((a, b) => a + b) / half;
      final secondHalf = moods.sublist(half).map((m) => m['mood_level'] as int).reduce((a, b) => a + b) / (moods.length - half);

      if (secondHalf > firstHalf + 0.5) trend = 'improving';
      if (secondHalf < firstHalf - 0.5) trend = 'declining';
    }

    return {
      'average': average,
      'mostFrequent': mostFrequent,
      'trend': trend,
    };
  }

  Color getMoodColor(int level) {
    return moodOptions.firstWhere((m) => m['level'] == level)['color'] as Color;
  }

  String getMoodEmoji(int level) {
    return moodOptions.firstWhere((m) => m['level'] == level)['emoji'] as String;
  }

  String getMoodLabel(int level) {
    return moodOptions.firstWhere((m) => m['level'] == level)['label'] as String;
  }
}