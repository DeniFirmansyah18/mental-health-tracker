import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Asumsi import provider sudah benar
import '../providers/health_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/assessment_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String userId = 'user_001';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Pastikan `context.read` dipanggil hanya di initState atau di luar build
    // kecuali di dalam builder (seperti Consumer).
    if (!mounted) return;
    final healthProvider = context.read<HealthProvider>();
    final moodProvider = context.read<MoodProvider>();
    final assessmentProvider = context.read<AssessmentProvider>();

    // Load mood and assessment data
    await moodProvider.loadMoodHistory(userId, limit: 7);
    await assessmentProvider.loadPHQ9History(userId);
    await assessmentProvider.loadGAD7History(userId);

    // FIXED: Hanya load health data jika masih kosong
    // Jangan override data yang sudah di-set oleh sync screen
    if (healthProvider.weeklyHealthData.isEmpty) {
      await healthProvider.loadWeeklyHealthData(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHealthTab(),
          _buildActivityTab(),
          _buildDiscoverTab(),
          _buildDevicesTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHealthTab() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6B4EE6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Kesehatan',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white70),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHealthCards(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.black,
            title: const Text(
              'Aktivitas',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 28,
                color: Colors.white,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildActivityCard(
                    'Input Mood Harian',
                    'Catat perasaan Anda hari ini',
                    Icons.mood,
                    const Color(0xFFFF6B9D),
                        () => Navigator.pushNamed(context, '/mood').then((_) => _loadData()),
                  ),
                  const SizedBox(height: 16),
                  _buildActivityCard(
                    'Kuesioner PHQ-9',
                    'Skrining depresi (9 pertanyaan)',
                    Icons.assignment_outlined,
                    const Color(0xFF4ECDC4),
                        () => Navigator.pushNamed(context, '/phq9').then((_) => _loadData()),
                  ),
                  const SizedBox(height: 16),
                  _buildActivityCard(
                    'Kuesioner GAD-7',
                    'Skrining kecemasan (7 pertanyaan)',
                    Icons.psychology_outlined,
                    const Color(0xFFFFA726),
                        () => Navigator.pushNamed(context, '/gad7').then((_) => _loadData()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverTab() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.black,
            title: const Text(
              'Temukan',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 28,
                color: Colors.white,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDiscoverCard(
                    'Laporan Lengkap',
                    'Analisis mendalam kesehatan mental Anda',
                    Icons.bar_chart,
                    const Color(0xFF6B4EE6),
                        () => Navigator.pushNamed(context, '/report'),
                  ),
                  const SizedBox(height: 16),
                  _buildDiscoverCard(
                    'Tips Kesehatan Mental',
                    'Pelajari cara menjaga kesehatan mental',
                    Icons.lightbulb_outline,
                    const Color(0xFFFFC107),
                        () {},
                  ),
                  const SizedBox(height: 16),
                  _buildDiscoverCard(
                    'Meditasi & Relaksasi',
                    'Teknik untuk menenangkan pikiran',
                    Icons.self_improvement,
                    const Color(0xFF66BB6A),
                        () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesTab() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.black,
            title: const Text(
              'Perangkat',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 28,
                color: Colors.white,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDeviceCard(
                    'Health Connect',
                    'Sinkronkan data dari smartwatch',
                    Icons.watch,
                    const Color(0xFF66BB6A),
                        () => Navigator.pushNamed(context, '/health-sync').then((_) => _loadData()),
                  ),
                  const SizedBox(height: 16),
                  Consumer<HealthProvider>(
                    builder: (context, provider, child) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  provider.isAuthorized
                                      ? Icons.check_circle
                                      : Icons.warning_amber_rounded,
                                  color: provider.isAuthorized
                                      ? Colors.green
                                      : Colors.orange,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        provider.isAuthorized
                                            ? 'Terhubung'
                                            : 'Belum Terhubung',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        provider.isAuthorized
                                            ? 'Data kesehatan tersinkronisasi'
                                            : 'Hubungkan untuk sinkronisasi data',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.black,
            title: const Text(
              'Saya',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 28,
                color: Colors.white,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Color(0xFF6B4EE6),
                          child: Icon(Icons.person, size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'User 001',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'user001@example.com',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildProfileMenuItem(
                    Icons.person_outline,
                    'Profil Saya',
                        () {},
                  ),
                  _buildProfileMenuItem(
                    Icons.notifications_outlined,
                    'Notifikasi',
                        () {},
                  ),
                  _buildProfileMenuItem(
                    Icons.privacy_tip_outlined,
                    'Privasi & Keamanan',
                        () {},
                  ),
                  _buildProfileMenuItem(
                    Icons.help_outline,
                    'Bantuan',
                        () {},
                  ),
                  _buildProfileMenuItem(
                    Icons.info_outline,
                    'Tentang Aplikasi',
                        () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCards() {
    return Consumer<HealthProvider>(
      builder: (context, provider, child) {
        final data = provider.todayHealthData;
        final weeklyData = provider.weeklyHealthData;

        return Column(
          children: [
            _buildHealthCard(
              icon: Icons.favorite,
              iconColor: Colors.red,
              title: 'Detak jantung',
              value: data != null ? '${data['avg_heart_rate']}' : '--',
              unit: 'bpm',
              subtitle: 'Denyut jantung',
              weeklyData: weeklyData.map((d) => d['avg_heart_rate'] as double).toList(),
              onTap: () => _navigateToDetail(context, 'heart'),
            ),
            const SizedBox(height: 12),
            _buildHealthCard(
              icon: Icons.directions_walk,
              iconColor: Colors.blue,
              title: 'Langkah',
              value: data != null ? '${data['steps']}' : '--',
              unit: '',
              subtitle: 'langkah',
              weeklyData: weeklyData.map((d) => (d['steps'] as int).toDouble()).toList(),
              onTap: () => _navigateToDetail(context, 'steps'),
            ),
            const SizedBox(height: 12),
            _buildHealthCard(
              icon: Icons.bedtime,
              iconColor: Colors.purple,
              title: 'Tidur',
              value: data != null ? data['sleep_hours'].toString() : '--',
              unit: '',
              subtitle: 'jam',
              weeklyData: weeklyData.map((d) => d['sleep_duration'] as double).toList(),
              onTap: () => _navigateToDetail(context, 'sleep'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHealthCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String unit,
    required String subtitle,
    required List<double> weeklyData,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    unit.isEmpty ? subtitle : unit,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            if (subtitle.isNotEmpty && unit.isNotEmpty)
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: _buildMiniChart(weeklyData, iconColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniChart(List<double> data, Color color) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'Belum ada data',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      );
    }

    final maxValue = data.reduce((a, b) => a > b ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((value) {
        final heightValue = maxValue > 0 ? (value / maxValue) * 50 : 5.0;
        return Container(
          width: 10,
          height: heightValue,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
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

  Widget _buildDeviceCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.favorite, 'Kesehatan', 0),
              _buildNavItem(Icons.directions_run, 'Aktivitas', 1),
              _buildNavItem(Icons.explore, 'Temukan', 2),
              _buildNavItem(Icons.watch, 'Perangkat', 3),
              _buildNavItem(Icons.person, 'Saya', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF6B4EE6) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF6B4EE6) : Colors.grey[600],
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HealthDetailScreen(
          userId: userId,
          type: type,
        ),
      ),
    );
  }
}

// Detail Screen (sama seperti sebelumnya, hanya update styling)
class HealthDetailScreen extends StatefulWidget {
  final String userId;
  final String type;

  const HealthDetailScreen({
    super.key,
    required this.userId,
    required this.type,
  });

  @override
  State<HealthDetailScreen> createState() => _HealthDetailScreenState();
}

class _HealthDetailScreenState extends State<HealthDetailScreen> {
  int _selectedTab = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _getTitle(),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<HealthProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Bagian Statis (Tabs dan Date Picker)
              Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTabButton('Hari', 0),
                    _buildTabButton('Minggu', 1),
                    _buildTabButton('Bulan', 2),
                  ],
                ),
              ),

              Container(
                color: Colors.black,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: () {},
                    ),
                    Column(
                      children: [
                        Text(
                          _getDateRange(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getAverageText(provider),
                          style: TextStyle(
                            color: _getIconColor().withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Bagian yang Dapat Digulir: Grafik, Deskripsi, dan Daftar Harian
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // GRAFIK
                      Container(
                        color: Colors.black,
                        padding: const EdgeInsets.all(16),
                        // Berikan tinggi yang pasti
                        height: 250,
                        child: _buildDetailChart(provider),
                      ),

                      // DESKRIPSI
                      Container(
                        color: const Color(0xFF1E1E1E),
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          _getDescription(),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),

                      // DAFTAR HARIAN (Gunakan Column dengan map().toList() di dalam SingleChildScrollView)
                      Container(
                        color: Colors.black,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: provider.weeklyHealthData
                              .map((data) => _buildDailyItem(data))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChart(HealthProvider provider) {
    final data = provider.weeklyHealthData;
    if (data.isEmpty) {
      return Center(
        child: Text(
          'Belum ada data',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    final values = _getChartValues(data);
    if (values.isEmpty) {
      return Center(
        child: Text(
          'Belum ada data untuk grafik',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final color = _getIconColor();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        if (index >= values.length) {
          return const SizedBox(width: 40);
        }

        final value = values[index];
        // Maksimum tinggi bar adalah 200 (sesuai tinggi Container di atas)
        final height = maxValue > 0 ? (value / maxValue) * 180 : 5.0;
        final dayLabels = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 40,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dayLabels[index],
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDailyItem(Map<String, dynamic> data) {
    final date = DateTime.parse(data['date']);
    final dayName = _getDayName(date.weekday);
    final dateStr = '${dayName}, ${date.day} ${_getMonthName(date.month)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            widget.type == 'heart'
                ? Icons.favorite
                : widget.type == 'steps'
                ? Icons.directions_walk
                : Icons.bedtime,
            color: _getIconColor(),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _getDailyValue(data),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (widget.type) {
      case 'heart':
        return 'Detak jantung';
      case 'steps':
        return 'Langkah';
      case 'sleep':
        return 'Tidur';
      default:
        return 'Detail';
    }
  }

  Color _getIconColor() {
    switch (widget.type) {
      case 'heart':
        return Colors.red;
      case 'steps':
        return Colors.blue;
      case 'sleep':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getDateRange() {
    return '12-18 Oktober';
  }

  String _getAverageText(HealthProvider provider) {
    final data = provider.weeklyHealthData;
    if (data.isEmpty) return '';

    switch (widget.type) {
      case 'heart':
        final avg = data.map((d) => d['avg_heart_rate'] as double).reduce((a, b) => a + b) / data.length;
        return '${avg.toStringAsFixed(0)} bpm (rata-rata)';
      case 'steps':
        final avg = data.map((d) => d['steps'] as int).reduce((a, b) => a + b) / data.length;
        return '${avg.toStringAsFixed(0)} langkah';
      case 'sleep':
        final avg = data.map((d) => d['sleep_duration'] as double).reduce((a, b) => a + b) / data.length;
        final hours = avg.floor();
        final minutes = ((avg % 1) * 60).floor();
        return 'Rata-rata $hours j $minutes m';
      default:
        return '';
    }
  }

  String _getDescription() {
    switch (widget.type) {
      case 'heart':
        return 'Detak jantung diukur dalam satuan detak per menit (bpm), dan dapat meningkat karena berbagai hal, seperti aktivitas, stres, atau kegembiraan.';
      case 'steps':
        return 'Langkah adalah alat ukur yang berguna untuk mengetahui sebanyak apa Anda bergerak, dan dapat membantu melihat perubahan dalam tingkat aktivitas Anda.';
      case 'sleep':
        return 'Durasi menunjukkan total waktu Anda tertidur setiap malamnya. Sebagian besar orang dewasa sehat membutuhkan antara 7 hingga 9 jam.';
      default:
        return '';
    }
  }

  List<double> _getChartValues(List<Map<String, dynamic>> data) {
    switch (widget.type) {
      case 'heart':
        return data.map((d) => d['avg_heart_rate'] as double).toList();
      case 'steps':
        return data.map((d) => (d['steps'] as int).toDouble()).toList();
      case 'sleep':
        return data.map((d) => d['sleep_duration'] as double).toList();
      default:
        return [];
    }
  }

  String _getDailyValue(Map<String, dynamic> data) {
    switch (widget.type) {
      case 'heart':
        final hr = data['avg_heart_rate'] as double;
        return '${hr.toStringAsFixed(0)} bpm';
      case 'steps':
        return '${data['steps']} langkah';
      case 'sleep':
        final duration = data['sleep_duration'] as double;
        final hours = duration.floor();
        final minutes = ((duration % 1) * 60).floor();
        return '$hours j $minutes m';
      default:
        return '';
    }
  }

  String _getDayName(int weekday) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return months[month - 1];
  }
}