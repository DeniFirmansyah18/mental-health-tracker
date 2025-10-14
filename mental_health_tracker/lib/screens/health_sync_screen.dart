import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';

class HealthSyncScreen extends StatefulWidget {
  const HealthSyncScreen({super.key});

  @override
  State<HealthSyncScreen> createState() => _HealthSyncScreenState();
}

class _HealthSyncScreenState extends State<HealthSyncScreen> {
  final String userId = 'user_001';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().loadWeeklyHealthData(userId);
    });
  }

  Future<void> _requestPermissions() async {
    final provider = context.read<HealthProvider>();
    final success = await provider.requestAuthorization();

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin berhasil diberikan! Silakan sinkronkan data.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Gagal mendapatkan izin'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _syncTodayData() async {
    final provider = context.read<HealthProvider>();
    if (!provider.isAuthorized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berikan izin terlebih dahulu')),
      );
      return;
    }

    await provider.syncHealthData(userId);

    if (mounted) {
      if (provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data hari ini berhasil disinkronkan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _syncWeekData() async {
    final provider = context.read<HealthProvider>();
    if (!provider.isAuthorized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berikan izin terlebih dahulu')),
      );
      return;
    }

    await provider.syncPastWeekData(userId);

    if (mounted) {
      if (provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data 7 hari terakhir berhasil disinkronkan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sinkronisasi Health Connect'),
        backgroundColor: const Color(0xFF66BB6A),
        foregroundColor: Colors.white,
      ),
      body: Consumer<HealthProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(provider),
                const SizedBox(height: 20),
                _buildPermissionCard(provider),
                const SizedBox(height: 20),
                _buildSyncActions(provider),
                const SizedBox(height: 20),
                _buildWeeklyDataList(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(HealthProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              provider.isAuthorized ? Icons.check_circle : Icons.warning_amber,
              size: 64,
              color: provider.isAuthorized ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              provider.isAuthorized
                  ? 'Terhubung dengan Health Connect'
                  : 'Belum Terhubung',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              provider.isAuthorized
                  ? 'Aplikasi dapat membaca data kesehatan Anda'
                  : 'Berikan izin untuk mengakses data kesehatan',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard(HealthProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data yang Diakses',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPermissionItem(
              Icons.directions_walk,
              'Jumlah Langkah',
              'Langkah harian dari smartwatch atau ponsel',
              Colors.blue,
            ),
            const Divider(height: 24),
            _buildPermissionItem(
              Icons.favorite,
              'Detak Jantung',
              'Rata-rata detak jantung harian',
              Colors.red,
            ),
            const Divider(height: 24),
            _buildPermissionItem(
              Icons.bedtime,
              'Durasi Tidur',
              'Lama waktu tidur setiap hari',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem(IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
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
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSyncActions(HealthProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Sinkronisasi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (!provider.isAuthorized)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: provider.isLoading ? null : _requestPermissions,
              icon: const Icon(Icons.vpn_key),
              label: const Text('Berikan Izin Akses'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF66BB6A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        if (provider.isAuthorized) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: provider.isLoading ? null : _syncTodayData,
              icon: provider.isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.sync),
              label: const Text('Sinkronkan Data Hari Ini'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF66BB6A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: provider.isLoading ? null : _syncWeekData,
              icon: provider.isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.history),
              label: const Text('Sinkronkan 7 Hari Terakhir'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWeeklyDataList(HealthProvider provider) {
    if (provider.weeklyHealthData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Belum ada data kesehatan.\nLakukan sinkronisasi untuk melihat data.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Data Kesehatan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...provider.weeklyHealthData.map((data) {
          final date = DateTime.parse(data['date']);
          final formattedDate = '${date.day}/${date.month}/${date.year}';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDataItem(
                        Icons.directions_walk,
                        '${data['steps']}',
                        'Langkah',
                        Colors.blue,
                      ),
                      _buildDataItem(
                        Icons.favorite,
                        '${data['avg_heart_rate'].toStringAsFixed(0)}',
                        'bpm',
                        Colors.red,
                      ),
                      _buildDataItem(
                        Icons.bedtime,
                        '${data['sleep_duration'].toStringAsFixed(1)}',
                        'jam',
                        Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDataItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}