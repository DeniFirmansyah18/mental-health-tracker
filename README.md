<div align="center">

# 🧠 Mental Health Tracker

**A Flutter-based Android application for comprehensive mental health monitoring, combining validated clinical assessments with real-time physiological data from Google Health Connect.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-8.0%2B-3DDC84?logo=android&logoColor=white)](https://developer.android.com)
[![Health Connect](https://img.shields.io/badge/Health%20Connect-Integrated-4285F4?logo=google&logoColor=white)](https://developer.android.com/health-and-fitness/guides/health-connect)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](https://github.com/DeniFirmansyah18/mental-health-tracker)

</div>

---

## 📋 Table of Contents

- [About the Project](#-about-the-project)
- [Key Features](#-key-features)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Getting Started](#-getting-started)
- [Project Structure](#-project-structure)
- [Usage Guide](#-usage-guide)
- [Understanding Your Results](#-understanding-your-results)
- [Privacy & Security](#-privacy--security)
- [Troubleshooting](#-troubleshooting)
- [Roadmap](#-roadmap)
- [References](#-references)
- [Disclaimer](#️-disclaimer)
- [License](#-license)
- [Contact](#-contact)

---

<img width="576" height="512" alt="photo_2025-10-15_19-05-50" src="https://github.com/user-attachments/assets/3ac1560c-2d51-48ba-a396-a85f9dbf1e25" /><img width="576" height="512" alt="photo_2025-10-19_19-52-02" src="https://github.com/user-attachments/assets/67b9704b-a609-47d1-81e3-038598a3ff73" /><img width="576" height="512" alt="photo_2025-11-21_19-28-26" src="https://github.com/user-attachments/assets/7612a0f0-c472-4789-82ba-621689d6682b" />



## 📖 About the Project

Mental Health Tracker is an Android mobile application developed as a **thesis (skripsi) project**, designed to bridge the gap between clinical mental health assessment and everyday self-monitoring. It empowers users to track their psychological well-being through a combination of:

- **Subjective inputs** — validated clinical questionnaires (PHQ-9, GAD-7) and daily mood logs
- **Objective biometric data** — steps, heart rate, and sleep duration automatically synced from Google Health Connect
- **Intelligent analytics** — correlation reports and a Spider/Radar Chart for multi-dimensional stress visualization

The app stores all data **locally on the device**, ensuring complete user privacy with no external server dependency.

---

## ✨ Key Features

| Feature | Description |
|---|---|
| 📊 **Daily Mood Tracking** | Log your daily mood using intuitive emoji-based input with optional notes |
| 📝 **PHQ-9 Assessment** | Standardized 9-item Patient Health Questionnaire for depression screening |
| 😰 **GAD-7 Assessment** | 7-item Generalized Anxiety Disorder scale for anxiety measurement |
| 💓 **Health Connect Sync** | Auto-import steps, heart rate, and sleep data from connected wearables |
| 🕸️ **Spider/Radar Chart** | Multi-dimensional stress distribution visualization across 4 severity levels |
| 📈 **Trend Analysis** | 7-day mood & activity line chart for pattern recognition |
| 🔗 **Correlation Reports** | Insight into relationships between physical activity, sleep, and mental health |
| 💾 **Offline-First** | All data stored locally in SQLite — works without internet connectivity |

---

## 🛠 Tech Stack

| Category | Technology |
|---|---|
| **Framework** | [Flutter](https://flutter.dev/) 3.x |
| **Language** | [Dart](https://dart.dev/) 3.9+ |
| **State Management** | [Provider](https://pub.dev/packages/provider) ^6.1.1 |
| **Local Database** | [sqflite](https://pub.dev/packages/sqflite) ^2.3.0 |
| **Health Data** | [health](https://pub.dev/packages/health) ^11.0.0 (Google Health Connect) |
| **Data Visualization** | [fl_chart](https://pub.dev/packages/fl_chart) ^0.68.0 |
| **Internationalization** | [intl](https://pub.dev/packages/intl) ^0.19.0 |
| **Storage** | [shared_preferences](https://pub.dev/packages/shared_preferences) ^2.2.2 |
| **Permissions** | [permission_handler](https://pub.dev/packages/permission_handler) ^11.0.1 |

---

## ✅ Prerequisites

Before you begin, ensure your environment meets the following requirements:

- **Flutter SDK** `3.x` or later → [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** `^3.9.2` (bundled with Flutter)
- **Android Studio** or **VS Code** with Flutter/Dart plugins
- **Android Device or Emulator** running **Android 8.0 (API 26)** or higher
- **Google Health Connect** app installed on the target device ([Download on Play Store](https://play.google.com/store/apps/details?id=com.google.android.apps.healthdata))
- **Android SDK** with `compileSdkVersion 34` configured

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/DeniFirmansyah18/mental-health-tracker.git
cd mental-health-tracker/mental_health_tracker
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Android SDK Versions

Ensure your `android/app/build.gradle` is configured as follows:

```gradle
android {
    compileSdkVersion 34  // Required for Health Connect

    defaultConfig {
        applicationId "com.example.mental_health_tracker"
        minSdkVersion 26    // Android 8.0 minimum
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"
    }
}
```

### 4. Set Up Google Health Connect

The app requires **Google Health Connect** to be installed on the target device:

1. Open the Google Play Store on your Android device
2. Search for **"Health Connect by Google"**
3. Install and open it, then complete the initial account setup
4. Grant the necessary data permissions when prompted by the app

### 5. Run the Application

```bash
# Run in debug mode
flutter run

# Build a release APK
flutter build apk --release

# Build an App Bundle (for Play Store submission)
flutter build appbundle --release
```

---

## 📁 Project Structure

```
mental_health_tracker/
├── android/
│   └── app/
│       └── src/
│           └── main/
│               └── AndroidManifest.xml      # Health Connect permissions
├── lib/
│   ├── main.dart                            # Application entry point
│   ├── providers/
│   │   ├── health_provider.dart             # Health Connect data management
│   │   ├── assessment_provider.dart         # PHQ-9 & GAD-7 logic
│   │   └── mood_provider.dart               # Daily mood state management
│   ├── screens/
│   │   ├── home_screen.dart                 # Main dashboard
│   │   ├── mood_input_screen.dart           # Daily mood logging
│   │   ├── phq9_screen.dart                 # PHQ-9 questionnaire
│   │   ├── gad7_screen.dart                 # GAD-7 questionnaire
│   │   ├── health_sync_screen.dart          # Health Connect sync UI
│   │   └── report_screen.dart               # Analytics & reports
│   └── services/
│       └── database_helper.dart             # SQLite CRUD operations
├── test/                                    # Unit & widget tests
├── pubspec.yaml                             # Project configuration & dependencies
└── analysis_options.yaml                    # Dart linting rules
```

---

## 📱 Usage Guide

### First-Time Setup

1. Launch the application
2. Navigate to the **"Sync"** tab
3. Tap **"Grant Access"** and allow all Health Connect permissions
4. Tap **"Sync Last 7 Days"** to import your historical health data

### Daily Workflow

| When | Action |
|---|---|
| **Morning** | Log your daily mood from the home screen |
| **Any time** | Review the 7-day mood trend on the dashboard |
| **Every 2 weeks** | Complete a PHQ-9 and GAD-7 assessment |
| **Any time** | Open the Report screen to view the Spider Chart and insights |

### Database Schema

All data is persisted locally in an SQLite database with the following tables:

| Table | Contents |
|---|---|
| `mood_entries` | Daily mood logs with timestamps and notes |
| `phq9_assessments` | PHQ-9 questionnaire results and scores |
| `gad7_assessments` | GAD-7 questionnaire results and scores |
| `health_data` | Biometric data synced from Health Connect |
| `stress_analysis` | Computed stress analysis results *(future use)* |

---

## 📊 Understanding Your Results

### PHQ-9 (Depression Screening)

| Score Range | Category | Recommended Action |
|---|---|---|
| 0 – 4 | **Minimal** | No intervention needed; continue monitoring |
| 5 – 9 | **Mild** | Practice self-care; monitor regularly |
| 10 – 14 | **Moderate** | Consider consulting a mental health professional |
| 15 – 19 | **Moderately Severe** | Professional support is strongly recommended |
| 20 – 27 | **Severe** | Seek immediate consultation with a psychologist or psychiatrist |

### GAD-7 (Anxiety Screening)

| Score Range | Category | Recommended Action |
|---|---|---|
| 0 – 4 | **Minimal** | No intervention needed; continue monitoring |
| 5 – 9 | **Mild** | Practice self-care; monitor regularly |
| 10 – 14 | **Moderate** | Consider consulting a mental health professional |
| 15 – 21 | **Severe** | Seek immediate consultation with a professional |

### Spider Chart — Stress Distribution

The Spider/Radar Chart visualizes your stress distribution across 4 dimensions simultaneously:

| Level | Range | Interpretation |
|---|---|---|
| 🟢 **Low** | 0 – 25% | Good mental state; maintain healthy habits |
| 🔵 **Normal** | 25 – 50% | Stable condition; continue routine monitoring |
| 🟠 **Moderate** | 50 – 75% | Elevated stress; increase self-care activities |
| 🔴 **High** | 75 – 100% | Consult a mental health professional promptly |

> **How to read the chart:** A wider area within a category indicates a higher proportion of that stress level. An uneven shape signals stress fluctuations, while a balanced shape suggests a more stable mental state.

---

## 🔐 Privacy & Security

- ✅ **Local Storage Only** — All personal and health data is stored exclusively on your device
- ✅ **No External Transmission** — No data is sent to any remote server without explicit user action
- ✅ **Google Encryption** — Health Connect data is encrypted at rest by Google's platform
- ✅ **Full User Control** — You can revoke Health Connect permissions or delete all data at any time

---

## 🐛 Troubleshooting

### Health Connect Not Detected

```bash
# Check if Health Connect is installed via ADB
adb shell pm list packages | grep health

# If missing, install it from the Play Store
```

### Permission Denied

1. Open **Settings → Apps → Mental Health Tracker**
2. Go to **Permissions** and grant all required permissions
3. Restart the application

### Data Not Syncing

1. Confirm that Google Health Connect contains data from your connected device
2. Verify your smartwatch or fitness tracker is synced with Health Connect
3. In Health Connect, tap **Refresh** on the data source
4. Return to the app and initiate sync again

### Spider Chart Not Rendering

1. Ensure you have logged mood data for **at least 3 consecutive days**
2. Complete at least one PHQ-9 and GAD-7 assessment for a full analysis
3. Pull down on the Report screen to refresh
4. If the issue persists, restart the application

### Build Errors

```bash
# Clean the build cache and reinstall dependencies
flutter clean
flutter pub get

# Re-run the application
flutter run
```

---

## 🗺 Roadmap

### Phase 2 — Backend Integration
- [ ] User authentication (OAuth 2.0)
- [ ] Cloud backup and restore
- [ ] Multi-device synchronization
- [ ] Export reports to PDF (including Spider Chart)

### Phase 3 — Machine Learning
- [ ] Predictive modeling for depression episode detection
- [ ] Personalized recommendations based on behavioral patterns
- [ ] Anomaly detection in stress distribution
- [ ] AI-powered chatbot with mental health support

### Phase 4 — Social & Professional Features
- [ ] Peer support groups
- [ ] Professional consultation booking
- [ ] Emergency contact integration
- [ ] Optional progress sharing with privacy controls

### Phase 5 — Enhanced Visualization
- [ ] Additional chart types: Bar chart, Area chart
- [ ] Cross-period comparison (weekly, monthly views)
- [ ] Animated Spider Chart transitions
- [ ] Interactive chart tooltips

---

## 📚 References

- [Flutter Documentation](https://docs.flutter.dev/)
- [health Package (pub.dev)](https://pub.dev/packages/health)
- [fl_chart Package (pub.dev)](https://pub.dev/packages/fl_chart)
- [PHQ-9 Screener](https://www.phqscreeners.com/)
- [GAD-7 Screener](https://www.phqscreeners.com/)
- [Health Connect Developer Guide](https://developer.android.com/health-and-fitness/guides/health-connect)
- [Radar/Spider Chart Best Practices — Data to Viz](https://www.data-to-viz.com/caveat/spider.html)

---

## ⚠️ Disclaimer

> This application is a **self-monitoring tool** intended to assist users in tracking their mental health trends. It is **not a substitute** for professional medical diagnosis, clinical evaluation, or psychiatric treatment.
>
> If you are experiencing severe symptoms of depression, anxiety, or any other mental health condition, please seek immediate assistance from a licensed psychologist, psychiatrist, or mental health professional.
>
> The Spider Chart visualization is provided for informational purposes only and **cannot be used as a medical diagnosis**.

---

## 📄 License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for more information.

---

## 📬 Contact

**Deni Firmansyah**

- 📧 Email: [denifirmansyah181003@gmail.com](mailto:denifirmansyah181003@gmail.com)
- 🐙 GitHub: [@DeniFirmansyah18](https://github.com/DeniFirmansyah18)
- 🐛 Bug Reports: [Open an Issue](https://github.com/DeniFirmansyah18/mental-health-tracker/issues)

---

<div align="center">

**Made with ❤️ for a healthier mind**

*Mental Health Tracker v1.0.0*

</div>
