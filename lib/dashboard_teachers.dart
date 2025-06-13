import 'package:flutter/material.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Teacher')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Selamat datang, Teacher!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/kelas');
              },
              child: const Text('Input / Kelola Kelas & Kuis'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/kelola-soal');
              },
              child: const Text('Kelola Soal Kuis'),
            ),
          ],
        ),
      ),
    );
  }
}
