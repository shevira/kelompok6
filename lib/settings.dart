import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? data;
  bool loading = true;
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;

    final res =
        await supabase.from('users').select().eq('id', uid).maybeSingle();
    setState(() {
      data = res;
      photoUrl = res?['photo_url'];
      loading = false;
    });
  }

  Future<void> _changePhoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 60);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final uid = supabase.auth.currentUser!.id;
      final fileName = 'profile_$uid.jpg';

      await supabase.storage
          .from('profile_photos')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = supabase.storage
          .from('profile_photos')
          .getPublicUrl(fileName);

      await supabase
          .from('users')
          .update({'photo_url': publicUrl})
          .eq('id', uid);
      setState(() => photoUrl = publicUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diperbarui')),
      );
    }
  }

  Future<void> _pickPhotoSource() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Text(
                "Ganti Foto Profil",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Pilih dari Galeri"),
                onTap: () {
                  Navigator.pop(context);
                  _changePhoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Ambil dari Kamera"),
                onTap: () {
                  Navigator.pop(context);
                  _changePhoto(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = supabase.auth.currentUser?.email ?? '-';
    final nama = data?['full_name'] ?? 'Nama tidak ditemukan';
    final nim = data?['nim_nip'] ?? '-';
    final status = data?['status'] ?? '-';

    return Scaffold(
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage:
                              photoUrl != null
                                  ? NetworkImage(photoUrl!)
                                  : const AssetImage(
                                        'assets/images/profile_default.jpg',
                                      )
                                      as ImageProvider,
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.teal),
                          onPressed: _pickPhotoSource,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Profile Table
                    Card(
                      color: const Color(0xFFF5F5F5),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Table(
                          columnWidths: const {
                            0: IntrinsicColumnWidth(),
                            1: FixedColumnWidth(10),
                            2: FlexColumnWidth(),
                          },
                          children: [
                            _buildRow('Nama Lengkap', nama),
                            _buildRow('NIM/NIP', nim),
                            _buildRow('Status', status),
                            _buildRow('Email', email),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      onPressed: () => _showEditProfileDialog(context),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showPasswordDialog(context),
                      icon: const Icon(Icons.lock_reset),
                      label: const Text('Ubah Password'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await supabase.auth.signOut();
                        if (context.mounted) context.go('/login');
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Keluar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  TableRow _buildRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(':'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(value),
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final namaController = TextEditingController(
      text: data?['full_name'] ?? '',
    );
    final nimController = TextEditingController(text: data?['nim_nip'] ?? '');

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Edit Profil'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                ),
                TextField(
                  controller: nimController,
                  decoration: const InputDecoration(labelText: 'NIM/NIP'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newName = namaController.text.trim();
                  final newNim = nimController.text.trim();
                  final uid = supabase.auth.currentUser?.id;

                  if (uid != null) {
                    await supabase
                        .from('users')
                        .update({'full_name': newName, 'nim_nip': newNim})
                        .eq('id', uid);
                    if (context.mounted) {
                      Navigator.pop(context);
                      _loadProfile();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil berhasil diperbarui'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Ubah Password'),
            content: TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Baru'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newPass = controller.text.trim();
                  if (newPass.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password minimal 6 karakter'),
                      ),
                    );
                    return;
                  }
                  try {
                    await supabase.auth.updateUser(
                      UserAttributes(password: newPass),
                    );
                    if (context.mounted) Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password berhasil diubah')),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }
}
