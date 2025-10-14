import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/database_helper.dart';
import 'package:intl/intl.dart';

class HealthProvider with ChangeNotifier {
  final Health _health = Health();
  bool _isAuthorized = false;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? _todayHealthData;
  List<Map<String, dynamic>> _weeklyHealthData = [];

  bool get isAuthorized => _isAuthorized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get todayHealthData => _todayHealthData;
  List<Map<String, dynamic>> get weeklyHealthData => _weeklyHealthData;

  final List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
  ];

  Future<bool> requestAuthorization() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final activityStatus = await Permission.activityRecognition.request();

      if (!activityStatus.isGranted) {
        _errorMessage = 'Izin Activity Recognition diperlukan';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      bool authorized = await _health.requestAuthorization(_types);

      _isAuthorized = authorized;

      if (!authorized) {
        _errorMessage = 'Akses ke Health Connect ditolak';
      }

    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isAuthorized = false;
    }

    _isLoading = false;
    notifyListeners();
    return _isAuthorized;
  }

  Future<void> syncHealthData(String userId) async {
    if (!_isAuthorized) {
      _errorMessage = 'Health Connect belum diotorisasi';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: startOfDay,
        endTime: now,
        types: _types,
      );

      int steps = 0;
      List<double> heartRates = [];
      double sleepHours = 0;

      for (var point in healthData) {
        if (point.value is NumericHealthValue) {
            final value = (point.value as NumericHealthValue).numericValue;
            if (point.type == HealthDataType.STEPS) {
              steps += value.toInt();
            } else if (point.type == HealthDataType.HEART_RATE) {
              heartRates.add(value.toDouble());
            } else if (point.type == HealthDataType.SLEEP_ASLEEP) {
              sleepHours += value.toDouble() / 60; // Convert minutes to hours
            }
        }
      }

      double avgHeartRate = heartRates.isNotEmpty
          ? heartRates.reduce((a, b) => a + b) / heartRates.length
          : 0;

      _todayHealthData = {
        'steps': steps,
        'avg_heart_rate': avgHeartRate.round(),
        'sleep_hours': sleepHours.toStringAsFixed(1),
      };

      await DatabaseHelper.instance.insertHealthData({
        'user_id': userId,
        'date': DateFormat('yyyy-MM-dd').format(now),
        'steps': steps,
        'avg_heart_rate': avgHeartRate,
        'sleep_duration': sleepHours,
        'timestamp': now.toIso8601String(),
      });

      await loadWeeklyHealthData(userId);

    } catch (e) {
      _errorMessage = 'Error sinkronisasi: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadWeeklyHealthData(String userId) async {
    try {
      final data = await DatabaseHelper.instance.getHealthData(userId, limit: 7);
      _weeklyHealthData = data;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading data: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> syncPastWeekData(String userId) async {
    if (!_isAuthorized) return;

    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();

      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(hours: 23, minutes: 59));

        List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
          startTime: startOfDay,
          endTime: endOfDay,
          types: _types,
        );

        int steps = 0;
        List<double> heartRates = [];
        double sleepHours = 0;

        for (var point in healthData) {
            if (point.value is NumericHealthValue) {
                final value = (point.value as NumericHealthValue).numericValue;
                if (point.type == HealthDataType.STEPS) {
                    steps += value.toInt();
                } else if (point.type == HealthDataType.HEART_RATE) {
                    heartRates.add(value.toDouble());
                } else if (point.type == HealthDataType.SLEEP_ASLEEP) {
                    sleepHours += value.toDouble() / 60; // Convert minutes to hours
                }
            }
        }

        double avgHeartRate = heartRates.isNotEmpty
            ? heartRates.reduce((a, b) => a + b) / heartRates.length
            : 0;

        await DatabaseHelper.instance.insertHealthData({
          'user_id': userId,
          'date': DateFormat('yyyy-MM-dd').format(date),
          'steps': steps,
          'avg_heart_rate': avgHeartRate,
          'sleep_duration': sleepHours,
          'timestamp': date.toIso8601String(),
        });
      }

      await loadWeeklyHealthData(userId);

    } catch (e) {
      _errorMessage = 'Error syncing past data: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }
}
