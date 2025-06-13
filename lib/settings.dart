import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? dataUser;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // Cari user berdasarkan email
    final response =
        await supabase.from('USER').select().eq('email', user.email!).single();

    setState(() {
      dataUser = response;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 16),
            Text(
              dataUser?['nama_lengkap'] ?? '-',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('NIM/NIP: ${dataUser?['nim_nip'] ?? '-'}'),
            Text('Status: ${dataUser?['status'] ?? '-'}'),
            Text('Email: ${dataUser?['email'] ?? '-'}'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigasi ke halaman ubah password
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Fitur ubah password coming soon"),
                  ),
                );
              },
              icon: const Icon(Icons.lock_reset),
              label: const Text('Ubah Password'),
            ),
          ],
        ),
      ),
    );
  }
}
