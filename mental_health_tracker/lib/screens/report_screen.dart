import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/assessment_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final String userId = 'user_001';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final healthProvider = context.read<HealthProvider>();
    final moodProvider = context.read<MoodProvider>();
    final assessmentProvider = context.read<AssessmentProvider>();

    await Future.wait([
      moodProvider.loadMoodHistory(userId, limit: 14),
      assessmentProvider.loadPHQ9History(userId),
      assessmentProvider.loadGAD7History(userId),
      healthProvider.loadWeeklyHealthData(userId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Lengkap'),
        backgroundColor: const Color(0xFF6B4EE6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Analisis Tingkat Stress'),
              const SizedBox(height: 12),
              _buildStressAnalysis(),
              const SizedBox(height: 24),
              _buildSectionTitle('Grafik Mood vs Kesehatan'),
              const SizedBox(height: 12),
              _buildCombinedChart(),
              const SizedBox(height: 24),
              _buildSectionTitle('Riwayat Asesmen'),
              const SizedBox(height: 12),
              _buildAssessmentHistory(),
              const SizedBox(height: 24),
              _buildSectionTitle('Korelasi Data'),
              const SizedBox(height: 12),
              _buildCorrelationInsights(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStressAnalysis() {
    return Consumer3<MoodProvider, HealthProvider, AssessmentProvider>(
      builder: (context, moodProvider, healthProvider, assessmentProvider, child) {
        // Simulasi analisis stress berdasarkan data
        final moodData = moodProvider.moodHistory;
        final healthData = healthProvider.weeklyHealthData;
        final phq9Data = assessmentProvider.phq9History;
        final gad7Data = assessmentProvider.gad7History;

        if (moodData.isEmpty && healthData.isEmpty && phq9Data.isEmpty && gad7Data.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Belum cukup data untuk analisis.\nIsi data mood, kesehatan, dan asesmen untuk mendapatkan analisis.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          );
        }

        // Hitung persentase tingkat stress (simulasi sederhana)
        double lowStress = 0;
        double normalStress = 0;
        double moderateStress = 0;
        double highStress = 0;

        // Analisis dari mood
        if (moodData.isNotEmpty) {
          for (var mood in moodData) {
            final level = mood['mood_level'] as int;
            if (level >= 4) lowStress += 1;
            else if (level == 3) normalStress += 1;
            else if (level == 2) moderateStress += 1;
            else highStress += 1;
          }
          final total = moodData.length.toDouble();
          lowStress = (lowStress / total) * 100;
          normalStress = (normalStress / total) * 100;
          moderateStress = (moderateStress / total) * 100;
          highStress = (highStress / total) * 100;
        }

        // Tambahkan bobot dari PHQ-9 dan GAD-7
        if (phq9Data.isNotEmpty) {
          final latestPHQ9 = phq9Data.first;
          final score = latestPHQ9['total_score'] as int;
          if (score > 14) {
            highStress = (highStress * 0.7) + 30;
            moderateStress *= 0.8;
          } else if (score > 9) {
            moderateStress = (moderateStress * 0.7) + 20;
          }
        }

        if (gad7Data.isNotEmpty) {
          final latestGAD7 = gad7Data.first;
          final score = latestGAD7['total_score'] as int;
          if (score > 14) {
            highStress = (highStress * 0.7) + 30;
            moderateStress *= 0.8;
          } else if (score > 9) {
            moderateStress = (moderateStress * 0.7) + 20;
          }
        }

        // Normalisasi agar total 100%
        final total = lowStress + normalStress + moderateStress + highStress;
        if (total > 0) {
          lowStress = (lowStress / total) * 100;
          normalStress = (normalStress / total) * 100;
          moderateStress = (moderateStress / total) * 100;
          highStress = (highStress / total) * 100;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Distribusi Tingkat Stress 2 Minggu Terakhir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      RadarChart(
                        RadarChartData(
                          radarShape: RadarShape.polygon,
                          radarBorderData: const BorderSide(
                            color: Colors.grey,
                            width: 2,
                          ),
                          gridBorderData: const BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                          tickCount: 5,
                          ticksTextStyle: const TextStyle(
                            color: Colors.transparent,
                            fontSize: 10,
                          ),
                          tickBorderData: const BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                          getTitle: (index, angle) {
                            const titles = ['Rendah', 'Normal', 'Sedang', 'Tinggi'];
                            return RadarChartTitle(
                              text: titles[index],
                              angle: angle,
                            );
                          },
                          titleTextStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          titlePositionPercentageOffset: 0.2,
                          dataSets: [
                            RadarDataSet(
                              fillColor: const Color(0xFF6B4EE6).withOpacity(0.3),
                              borderColor: const Color(0xFF6B4EE6),
                              borderWidth: 2.5,
                              entryRadius: 5,
                              dataEntries: [
                                RadarEntry(value: lowStress),
                                RadarEntry(value: normalStress),
                                RadarEntry(value: moderateStress),
                                RadarEntry(value: highStress),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildStressLegend(lowStress, normalStress, moderateStress, highStress),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStressLegend(double low, double normal, double moderate, double high) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLegendItemWithValue('Rendah', Colors.green, low),
            _buildLegendItemWithValue('Normal', Colors.blue, normal),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLegendItemWithValue('Sedang', Colors.orange, moderate),
            _buildLegendItemWithValue('Tinggi', Colors.red, high),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItemWithValue(String label, Color color, double value) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCombinedChart() {
    return Consumer2<MoodProvider, HealthProvider>(
      builder: (context, moodProvider, healthProvider, child) {
        final moodData = moodProvider.moodHistory.reversed.toList();
        final healthData = healthProvider.weeklyHealthData.reversed.toList();

        if (moodData.isEmpty && healthData.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Belum ada data untuk ditampilkan',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mood & Langkah Harian',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          axisNameWidget: const Text('Mood', style: TextStyle(fontSize: 10)),
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
                        rightTitles: AxisTitles(
                          axisNameWidget: const Text('Langkah (x1000)', style: TextStyle(fontSize: 10)),
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
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
                              if (value.toInt() >= moodData.length) return const Text('');
                              final date = DateTime.parse(moodData[value.toInt()]['date']);
                              return Text(
                                DateFormat('dd/MM').format(date),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        if (moodData.isNotEmpty)
                          LineChartBarData(
                            spots: moodData.asMap().entries.map((entry) {
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
                        if (healthData.isNotEmpty)
                          LineChartBarData(
                            spots: healthData.asMap().entries.map((entry) {
                              return FlSpot(
                                entry.key.toDouble(),
                                (entry.value['steps'] as int) / 1000,
                              );
                            }).toList(),
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('Mood', const Color(0xFF6B4EE6)),
                    const SizedBox(width: 16),
                    _buildLegendItem('Langkah', Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssessmentHistory() {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        final phq9 = provider.phq9History;
        final gad7 = provider.gad7History;

        if (phq9.isEmpty && gad7.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Belum ada riwayat asesmen',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            if (phq9.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Riwayat PHQ-9 (Depresi)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...phq9.take(5).map((assessment) {
                        return _buildAssessmentItem(
                          assessment,
                          'PHQ-9',
                          provider,
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (gad7.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Riwayat GAD-7 (Kecemasan)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...gad7.take(5).map((assessment) {
                        return _buildAssessmentItem(
                          assessment,
                          'GAD-7',
                          provider,
                        );
                      }),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAssessmentItem(
      Map<String, dynamic> assessment,
      String type,
      AssessmentProvider provider,
      ) {
    final date = DateTime.parse(assessment['date']);
    final score = assessment['total_score'] as int;
    final severity = assessment['severity'] as String;
    final color = provider.getSeverityColor(severity);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('d MMM yyyy', 'id_ID').format(date),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  severity,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              score.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationInsights() {
    return Consumer3<MoodProvider, HealthProvider, AssessmentProvider>(
      builder: (context, moodProvider, healthProvider, assessmentProvider, child) {
        final insights = <String>[];

        // Analisis korelasi sederhana
        final moodData = moodProvider.moodHistory;
        final healthData = healthProvider.weeklyHealthData;

        if (moodData.length >= 3 && healthData.length >= 3) {
          // Cek korelasi mood dengan langkah
          final avgMood = moodData.take(7).map((m) => m['mood_level'] as int).reduce((a, b) => a + b) / 7;
          final avgSteps = healthData.take(7).map((h) => h['steps'] as int).reduce((a, b) => a + b) / 7;

          if (avgSteps > 8000) {
            insights.add('✓ Aktivitas fisik Anda baik! Rata-rata ${avgSteps.toInt()} langkah per hari.');
          } else {
            insights.add('⚠ Tingkatkan aktivitas fisik. Target minimal 8.000 langkah/hari.');
          }

          final avgSleep = healthData.take(7).map((h) => h['sleep_duration'] as double).reduce((a, b) => a + b) / 7;
          if (avgSleep >= 7 && avgSleep <= 9) {
            insights.add('✓ Durasi tidur Anda ideal (${avgSleep.toStringAsFixed(1)} jam/malam).');
          } else if (avgSleep < 7) {
            insights.add('⚠ Tidur kurang dari 7 jam dapat mempengaruhi mood. Usahakan tidur 7-9 jam.');
          } else {
            insights.add('⚠ Tidur terlalu lama dapat menunjukkan masalah. Konsultasi jika perlu.');
          }

          if (avgMood >= 3.5) {
            insights.add('✓ Mood Anda cenderung positif dalam 7 hari terakhir.');
          } else if (avgMood < 2.5) {
            insights.add('⚠ Mood Anda cenderung rendah. Pertimbangkan konsultasi profesional.');
          }
        }

        final latestPHQ9 = assessmentProvider.phq9History.isNotEmpty
            ? assessmentProvider.phq9History.first
            : null;
        final latestGAD7 = assessmentProvider.gad7History.isNotEmpty
            ? assessmentProvider.gad7History.first
            : null;

        if (latestPHQ9 != null) {
          final score = latestPHQ9['total_score'] as int;
          if (score > 14) {
            insights.add('⚠ Skor PHQ-9 menunjukkan gejala depresi sedang-berat. Sangat disarankan konsultasi psikolog/psikiater.');
          } else if (score > 9) {
            insights.add('⚠ Skor PHQ-9 menunjukkan gejala depresi sedang. Pertimbangkan konsultasi profesional.');
          }
        }

        if (latestGAD7 != null) {
          final score = latestGAD7['total_score'] as int;
          if (score > 14) {
            insights.add('⚠ Skor GAD-7 menunjukkan kecemasan berat. Sangat disarankan konsultasi profesional.');
          } else if (score > 9) {
            insights.add('⚠ Skor GAD-7 menunjukkan kecemasan sedang. Pertimbangkan konsultasi profesional.');
          }
        }

        if (insights.isEmpty) {
          insights.add('Belum cukup data untuk memberikan insight. Terus isi data Anda secara berkala.');
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Insight & Rekomendasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...insights.map((insight) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          insight.startsWith('✓') ? Icons.check_circle : Icons.info,
                          color: insight.startsWith('✓') ? Colors.green : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            insight.substring(2),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Catatan: Aplikasi ini hanya alat bantu. Untuk diagnosis dan penanganan, konsultasi dengan profesional kesehatan mental.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}