import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';
import 'screens/mood_input_screen.dart';
import 'screens/phq9_screen.dart';
import 'screens/gad7_screen.dart';
import 'screens/health_sync_screen.dart';
import 'screens/report_screen.dart';
import 'providers/health_provider.dart';
import 'providers/assessment_provider.dart';
import 'providers/mood_provider.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await DatabaseHelper.instance.database;

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider(create: (_) => AssessmentProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
      ],
      child: MaterialApp(
        title: 'Mental Health Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6B4EE6),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        home: const HomeScreen(),
        routes: {
          '/mood': (context) => const MoodInputScreen(),
          '/phq9': (context) => const PHQ9Screen(),
          '/gad7': (context) => const GAD7Screen(),
          '/health-sync': (context) => const HealthSyncScreen(),
          '/report': (context) => const ReportScreen(),
        },
      ),
    );
  }
}