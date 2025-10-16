import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_helper.dart'; // Pastikan path ini benar
import 'package:intl/intl.dart';

enum HealthDataViewMode { today, week }

class HealthProvider with ChangeNotifier {
  final Health _health = Health();
  bool _isAuthorized = false;
  bool _isLoading = false;
  String? _errorMessage;

  HealthDataViewMode _viewMode = HealthDataViewMode.week;
  HealthDataViewMode get viewMode => _viewMode;

  // Data hari ini (dari sinkronisasi terbaru)
  Map<String, dynamic>? _todayHealthData;
  // Data mingguan (untuk grafik di home dan detail mingguan)
  List<Map<String, dynamic>> _weeklyHealthData = [];

  // Data terstruktur untuk grafik mingguan (tetap dipertahankan)
  List<int> _weeklySteps = [];
  List<double> _weeklySleep = [];
  List<int> _weeklyHeartRates = [];

  bool get isAuthorized => _isAuthorized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get todayHealthData => _todayHealthData;
  List<Map<String, dynamic>> get weeklyHealthData => _weeklyHealthData;

  List<int> get weeklySteps => _weeklySteps;
  List<double> get weeklySleep => _weeklySleep;
  List<int> get weeklyHeartRates => _weeklyHeartRates;

  final List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_REM,
  ];

  final List<HealthDataType> _permissionTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
  ];

  HealthProvider() {
    _checkAuthorizationStatus();
  }

  Future<void> _checkAuthorizationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuth = prefs.getBool('health_authorized') ?? false;

      if (isAuth) {
        bool hasPermission = await _health.hasPermissions(_permissionTypes) ?? false;
        _isAuthorized = hasPermission;

        if (!hasPermission) {
          await prefs.remove('health_authorized');
          _isAuthorized = false;
        }
      }

      notifyListeners();
    } catch (e) {
      print('Error checking authorization: $e');
    }
  }

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

      bool hasPermission = await _health.hasPermissions(_permissionTypes) ?? false;

      if (!hasPermission) {
        bool authorized = await _health.requestAuthorization(_permissionTypes);
        _isAuthorized = authorized;

        if (authorized) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('health_authorized', true);
        } else {
          _errorMessage = 'Akses ke Health Connect ditolak';
        }
      } else {
        _isAuthorized = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('health_authorized', true);
      }

    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isAuthorized = false;
    }

    _isLoading = false;
    notifyListeners();
    return _isAuthorized;
  }

  // Fungsi sinkronisasi data HARI INI
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

      print('📊 Total data points fetched: ${healthData.length}');

      Map<String, HealthDataPoint> uniqueData = {};
      for (var point in healthData) {
        String key = '${point.type}_${point.dateFrom}_${point.value}';
        uniqueData[key] = point;
      }

      print('📊 Unique data points: ${uniqueData.length}');

      int steps = 0;
      List<double> heartRates = [];
      double sleepMinutes = 0;

      for (var point in uniqueData.values) {
        switch (point.type) {
          case HealthDataType.STEPS:
            if (point.value is NumericHealthValue) {
              steps += (point.value as NumericHealthValue).numericValue.toInt();
            }
            break;
          case HealthDataType.HEART_RATE:
            if (point.value is NumericHealthValue) {
              heartRates.add((point.value as NumericHealthValue).numericValue.toDouble());
            }
            break;
          case HealthDataType.SLEEP_LIGHT:
          case HealthDataType.SLEEP_DEEP:
          case HealthDataType.SLEEP_REM:
            final duration = point.dateTo.difference(point.dateFrom).inMinutes;
            sleepMinutes += duration.toDouble();
            break;
          default:
            break;
        }
      }

      double sleepHours = sleepMinutes / 60;

      double avgHeartRate = heartRates.isNotEmpty
          ? heartRates.reduce((a, b) => a + b) / heartRates.length
          : 0;

      // SIMPAN DATA HARI INI KE VARIABEL PROVIDER
      _todayHealthData = {
        'steps': steps,
        'avg_heart_rate': avgHeartRate.round(),
        'sleep_hours': sleepHours.toStringAsFixed(1),
      };

      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final existingData = await DatabaseHelper.instance.getHealthDataByDate(userId, dateStr);

      if (existingData != null) {
        print('🔄 Updating existing data for $dateStr');
        await DatabaseHelper.instance.updateHealthData(
          existingData['id'],
          {
            'steps': steps,
            'avg_heart_rate': avgHeartRate,
            'sleep_duration': sleepHours,
            'timestamp': now.toIso8601String(),
          },
        );
      } else {
        print('➕ Inserting new data for $dateStr');
        await DatabaseHelper.instance.insertHealthData({
          'user_id': userId,
          'date': dateStr,
          'steps': steps,
          'avg_heart_rate': avgHeartRate,
          'sleep_duration': sleepHours,
          'timestamp': now.toIso8601String(),
        });
      }

      // Perbarui hanya data hari ini di UI
      await loadTodayHealthData(userId);

    } catch (e) {
      _errorMessage = 'Error sinkronisasi: ${e.toString()}';
      print('❌ Sync error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fungsi untuk memuat data HARI INI dari DB ke _weeklyHealthData
  Future<void> loadTodayHealthData(String userId) async {
    _viewMode = HealthDataViewMode.today;
    try {
      final todayData = await getTodayDataFromDb(userId);
      if (todayData != null) {
        _weeklyHealthData = [todayData];
      } else {
        _weeklyHealthData = [];
      }
      _updateWeeklyChartData(); // Panggil fungsi ini untuk memperbarui data grafik
      notifyListeners();
    } catch (e) {
      _errorMessage = "Error loading today's data: ${e.toString()}";
      print("❌ Error loading today's data: $e");
      notifyListeners();
    }
  }


  // Fungsi untuk memuat data MINGGUAN dari DB
  Future<void> loadWeeklyHealthData(String userId) async {
    _viewMode = HealthDataViewMode.week;
    try {
      // 1. Ambil data dari DB
      final rawData = await DatabaseHelper.instance.getHealthData(userId, limit: 7);

      // 2. BUAT SALINAN MUTABLE DARI DAFTAR
      List<Map<String, dynamic>> data = List.from(rawData);

      // 3. Mengurutkan data berdasarkan tanggal dari yang paling lama ke yang paling baru
      data.sort((a, b) => a['date'].compareTo(b['date']));

      _weeklyHealthData = data;
      _updateWeeklyChartData();


      print('📊 Loaded weekly data: ${data.length} days');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading data: ${e.toString()}';
      print('❌ Error loading data: $e');
      notifyListeners();
    }
  }

  void _updateWeeklyChartData() {
    // Reset list mingguan
    _weeklySteps = [];
    _weeklySleep = [];
    _weeklyHeartRates = [];

    // Isi list untuk grafik/bar di Menu Utama
    for (var day in _weeklyHealthData) {
      // Data langkah
      _weeklySteps.add((day['steps'] as num).toInt());

      // Data tidur
      double sleepDuration = (day['sleep_duration'] as num).toDouble();
      _weeklySleep.add(double.parse(sleepDuration.toStringAsFixed(1)));

      // Data detak jantung
      double avgHr = (day['avg_heart_rate'] as num).toDouble();
      _weeklyHeartRates.add(avgHr.round());
    }
  }


  // Fungsi untuk mendapatkan data hari ini dari DB (digunakan oleh Detail Screen)
  Future<Map<String, dynamic>?> getTodayDataFromDb(String userId) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return await DatabaseHelper.instance.getHealthDataByDate(userId, dateStr);
  }

  // Fungsi untuk sinkronisasi data 7 hari ke belakang (biasanya dipanggil saat startup)
  Future<void> syncPastWeekData(String userId) async {
    if (!_isAuthorized) return;

    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();

      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(hours: 23, minutes: 59, seconds: 59));

        List<HealthDataPoint> healthData;
        try {
          healthData = await _health.getHealthDataFromTypes(
            startTime: startOfDay,
            endTime: endOfDay,
            types: _types,
          );
        } catch (e) {
          print('Error fetching health data for $date: $e');
          continue;
        }

        Map<String, HealthDataPoint> uniqueData = {};
        for (var point in healthData) {
          String key = '${point.type}_${point.dateFrom}_${point.value}';
          uniqueData[key] = point;
        }

        int steps = 0;
        List<double> heartRates = [];
        double sleepMinutes = 0;

        for (var point in uniqueData.values) {
          switch (point.type) {
            case HealthDataType.STEPS:
              if (point.value is NumericHealthValue) {
                steps += (point.value as NumericHealthValue).numericValue.toInt();
              }
              break;
            case HealthDataType.HEART_RATE:
              if (point.value is NumericHealthValue) {
                heartRates.add((point.value as NumericHealthValue).numericValue.toDouble());
              }
              break;
            case HealthDataType.SLEEP_LIGHT:
            case HealthDataType.SLEEP_DEEP:
            case HealthDataType.SLEEP_REM:
              final duration = point.dateTo.difference(point.dateFrom).inMinutes;
              sleepMinutes += duration.toDouble();
              break;
            default:
              break;
          }
        }

        double sleepHours = sleepMinutes / 60;
        double avgHeartRate = heartRates.isNotEmpty
            ? heartRates.reduce((a, b) => a + b) / heartRates.length
            : 0;

        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        final existingData = await DatabaseHelper.instance.getHealthDataByDate(userId, dateStr);

        if (existingData != null) {
          await DatabaseHelper.instance.updateHealthData(
            existingData['id'],
            {
              'steps': steps,
              'avg_heart_rate': avgHeartRate,
              'sleep_duration': sleepHours,
              'timestamp': date.toIso8601String(),
            },
          );
        } else {
          await DatabaseHelper.instance.insertHealthData({
            'user_id': userId,
            'date': dateStr,
            'steps': steps,
            'avg_heart_rate': avgHeartRate,
            'sleep_duration': sleepHours,
            'timestamp': date.toIso8601String(),
          });
        }
      }

      await loadWeeklyHealthData(userId);

    } catch (e) {
      _errorMessage = 'Error syncing past data: ${e.toString()}';
      print('❌ Sync past week error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearAuthorization() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('health_authorized');
    _isAuthorized = false;
    notifyListeners();
  }
}
