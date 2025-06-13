import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tubesmob/dashboard_student.dart';
import 'package:tubesmob/dashboard_teachers.dart';
import 'package:tubesmob/input_kuis_page.dart';
import 'package:tubesmob/input_soal.dart';
import 'package:tubesmob/lihat_nilai.dart';
import 'package:tubesmob/login_page.dart';
import 'package:tubesmob/registerpage.dart';
import 'package:tubesmob/scan_kuis.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
      builder: (context, state) => const StudentDashboard(),
    ),
    GoRoute(
      path: '/dashboard-teacher',
      builder: (context, state) => const TeacherDashboard(),
    ),
    GoRoute(
      path: '/scan-kuis',
      builder:
          (context, state) => const ScanKuisPage(), // nanti kamu buat file ini
    ),
    GoRoute(
      path: '/lihat-nilai',
      builder: (context, state) => const LihatNilaiPage(), // dan file ini juga
    ),
    GoRoute(
      path: '/buat-soal',
      builder: (context, state) {
        final kodeKuis = (state.extra as Map)['kodeKuis'];
        return InputSoalPage(kodeKuis: kodeKuis);
      },
    ),
    // GoRoute(
    //   path: '/input-kuis',
    //   builder: (context, state) => const InputKuisPage(),
    // ),
    GoRoute(path: '/kelas', builder: (context, state) => const InputKuisPage()),
  ],
);
