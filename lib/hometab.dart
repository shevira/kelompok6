import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final members = [
      {
        'nama': 'Aldi Karisma',
        'nim': '1203210001',
        'foto': 'assets/aldikarisma.jpg',
      },
      {
        'nama': 'Rina Wijaya',
        'nim': '1203210002',
        'foto': 'assets/rinawijaya.jpg',
      },
      {
        'nama': 'Budi Santoso',
        'nim': '1203210003',
        'foto': 'assets/budisantoso.jpg',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final m = members[index];
          return Card(
            color: Colors.deepPurple.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: CircleAvatar(backgroundImage: AssetImage(m['foto']!)),
              title: Text(
                m['nama']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'NIM: ${m['nim']}',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        },
      ),
    );
  }
}
