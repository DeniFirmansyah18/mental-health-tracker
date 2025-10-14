import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/assessment_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String userId = 'user_001'; // In production, get from auth

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final healthProvider = context.read<HealthProvider>();
    final moodProvider = context.read<MoodProvider>();
    final assessmentProvider = context.read<AssessmentProvider>();

    await moodProvider.loadMoodHistory(userId, limit: 7);
    await assessmentProvider.loadPHQ9History(userId);
    await assessmentProvider.loadGAD7History(userId);
    await healthProvider.loadWeeklyHealthData(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF6B4EE6),
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Mental Health Tracker',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6B4EE6), Color(0xFF9B7EF5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreetingCard(),
                    const SizedBox(height: 20),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildMoodChart(),
                    const SizedBox(height: 20),
                    _buildHealthDataCard(),
                    const SizedBox(height: 20),
                    _buildAssessmentSummary(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingCard() {
    final hour = DateTime.now().hour;
    String greeting = 'Selamat Pagi';
    if (hour >= 12 && hour < 15) greeting = 'Selamat Siang';
    if (hour >= 15 && hour < 18) greeting = 'Selamat Sore';
    if (hour >= 18) greeting = 'Selamat Malam';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6B4EE6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.psychology,
                color: Color(0xFF6B4EE6),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bagaimana perasaan Anda hari ini?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.mood,
                label: 'Input Mood',
                color: const Color(0xFFFF6B9D),
                onTap: () => Navigator.pushNamed(context, '/mood').then((_) => _loadData()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.assignment,
                label: 'PHQ-9',
                color: const Color(0xFF4ECDC4),
                onTap: () => Navigator.pushNamed(context, '/phq9').then((_) => _loadData()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.assessment,
                label: 'GAD-7',
                color: const Color(0xFFFFA726),
                onTap: () => Navigator.pushNamed(context, '/gad7').then((_) => _loadData()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.sync,
                label: 'Sinkronisasi',
                color: const Color(0xFF66BB6A),
                onTap: () => Navigator.pushNamed(context, '/health-sync').then((_) => _loadData()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _buildActionButton(
            icon: Icons.bar_chart,
            label: 'Lihat Laporan Lengkap',
            color: const Color(0xFF6B4EE6),
            onTap: () => Navigator.pushNamed(context, '/report'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodChart() {
    return Consumer<MoodProvider>(
      builder: (context, provider, child) {
        if (provider.moodHistory.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Belum ada data mood.\nMulai catat mood harian Anda!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          );
        }

        final moods = provider.moodHistory.reversed.toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Grafik Mood 7 Hari Terakhir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= moods.length) return const Text('');
                              final date = DateTime.parse(moods[value.toInt()]['date']);
                              return Text(
                                DateFormat('dd/MM').format(date),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true),
                      minY: 0,
                      maxY: 6,
                      lineBarsData: [
                        LineChartBarData(
                          spots: moods.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              (entry.value['mood_level'] as int).toDouble(),
                            );
                          }).toList(),
                          isCurved: true,
                          color: const Color(0xFF6B4EE6),
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthDataCard() {
    return Consumer<HealthProvider>(
      builder: (context, provider, child) {
        final data = provider.todayHealthData;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Data Kesehatan Hari Ini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      provider.isAuthorized ? Icons.check_circle : Icons.warning,
                      color: provider.isAuthorized ? Colors.green : Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (data != null) ...[
                  _buildHealthItem(
                    Icons.directions_walk,
                    'Langkah',
                    '${data['steps']}',
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildHealthItem(
                    Icons.favorite,
                    'Detak Jantung',
                    '${data['avg_heart_rate']} bpm',
                    Colors.red,
                  ),
                  const SizedBox(height: 12),
                  _buildHealthItem(
                    Icons.bedtime,
                    'Durasi Tidur',
                    '${data['sleep_hours']} jam',
                    Colors.purple,
                  ),
                ] else
                  Center(
                    child: Text(
                      'Belum ada data kesehatan.\nSinkronkan dengan Health Connect.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthItem(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAssessmentSummary() {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        final latestPHQ9 = provider.phq9History.isNotEmpty ? provider.phq9History.first : null;
        final latestGAD7 = provider.gad7History.isNotEmpty ? provider.gad7History.first : null;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hasil Asesmen Terakhir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (latestPHQ9 != null)
                  _buildAssessmentItem(
                    'PHQ-9 (Depresi)',
                    latestPHQ9['total_score'].toString(),
                    latestPHQ9['severity'],
                    provider.getSeverityColor(latestPHQ9['severity']),
                  ),
                if (latestPHQ9 != null && latestGAD7 != null) const SizedBox(height: 12),
                if (latestGAD7 != null)
                  _buildAssessmentItem(
                    'GAD-7 (Kecemasan)',
                    latestGAD7['total_score'].toString(),
                    latestGAD7['severity'],
                    provider.getSeverityColor(latestGAD7['severity']),
                  ),
                if (latestPHQ9 == null && latestGAD7 == null)
                  Center(
                    child: Text(
                      'Belum ada hasil asesmen.\nMulai isi kuesioner PHQ-9 atau GAD-7.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssessmentItem(String title, String score, String severity, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tingkat: $severity',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              score,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}