import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Panduan Aplikasi',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Pengenalan Aplikasi'),
          _buildGuideCard(
            context,
            icon: Icons.favorite,
            color: const Color(0xFF6B4EE6),
            title: 'Apa itu Mental Health Tracker?',
            preview: 'Kenali fitur utama dan manfaat aplikasi ini.',
            content: '''
Mental Health Tracker adalah aplikasi untuk membantu kamu memantau kesehatan mental sehari-hari secara mudah dan terukur.

📌 Fitur Utama:
• Tab Kesehatan — lihat ringkasan data detak jantung, langkah, dan tidur
• Tab Aktivitas — isi mood harian dan kuesioner kesehatan mental
• Tab Temukan — akses laporan dan tips kesehatan mental
• Tab Perangkat — sambungkan ke Health Connect untuk data otomatis
• Tab Saya — kelola profil dan pengaturan

Aplikasi ini TIDAK mengirim data ke server manapun. Semua data tersimpan hanya di perangkat kamu.
''',
          ),
          const SizedBox(height: 12),
          _buildSectionHeader('Cara Menggunakan Fitur'),
          _buildGuideCard(
            context,
            icon: Icons.mood,
            color: const Color(0xFFFF6B9D),
            title: 'Input Mood Harian',
            preview: 'Catat perasaan kamu setiap hari.',
            content: '''
Mood harian membantu kamu melacak perubahan suasana hati dari waktu ke waktu.

📋 Langkah-langkah:
1. Buka tab "Aktivitas" (ikon orang berlari di bawah)
2. Ketuk "Input Mood Harian"
3. Pilih emoji yang paling menggambarkan perasaanmu hari ini
4. Tambahkan catatan singkat jika ingin (opsional)
5. Ketuk "Simpan"

💡 Tips:
• Isi mood setiap hari agar data lebih akurat
• Waktu terbaik adalah pagi hari atau sebelum tidur
• Data mood bisa dilihat di laporan mingguan
''',
          ),
          const SizedBox(height: 12),
          _buildGuideCard(
            context,
            icon: Icons.assignment_outlined,
            color: const Color(0xFF4ECDC4),
            title: 'Kuesioner PHQ-9 (Skrining Depresi)',
            preview: 'Panduan mengisi kuesioner PHQ-9.',
            content: '''
PHQ-9 adalah kuesioner standar medis untuk mendeteksi gejala depresi. Terdiri dari 9 pertanyaan sederhana.

📋 Langkah-langkah:
1. Buka tab "Aktivitas"
2. Ketuk "Kuesioner PHQ-9"
3. Baca setiap pertanyaan dengan seksama
4. Pilih jawaban yang paling sesuai (0 = Tidak pernah, 3 = Hampir setiap hari)
5. Ketuk "Selesai" untuk melihat hasil

📊 Interpretasi Skor:
• 0–4 : Minimal / Tidak ada gejala
• 5–9 : Gejala ringan
• 10–14: Gejala sedang
• 15–19: Gejala agak berat
• 20–27: Gejala berat

⚠️ Penting: Hasil ini BUKAN diagnosis medis. Jika skor tinggi, segera konsultasi dengan profesional kesehatan mental.
''',
          ),
          const SizedBox(height: 12),
          _buildGuideCard(
            context,
            icon: Icons.psychology_outlined,
            color: const Color(0xFFFFA726),
            title: 'Kuesioner GAD-7 (Skrining Kecemasan)',
            preview: 'Panduan mengisi kuesioner GAD-7.',
            content: '''
GAD-7 adalah kuesioner untuk mengukur tingkat kecemasan (anxiety). Terdiri dari 7 pertanyaan.

📋 Langkah-langkah:
1. Buka tab "Aktivitas"
2. Ketuk "Kuesioner GAD-7"
3. Baca setiap pertanyaan dan pilih jawaban jujur
4. Ketuk "Selesai" untuk melihat hasil

📊 Interpretasi Skor:
• 0–4 : Kecemasan minimal
• 5–9 : Kecemasan ringan
• 10–14: Kecemasan sedang
• 15–21: Kecemasan berat

💡 Disarankan mengisi kuesioner ini setiap 2 minggu sekali untuk memantau perkembangan.
''',
          ),
          const SizedBox(height: 12),
          _buildSectionHeader('Sinkronisasi Data Kesehatan'),
          _buildGuideCard(
            context,
            icon: Icons.watch,
            color: const Color(0xFF66BB6A),
            title: 'Menghubungkan Health Connect',
            preview: 'Cara menghubungkan aplikasi ke Health Connect.',
            content: '''
Health Connect adalah platform Google yang mengumpulkan data dari berbagai aplikasi kesehatan di Android.

📋 Langkah menghubungkan:
1. Buka tab "Perangkat" (ikon jam tangan di bawah)
2. Ketuk "Health Connect"
3. Ketuk tombol "Berikan Izin Akses"
4. Dialog izin akan muncul — ketuk "Izinkan" untuk setiap data (Langkah, Detak Jantung, Tidur)
5. Kembali ke aplikasi — status akan berubah menjadi "Terhubung"

✅ Setelah terhubung, kamu bisa:
• Sinkronkan Data Hari Ini — ambil data hari ini saja
• Sinkronkan 7 Hari Terakhir — ambil data seminggu ke belakang
• Sinkronkan Riwayat 90 Hari — ambil data 3 bulan ke belakang (proses 1–3 menit)

⚠️ Jika tombol izin tidak muncul, pastikan aplikasi Health Connect sudah terpasang di HP kamu.
''',
          ),
          const SizedBox(height: 12),
          _buildGuideCard(
            context,
            icon: Icons.sync_alt,
            color: const Color(0xFF29B6F6),
            title: 'Menghubungkan Huawei Health via Health Sync',
            preview: 'Panduan lengkap sinkronisasi Huawei Health ke Health Connect.',
            content: '''
Huawei Health tidak langsung terhubung ke Health Connect Google. Kamu perlu aplikasi perantara bernama Health Sync.

━━━━━━━━━━━━━━━━━━━━━
LANGKAH 1: Pasang Aplikasi yang Diperlukan
━━━━━━━━━━━━━━━━━━━━━
Pastikan ketiga aplikasi ini sudah terpasang:
① Huawei Health (sudah terinstal jika pakai smartwatch Huawei)
② Health Connect — unduh di Play Store (gratis, oleh Google)
③ Health Sync — unduh di Play Store (berbayar ~Rp30.000, oleh Baltic Data)

━━━━━━━━━━━━━━━━━━━━━
LANGKAH 2: Atur Health Connect
━━━━━━━━━━━━━━━━━━━━━
1. Buka aplikasi Health Connect
2. Masuk ke "Izin Aplikasi"
3. Cari "Health Sync" → Berikan semua izin baca & tulis
4. Cari "Mental Health Tracker" → Berikan izin baca

━━━━━━━━━━━━━━━━━━━━━
LANGKAH 3: Konfigurasi Health Sync
━━━━━━━━━━━━━━━━━━━━━
1. Buka aplikasi Health Sync
2. Ketuk "Add Sync" atau tombol "+"
3. Pilih sumber data: "Huawei Health"
4. Pilih tujuan: "Health Connect"
5. Pilih tipe data yang ingin disinkronkan:
   ✓ Steps (Langkah)
   ✓ Heart Rate (Detak Jantung)
   ✓ Sleep (Tidur)
6. Ketuk "Start Sync" atau "Sinkronkan"
7. Tunggu proses selesai (biasanya 1–5 menit)

━━━━━━━━━━━━━━━━━━━━━
LANGKAH 4: Sinkronkan ke Aplikasi Ini
━━━━━━━━━━━━━━━━━━━━━
1. Kembali ke Mental Health Tracker
2. Buka tab "Perangkat" → ketuk "Health Connect"
3. Jika belum terhubung, ketuk "Berikan Izin Akses"
4. Ketuk "Sinkronkan Data Hari Ini" atau "7 Hari Terakhir"
5. Data dari Huawei Health kini muncul di aplikasi!

💡 Tips agar sinkronisasi berjalan lancar:
• Jalankan Health Sync sebelum membuka aplikasi ini
• Pastikan Huawei Health sudah sync dengan smartwatch kamu
• Aktifkan sinkronisasi otomatis di Health Sync agar data selalu terbaru
• Jika data tidak muncul, coba "Sinkronkan Riwayat 90 Hari"
''',
          ),
          const SizedBox(height: 12),
          _buildSectionHeader('Tips & Informasi'),
          _buildGuideCard(
            context,
            icon: Icons.bar_chart,
            color: const Color(0xFF6B4EE6),
            title: 'Melihat Laporan Kesehatan',
            preview: 'Cara membaca dan memahami laporan.',
            content: '''
Laporan memberikan gambaran menyeluruh tentang kondisi kesehatan mental dan fisik kamu.

📋 Cara mengakses:
1. Buka tab "Temukan" (ikon kompas di bawah)
2. Ketuk "Laporan Lengkap"
3. Lihat grafik dan ringkasan data

📊 Yang bisa kamu lihat:
• Tren mood mingguan
• Skor PHQ-9 dan GAD-7 dari waktu ke waktu
• Data fisik (langkah, detak jantung, tidur)
• Korelasi antara aktivitas fisik dan mood

💡 Semakin rutin kamu mengisi data, semakin akurat laporannya.
''',
          ),
          const SizedBox(height: 12),
          _buildGuideCard(
            context,
            icon: Icons.privacy_tip_outlined,
            color: const Color(0xFF78909C),
            title: 'Privasi & Keamanan Data',
            preview: 'Bagaimana data kamu dijaga.',
            content: '''
Privasi kamu adalah prioritas utama kami.

🔒 Fakta keamanan data:
• Semua data disimpan HANYA di perangkat kamu
• Tidak ada data yang dikirim ke server atau internet
• Tidak ada akun yang diperlukan untuk menggunakan aplikasi
• Data Health Connect hanya dibaca, tidak diubah

📂 Penyimpanan data:
• Database lokal di memori internal HP
• Data tidak hilang saat menutup aplikasi
• Data bisa hilang jika aplikasi dihapus (uninstall)

💡 Saran: Catat atau screenshot laporan penting sebelum menghapus aplikasi.
''',
          ),
          const SizedBox(height: 12),
          _buildGuideCard(
            context,
            icon: Icons.help_outline,
            color: const Color(0xFFEF5350),
            title: 'Pertanyaan Umum (FAQ)',
            preview: 'Jawaban untuk pertanyaan yang sering ditanyakan.',
            content: '''
❓ Data saya tidak muncul setelah sinkronisasi?
→ Pastikan sudah memberikan izin di Health Connect. Coba tekan "Sinkronkan 7 Hari Terakhir".

❓ Health Sync apa gratis?
→ Health Sync tersedia gratis dengan fitur terbatas, dan berbayar (~Rp30.000) untuk fitur penuh termasuk sinkronisasi otomatis.

❓ Apakah aplikasi ini pengganti dokter?
→ TIDAK. Aplikasi ini hanya alat bantu pemantauan mandiri. Selalu konsultasikan kondisi kesehatan ke profesional medis.

❓ Smartwatch Huawei saya tidak terbaca?
→ Pastikan Huawei Health sudah sync dengan smartwatch. Kemudian jalankan Health Sync. Tunggu beberapa menit sebelum sinkronisasi di aplikasi ini.

❓ Apakah data saya aman jika ganti HP?
→ Data tersimpan lokal, jadi tidak otomatis pindah. Kamu perlu memasang ulang aplikasi dan sinkronisasi ulang dari Health Connect.

❓ Kenapa skor PHQ-9/GAD-7 saya tinggi?
→ Skor tinggi bukan berarti kamu "sakit". Ini hanya indikator. Segera konsultasikan ke psikolog atau psikiater terdekat untuk evaluasi lebih lanjut.
''',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.favorite, color: Color(0xFF6B4EE6), size: 28),
                const SizedBox(height: 8),
                const Text(
                  'Mental Health Tracker v1.0',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dibuat untuk membantu kamu lebih peduli terhadap kesehatan mental.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildGuideCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String preview,
    required String content,
  }) {
    return InkWell(
      onTap: () => _showGuideDetail(context, icon: icon, color: color, title: title, content: content),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    preview,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
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

  void _showGuideDetail(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String content,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 24),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  children: [
                    Text(
                      content.trim(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
