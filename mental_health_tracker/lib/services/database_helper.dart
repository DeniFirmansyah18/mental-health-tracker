import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mental_health.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Tabel Mood Harian
    await db.execute('''
    CREATE TABLE mood_entries (
      id $idType,
      user_id $textType,
      date $textType,
      mood_level $integerType,
      mood_emoji $textType,
      notes TEXT,
      timestamp $textType,
      UNIQUE(user_id, date)
    )
    ''');

    // Tabel PHQ-9
    await db.execute('''
    CREATE TABLE phq9_assessments (
      id $idType,
      user_id $textType,
      date $textType,
      q1 $integerType,
      q2 $integerType,
      q3 $integerType,
      q4 $integerType,
      q5 $integerType,
      q6 $integerType,
      q7 $integerType,
      q8 $integerType,
      q9 $integerType,
      total_score $integerType,
      severity $textType,
      timestamp $textType
    )
    ''');

    // Tabel GAD-7
    await db.execute('''
    CREATE TABLE gad7_assessments (
      id $idType,
      user_id $textType,
      date $textType,
      q1 $integerType,
      q2 $integerType,
      q3 $integerType,
      q4 $integerType,
      q5 $integerType,
      q6 $integerType,
      q7 $integerType,
      total_score $integerType,
      severity $textType,
      timestamp $textType
    )
    ''');

    // Tabel Health Data (dari Health Connect)
    await db.execute('''
    CREATE TABLE health_data (
      id $idType,
      user_id $textType,
      date $textType,
      steps $integerType,
      avg_heart_rate $realType,
      sleep_duration $realType,
      timestamp $textType,
      UNIQUE(user_id, date)
    )
    ''');

    // Tabel Stress Analysis Results
    await db.execute('''
    CREATE TABLE stress_analysis (
      id $idType,
      user_id $textType,
      start_date $textType,
      end_date $textType,
      stress_level_low $realType,
      stress_level_normal $realType,
      stress_level_moderate $realType,
      stress_level_high $realType,
      correlations TEXT,
      timestamp $textType
    )
    ''');
  }

  // MOOD ENTRIES
  Future<int> insertMoodEntry(Map<String, dynamic> entry) async {
    final db = await database;
    return await db.insert(
      'mood_entries',
      entry,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMoodEntries(String userId, {int? limit}) async {
    final db = await database;
    return await db.query(
      'mood_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: limit,
    );
  }

  // PHQ-9 ASSESSMENTS
  Future<int> insertPHQ9(Map<String, dynamic> assessment) async {
    final db = await database;
    return await db.insert('phq9_assessments', assessment);
  }

  Future<List<Map<String, dynamic>>> getPHQ9Assessments(String userId) async {
    final db = await database;
    return await db.query(
      'phq9_assessments',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  // GAD-7 ASSESSMENTS
  Future<int> insertGAD7(Map<String, dynamic> assessment) async {
    final db = await database;
    return await db.insert('gad7_assessments', assessment);
  }

  Future<List<Map<String, dynamic>>> getGAD7Assessments(String userId) async {
    final db = await database;
    return await db.query(
      'gad7_assessments',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  // HEALTH DATA
  Future<int> insertHealthData(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      'health_data',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateHealthData(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      'health_data',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> getHealthDataByDate(String userId, String date) async {
    final db = await database;
    final results = await db.query(
      'health_data',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getHealthData(String userId, {int? limit}) async {
    final db = await database;
    return await db.query(
      'health_data',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: limit,
    );
  }

  /// Returns all health data rows for a specific year and month.
  Future<List<Map<String, dynamic>>> getHealthDataByMonth(
      String userId, int year, int month) async {
    final db = await database;
    final monthStr =
        '$year-${month.toString().padLeft(2, '0')}'; // e.g. "2026-05"
    final results = await db.query(
      'health_data',
      where: "user_id = ? AND strftime('%Y-%m', date) = ?",
      whereArgs: [userId, monthStr],
      orderBy: 'date ASC',
    );
    return results;
  }

  /// Returns a list of distinct year-month strings (e.g. ["2026-05", "2026-04"])
  /// for which health data exists for the given user.
  Future<List<String>> getAvailableMonths(String userId) async {
    final db = await database;
    final results = await db.rawQuery(
      "SELECT DISTINCT strftime('%Y-%m', date) AS ym FROM health_data "
      "WHERE user_id = ? ORDER BY ym DESC",
      [userId],
    );
    return results.map((r) => r['ym'] as String).toList();
  }

  /// Returns health data from multiple months, capped at [maxDaysPerMonth] most
  /// recent days per month. Results are sorted oldest-to-newest across all months.
  /// Used for the analysis/report screen so previous months' stored data is included.
  Future<List<Map<String, dynamic>>> getHealthDataMultiMonth(
      String userId, {
      int maxDaysPerMonth = 7,
  }) async {
    final db = await database;
    // Get all available months (newest first)
    final months = await getAvailableMonths(userId);
    final List<Map<String, dynamic>> combined = [];

    for (final ym in months) {
      // For each month take the [maxDaysPerMonth] most recent days
      final rows = await db.rawQuery(
        "SELECT * FROM health_data "
        "WHERE user_id = ? AND strftime('%Y-%m', date) = ? "
        "ORDER BY date DESC LIMIT ?",
        [userId, ym, maxDaysPerMonth],
      );
      combined.addAll(rows);
    }

    // Sort combined list oldest-to-newest
    combined.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
    return combined;
  }

  // STRESS ANALYSIS
  Future<int> insertStressAnalysis(Map<String, dynamic> analysis) async {
    final db = await database;
    return await db.insert('stress_analysis', analysis);
  }

  Future<List<Map<String, dynamic>>> getStressAnalysis(String userId, {int? limit}) async {
    final db = await database;
    return await db.query(
      'stress_analysis',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
  }

  // DELETE DATA (untuk testing/reset)
  Future<int> deleteHealthData(String userId) async {
    final db = await database;
    return await db.delete(
      'health_data',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}