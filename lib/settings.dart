
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    final nama = user?.userMetadata?['nama'] ?? 'Nama tidak ditemukan';
    final nim = user?.userMetadata?['nim'] ?? '-';
    final status = user?.userMetadata?['status'] ?? '-';
    final email = user?.email ?? '-';
    final photoUrl = user?.userMetadata?['photoUrl'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.teal[700], // Sesuaikan warna tema
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Foto profil
            Center(
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.teal[900],
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl) : null,
                child:
                    photoUrl == null
                        ? const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 16),

            // Card Data Profil
            Card(
              color: const Color(0xFF1E1E1E),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildProfileRow('Nama Lengkap', nama),
                    _buildProfileRow('NIM/NIP', nim),
                    _buildProfileRow('Status', status),
                    _buildProfileRow('Email', email),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Ubah Password
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigasi ke halaman ubah password
              },
              icon: const Icon(Icons.lock_reset),
              label: const Text('Ubah Password'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                backgroundColor: Colors.teal[600],
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}