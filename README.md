# Mental Health Tracker - Panduan Implementasi

## 📱 Deskripsi Aplikasi

Mental Health Tracker adalah aplikasi Android untuk memantau kesehatan mental dengan mengintegrasikan:
- ✅ Input manual: Mood harian, kuesioner PHQ-9 & GAD-7
- ✅ Data otomatis: Langkah, detak jantung, dan durasi tidur dari Health Connect
- ✅ Analisis tingkat stress dengan visualisasi data
- ✅ Laporan korelasi antara data subjektif dan objektif

## 🏗️ Struktur Folder Proyek

```
mental_health_tracker/
├── android/
│   └── app/
│       └── src/
│           └── main/
│               └── AndroidManifest.xml  
├── lib/
│   ├── main.dart                        
│   ├── providers/
│   │   ├── health_provider.dart         
│   │   ├── assessment_provider.dart     
│   │   └── mood_provider.dart           
│   ├── screens/
│   │   ├── home_screen.dart             
│   │   ├── mood_input_screen.dart       
│   │   ├── phq9_screen.dart             
│   │   ├── gad7_screen.dart             
│   │   ├── health_sync_screen.dart      
│   │   └── report_screen.dart           
│   └── services/
│       └── database_helper.dart         
└── pubspec.yaml                         
```

## 🚀 Cara Instalasi

### 1. Persiapan

```bash
# Pastikan Flutter SDK terinstall
flutter --version

# Clone atau buat project baru
flutter create mental_health_tracker
cd mental_health_tracker
```

### 2. Copy File-File

Salin semua file yang sudah dibuat ke dalam folder yang sesuai:

1. **pubspec.yaml** → root folder
2. **AndroidManifest.xml** → `android/app/src/main/AndroidManifest.xml`
3. **main.dart** → `lib/main.dart`
4. **database_helper.dart** → `lib/services/database_helper.dart`
5. **health_provider.dart** → `lib/providers/health_provider.dart`
6. **assessment_provider.dart** → `lib/providers/assessment_provider.dart`
7. **mood_provider.dart** → `lib/providers/mood_provider.dart`
8. **home_screen.dart** → `lib/screens/home_screen.dart`
9. **mood_input_screen.dart** → `lib/screens/mood_input_screen.dart`
10. **phq9_screen.dart** → `lib/screens/phq9_screen.dart`
11. **gad7_screen.dart** → `lib/screens/gad7_screen.dart`
12. **health_sync_screen.dart** → `lib/screens/health_sync_screen.dart`
13. **report_screen.dart** → `lib/screens/report_screen.dart`

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Konfigurasi Android

Edit file `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34  // Minimal SDK 34 untuk Health Connect
    
    defaultConfig {
        applicationId "com.example.mental_health_tracker"
        minSdkVersion 26  // Android 8.0
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"
    }
}
```

### 5. Install Health Connect di Device

Aplikasi memerlukan **Google Health Connect** terinstall di perangkat Android:

1. Buka Google Play Store
2. Cari "Health Connect by Google"
3. Install aplikasi
4. Buka Health Connect dan setup akun

### 6. Build & Run

```bash
# Debug mode
flutter run

# Release APK
flutter build apk --release

# Release App Bundle
flutter build appbundle --release
```

## 📋 Fitur Aplikasi

### A. INPUT DATA

#### 1. Input Manual (Data Aktif)

**Mood Harian**
- Pilih emoji mood (😄 😊 😐 😔 😢)
- Tambah catatan opsional
- Simpan setiap hari

**PHQ-9 (Patient Health Questionnaire-9)**
- 9 pertanyaan tentang gejala depresi
- Skor 0-3 per pertanyaan
- Total skor: 0-27
- Kategori: Minimal (0-4), Ringan (5-9), Sedang (10-14), Sedang-Berat (15-19), Berat (20-27)

**GAD-7 (Generalized Anxiety Disorder-7)**
- 7 pertanyaan tentang kecemasan
- Skor 0-3 per pertanyaan
- Total skor: 0-21
- Kategori: Minimal (0-4), Ringan (5-9), Sedang (10-14), Berat (15-21)

#### 2. Data Otomatis (Health Connect)

Setelah memberikan izin, aplikasi otomatis membaca:
- **Langkah Harian**: Total langkah per hari
- **Detak Jantung**: Rata-rata BPM per hari
- **Durasi Tidur**: Jam tidur per malam

### B. PENYIMPANAN DATA

Semua data disimpan di **SQLite Database lokal** dengan tabel:
- `mood_entries`: Data mood harian
- `phq9_assessments`: Hasil PHQ-9
- `gad7_assessments`: Hasil GAD-7
- `health_data`: Data fisiologis dari Health Connect
- `stress_analysis`: Hasil analisis (untuk future development)

### C. ANALISIS & VISUALISASI

#### Dashboard Utama
- Greeting card dengan status
- Quick actions (Input Mood, PHQ-9, GAD-7, Sync)
- Grafik mood 7 hari terakhir
- Ringkasan data kesehatan hari ini
- Hasil asesmen terakhir

#### Laporan Lengkap
- **Pie Chart**: Distribusi tingkat stress (Rendah, Normal, Sedang, Tinggi)
- **Line Chart**: Kombinasi mood dan aktivitas fisik
- **Riwayat Asesmen**: Timeline PHQ-9 dan GAD-7
- **Insight & Korelasi**: 
  - Analisis pola tidur
  - Evaluasi aktivitas fisik
  - Rekomendasi berdasarkan data

## 📊 Cara Menggunakan Aplikasi

### 1. First Time Setup

1. Buka aplikasi
2. Tap "Sinkronisasi" → "Berikan Izin Akses"
3. Izinkan akses ke Health Connect
4. Tap "Sinkronkan 7 Hari Terakhir"

### 2. Penggunaan Harian

**Pagi Hari:**
- Input mood harian
- Cek data kesehatan kemarin

**Berkala (2 minggu sekali):**
- Isi kuesioner PHQ-9
- Isi kuesioner GAD-7

**Kapan Saja:**
- Lihat dashboard untuk trend
- Buka laporan lengkap untuk insight

### 3. Membaca Hasil

**Tingkat Stress:**
- 🟢 Rendah (0-25%): Kondisi mental baik
- 🔵 Normal (25-50%): Kondisi stabil
- 🟠 Sedang (50-75%): Perlu perhatian
- 🔴 Tinggi (75-100%): Konsultasi profesional

**PHQ-9 & GAD-7:**
- Minimal: Tidak perlu intervensi
- Ringan: Self-care & monitoring
- Sedang: Pertimbangkan konsultasi
- Berat: Segera konsultasi profesional

## 🔐 Privacy & Security

- ✅ Data disimpan **lokal** di device
- ✅ Tidak ada data yang dikirim ke server tanpa izin
- ✅ Health Connect menggunakan enkripsi Google
- ✅ User memiliki kontrol penuh atas datanya

## 🐛 Troubleshooting

### Health Connect Tidak Terdeteksi

```bash
# Pastikan Health Connect installed
adb shell pm list packages | grep health

# Jika tidak ada, install dari Play Store
```

### Permission Denied

1. Buka Settings → Apps → Mental Health Tracker
2. Permissions → Allow all required permissions
3. Restart aplikasi

### Data Tidak Tersinkronisasi

1. Pastikan Health Connect memiliki data
2. Cek koneksi smartwatch/fitness tracker
3. Buka Health Connect → Refresh data source
4. Kembali ke aplikasi → Sync ulang

### Build Error

```bash
# Clean build
flutter clean
flutter pub get

# Rebuild
flutter run
```

## 🚀 Future Development

### Phase 2: Backend Integration
- [ ] User authentication
- [ ] Cloud backup
- [ ] Sinkronisasi multi-device
- [ ] Export data ke PDF

### Phase 3: Machine Learning
- [ ] Prediksi episode depresi
- [ ] Rekomendasi personalized
- [ ] Deteksi pola anomali
- [ ] Chatbot support

### Phase 4: Social Features
- [ ] Support group
- [ ] Professional consultation booking
- [ ] Emergency contact system
- [ ] Progress sharing (optional)

## 📚 Referensi

- [Flutter Documentation](https://docs.flutter.dev/)
- [Health Package](https://pub.dev/packages/health)
- [PHQ-9 Questionnaire](https://www.phqscreeners.com/)
- [GAD-7 Questionnaire](https://www.phqscreeners.com/)
- [Health Connect Developer Guide](https://developer.android.com/health-and-fitness/guides/health-connect)

## 📄 License

MIT License - Bebas digunakan untuk tujuan pendidikan dan komersial.

## 👨‍💻 Support

Untuk pertanyaan dan bug report:
- Email: denifirmansyah181003@gmail.com
- GitHub Issues: [Link to repository]

## ⚠️ Disclaimer

Aplikasi ini adalah **alat bantu** untuk monitoring kesehatan mental, bukan pengganti diagnosis atau perawatan profesional. Jika Anda mengalami gejala serius, segera konsultasi dengan psikolog atau psikiater.

---

**Selamat menggunakan Mental Health Tracker! 🧠💚**
