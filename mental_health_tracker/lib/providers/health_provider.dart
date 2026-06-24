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
  // Data bulanan (untuk detail screen per bulan)
  List<Map<String, dynamic>> _monthlyHealthData = [];
  // Data multi-bulan untuk laporan analisis (max 7 hari per bulan dari semua bulan tersimpan)
  List<Map<String, dynamic>> _reportHealthData = [];
  // Daftar bulan yang tersedia (format 'yyyy-MM')
  List<String> _availableMonths = [];

  // Data terstruktur untuk grafik mingguan (tetap dipertahankan)
  List<int> _weeklySteps = [];
  List<double> _weeklySleep = [];
  List<int> _weeklyHeartRates = [];

  bool get isAuthorized => _isAuthorized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get todayHealthData => _todayHealthData;
  List<Map<String, dynamic>> get weeklyHealthData => _weeklyHealthData;
  List<Map<String, dynamic>> get monthlyHealthData => _monthlyHealthData;
  List<Map<String, dynamic>> get reportHealthData => _reportHealthData;
  List<String> get availableMonths => _availableMonths;

  /// True jika data laporan sudah cukup:
  /// – Satu bulan saja  → minimal 7 hari
  /// – Lebih dari satu bulan → minimal 14 hari total (7 hari per bulan)
  bool get hasEnoughReportData {
    if (_reportHealthData.isEmpty) return false;
    // Hitung jumlah bulan unik dalam data laporan
    final months = _reportHealthData
        .map((d) => (d['date'] as String).substring(0, 7))
        .toSet();
    if (months.length == 1) {
      return _reportHealthData.length >= 7;
    }
    return _reportHealthData.length >= 14;
  }

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


  /// Memuat data health untuk bulan dan tahun tertentu dari DB.
  Future<void> loadMonthlyHealthData(String userId, int year, int month) async {
    _isLoading = true;
    notifyListeners();
    try {
      final rawData = await DatabaseHelper.instance
          .getHealthDataByMonth(userId, year, month);
      _monthlyHealthData = List.from(rawData);
      print('📊 Loaded monthly data ($year-$month): ${rawData.length} days');
    } catch (e) {
      _errorMessage = 'Error loading monthly data: ${e.toString()}';
      print('❌ Error loading monthly data: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Mengambil daftar bulan yang tersedia (memiliki data) dari DB.
  Future<void> fetchAvailableMonths(String userId) async {
    try {
      _availableMonths =
          await DatabaseHelper.instance.getAvailableMonths(userId);
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching available months: $e');
    }
  }

  /// Memuat data health untuk laporan analisis:
  /// Mengambil max 7 hari terbaru per bulan dari semua bulan yang tersimpan di DB.
  /// Laporan baru ditampilkan jika total >= 7 hari (1 bulan) atau >= 14 hari (2+ bulan).
  Future<void> loadReportHealthData(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final rawData = await DatabaseHelper.instance
          .getHealthDataMultiMonth(userId, maxDaysPerMonth: 7);
      _reportHealthData = List.from(rawData);
      print('📊 Loaded report data: ${rawData.length} days '
          'across ${rawData.map((d) => (d["date"] as String).substring(0, 7)).toSet().length} month(s)');
    } catch (e) {
      _errorMessage = 'Error loading report data: ${e.toString()}';
      print('❌ Error loading report data: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // Fungsi untuk mendapatkan data hari ini dari DB (digunakan oleh Detail Screen)
  Future<Map<String, dynamic>?> getTodayDataFromDb(String userId) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return await DatabaseHelper.instance.getHealthDataByDate(userId, dateStr);
  }

  // Progress sinkronisasi historis (0.0 – 1.0) dan jumlah hari yang berhasil
  double _syncProgress = 0.0;
  int _syncedDaysCount = 0;
  double get syncProgress => _syncProgress;
  int get syncedDaysCount => _syncedDaysCount;

  /// Sinkronisasi data historis dari Health Connect sejauh [days] hari ke belakang.
  /// Berguna untuk memulihkan data bulan-bulan lalu (mis. April & Mei) setelah
  /// APK diinstall ulang dan data SQLite lokal terhapus.
  /// Hanya menyimpan hari yang benar-benar ada data dari Health Connect
  /// (steps > 0 ATAU heart_rate > 0 ATAU sleep > 0).
  Future<void> syncHistoricalData(String userId, {int days = 90}) async {
    if (!_isAuthorized) {
      _errorMessage = 'Health Connect belum diotorisasi';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _syncProgress = 0.0;
    _syncedDaysCount = 0;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      int savedCount = 0;

      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(
            const Duration(hours: 23, minutes: 59, seconds: 59));

        // Update progress
        _syncProgress = i / days;
        notifyListeners();

        List<HealthDataPoint> healthData;
        try {
          healthData = await _health.getHealthDataFromTypes(
            startTime: startOfDay,
            endTime: endOfDay,
            types: _types,
          );
        } catch (e) {
          print('⚠ Skipping $date: $e');
          continue;
        }

        if (healthData.isEmpty) continue;

        // Deduplicate
        final Map<String, HealthDataPoint> uniqueData = {};
        for (var point in healthData) {
          final key = '${point.type}_${point.dateFrom}_${point.value}';
          uniqueData[key] = point;
        }

        int steps = 0;
        final List<double> heartRates = [];
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
                heartRates.add(
                    (point.value as NumericHealthValue).numericValue.toDouble());
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

        // Lewati hari tanpa data bermakna
        if (steps == 0 && heartRates.isEmpty && sleepMinutes == 0) continue;

        final double sleepHours = sleepMinutes / 60;
        final double avgHeartRate = heartRates.isNotEmpty
            ? heartRates.reduce((a, b) => a + b) / heartRates.length
            : 0;

        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        final existing =
            await DatabaseHelper.instance.getHealthDataByDate(userId, dateStr);

        if (existing != null) {
          await DatabaseHelper.instance.updateHealthData(existing['id'], {
            'steps': steps,
            'avg_heart_rate': avgHeartRate,
            'sleep_duration': sleepHours,
            'timestamp': date.toIso8601String(),
          });
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

        savedCount++;
        _syncedDaysCount = savedCount;
      }

      _syncProgress = 1.0;
      print('✅ Historical sync done: $savedCount days saved (last $days days)');

      // Refresh data UI setelah sinkronisasi selesai
      await loadWeeklyHealthData(userId);
    } catch (e) {
      _errorMessage = 'Error sync historis: ${e.toString()}';
      print('❌ Historical sync error: $e');
    }

    _isLoading = false;
    notifyListeners();
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
