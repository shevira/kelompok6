
// File: teacher_main_tabs.dart
import 'package:flutter/material.dart';
import 'package:tubesmob/hometab.dart';
import 'package:tubesmob/input_kuis_page.dart';
import 'package:tubesmob/scan_kuis.dart';
import 'package:tubesmob/settings.dart';

class TeacherMainTabs extends StatefulWidget {
  const TeacherMainTabs({super.key});

  @override
  State<TeacherMainTabs> createState() => _TeacherMainTabsState();
}

class _TeacherMainTabsState extends State<TeacherMainTabs> {
  int _currentIndex = 0;

  final _pages = [
    const HomeTab(),
    const InputKuisPage(),
    const ScanKuisPage(),
    const SettingsTab(),
  ];

  final _titles = ['Home', 'Input Kuis', 'Lihat Kuis', 'Pengaturan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF009688), Color(0xFF4DB6AC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.6),
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.edit),
                label: 'Input Kuis',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.qr_code),
                label: 'Lihat Kuis',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}