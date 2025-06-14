// main.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tubesmob/dashboard_student.dart';
import 'package:tubesmob/dashboard_teachers.dart';
import 'package:tubesmob/input_kuis_page.dart';
import 'package:tubesmob/input_soal.dart';
import 'package:tubesmob/login_page.dart';
import 'package:tubesmob/manual_token_reset.dart';
import 'package:tubesmob/pengerjaan_kuis_page.dart';
import 'package:tubesmob/registerpage.dart';
import 'package:tubesmob/scan_kuis.dart';
import 'package:tubesmob/update_password.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://llebmrhpegbineaatydc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxsZWJtcmhwZWdiaW5lYWF0eWRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk3OTExNzgsImV4cCI6MjA2NTM2NzE3OH0.xLnxYnCYPv9MLujg4wfiiHi3dT2dCrnB174Yq2eLZhY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kuis Online',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/dashboard-student',
      builder: (context, state) => const StudentMainTabs(),
    ),
    GoRoute(
      path: '/dashboard-teacher',
      builder: (context, state) => const TeacherMainTabs(),
    ),
    GoRoute(
      path: '/scan-kuis',
      builder:
          (context, state) => const ScanKuisPage(), // nanti kamu buat file ini
    ),
    GoRoute(
      path: '/kerjakan-kuis',
      builder: (context, state) {
        final kode_kuis = (state.extra as Map)['kode_kuis'];
        return PengerjaanKuisPage(kode_kuis: kode_kuis);
      },
    ),
    GoRoute(
      path: '/buat-soal',
      builder: (context, state) {
        final kodeKuis = (state.extra as Map)['kodeKuis'];
        return BuatSoalPage(kodeKuis: kodeKuis);
      },
    ),
    GoRoute(path: '/kelas', builder: (context, state) => const InputKuisPage()),

    GoRoute(
      path: '/reset-password',
      builder: (context, state) => ResetPassword(),
    ),
    GoRoute(
      path: '/reset-token',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return ManualTokenResetPage(email: email);
      },
    ),
  ],
);
