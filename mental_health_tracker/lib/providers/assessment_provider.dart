import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'package:intl/intl.dart';

class AssessmentProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _phq9History = [];
  List<Map<String, dynamic>> _gad7History = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get phq9History => _phq9History;
  List<Map<String, dynamic>> get gad7History => _gad7History;

  // PHQ-9 Questions
  static const List<String> phq9Questions = [
    'Minat atau kesenangan yang berkurang dalam melakukan sesuatu',
    'Merasa sedih, tertekan, atau putus asa',
    'Kesulitan tidur atau terlalu banyak tidur',
    'Merasa lelah atau tidak berenergi',
    'Nafsu makan berkurang atau berlebihan',
    'Merasa buruk tentang diri sendiri atau merasa gagal',
    'Kesulitan berkonsentrasi',
    'Bergerak atau berbicara sangat lambat, atau sebaliknya gelisah',
    'Pikiran untuk melukai diri sendiri',
  ];

  // GAD-7 Questions
  static const List<String> gad7Questions = [
    'Merasa gugup, cemas, atau gelisah',
    'Tidak dapat menghentikan atau mengontrol kekhawatiran',
    'Terlalu khawatir tentang berbagai hal',
    'Kesulitan untuk rileks',
    'Sangat gelisah sehingga sulit untuk duduk diam',
    'Mudah terganggu atau mudah marah',
    'Merasa takut seolah-olah sesuatu yang buruk akan terjadi',
  ];

  Future<void> submitPHQ9(String userId, List<int> answers) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final totalScore = answers.reduce((a, b) => a + b);
      final severity = _getPHQ9Severity(totalScore);
      final now = DateTime.now();

      final assessment = {
        'user_id': userId,
        'date': DateFormat('yyyy-MM-dd').format(now),
        'q1': answers[0],
        'q2': answers[1],
        'q3': answers[2],
        'q4': answers[3],
        'q5': answers[4],
        'q6': answers[5],
        'q7': answers[6],
        'q8': answers[7],
        'q9': answers[8],
        'total_score': totalScore,
        'severity': severity,
        'timestamp': now.toIso8601String(),
      };

      await DatabaseHelper.instance.insertPHQ9(assessment);
      await loadPHQ9History(userId);

    } catch (e) {
      _errorMessage = 'Error menyimpan PHQ-9: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> submitGAD7(String userId, List<int> answers) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final totalScore = answers.reduce((a, b) => a + b);
      final severity = _getGAD7Severity(totalScore);
      final now = DateTime.now();

      final assessment = {
        'user_id': userId,
        'date': DateFormat('yyyy-MM-dd').format(now),
        'q1': answers[0],
        'q2': answers[1],
        'q3': answers[2],
        'q4': answers[3],
        'q5': answers[4],
        'q6': answers[5],
        'q7': answers[6],
        'total_score': totalScore,
        'severity': severity,
        'timestamp': now.toIso8601String(),
      };

      await DatabaseHelper.instance.insertGAD7(assessment);
      await loadGAD7History(userId);

    } catch (e) {
      _errorMessage = 'Error menyimpan GAD-7: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPHQ9History(String userId) async {
    try {
      _phq9History = await DatabaseHelper.instance.getPHQ9Assessments(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading PHQ-9: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> loadGAD7History(String userId) async {
    try {
      _gad7History = await DatabaseHelper.instance.getGAD7Assessments(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading GAD-7: ${e.toString()}';
      notifyListeners();
    }
  }

  String _getPHQ9Severity(int score) {
    if (score <= 4) return 'Minimal';
    if (score <= 9) return 'Ringan';
    if (score <= 14) return 'Sedang';
    if (score <= 19) return 'Sedang-Berat';
    return 'Berat';
  }

  String _getGAD7Severity(int score) {
    if (score <= 4) return 'Minimal';
    if (score <= 9) return 'Ringan';
    if (score <= 14) return 'Sedang';
    return 'Berat';
  }

  Color getSeverityColor(String severity) {
    switch (severity) {
      case 'Minimal':
        return Colors.green;
      case 'Ringan':
        return Colors.lightGreen;
      case 'Sedang':
        return Colors.orange;
      case 'Sedang-Berat':
        return Colors.deepOrange;
      case 'Berat':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}