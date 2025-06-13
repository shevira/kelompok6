import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';

class InputKuisPage extends StatefulWidget {
  const InputKuisPage({super.key});

  @override
  State<InputKuisPage> createState() => _InputKuisPageState();
}

class _InputKuisPageState extends State<InputKuisPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController mkController = TextEditingController();
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> kelasList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadKelas();
  }

  Future<void> _loadKelas() async {
    final data = await supabase.from('kelas').select().order('id_mk');
    setState(() {
      kelasList = List<Map<String, dynamic>>.from(data);
      loading = false;
    });
  }

  String _generateKodeKuis() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ123456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _createKelas() async {
    if (!_formKey.currentState!.validate()) return;

    final mk = mkController.text.trim();
    final kodeKuis = _generateKodeKuis();

    await supabase.from('kelas').insert({
      'mata_kuliah': mk,
      'kode_kuis': kodeKuis,
    });

    mkController.clear();
    _loadKelas();
  }

  void _showKelasDetail(Map<String, dynamic> kelas) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Detail Kelas: ${kelas['mata_kuliah']}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Kode Kuis: ${kelas['kode_kuis']}'),
                const SizedBox(height: 16),
                QrImageView(data: kelas['kode_kuis'], size: 150),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit_document),
                  label: const Text("Kelola Soal"),
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/kelola-soal', extra: kelas['kode_kuis']);
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Input / Kelola Kelas & Kuis')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      key: _formKey,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: mkController,
                              decoration: const InputDecoration(
                                labelText: 'Mata Kuliah',
                                border: OutlineInputBorder(),
                              ),
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Wajib diisi'
                                          : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _createKelas,
                            child: const Text('Tambah'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Daftar Kelas:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: kelasList.length,
                        itemBuilder: (context, index) {
                          final item = kelasList[index];
                          return Card(
                            child: ListTile(
                              title: Text(item['mata_kuliah']),
                              subtitle: Text('Kode: ${item['kode_kuis']}'),
                              trailing: const Icon(Icons.qr_code),
                              onTap: () => _showKelasDetail(item),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
