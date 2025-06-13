import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Student')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Selamat datang, Student!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/scan-kuis');
              },
              child: const Text('Masukkan/Scan Kode Kuis'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/lihat-nilai');
              },
              child: const Text('Lihat Nilai'),
            ),
          ],
        ),
      ),
    );
  }
}
