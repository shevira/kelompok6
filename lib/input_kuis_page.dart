import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InputKuisPage extends StatefulWidget {
  const InputKuisPage({super.key});

  @override
  State<InputKuisPage> createState() => _InputKuisPageState();
}

class _InputKuisPageState extends State<InputKuisPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mkController = TextEditingController();
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> kelasList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadKelas();
  }

  Future<void> _loadKelas() async {
    final data = await supabase.from('kelas').select().order('id');
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

    final mk = _mkController.text.trim();
    final kodeKuis = _generateKodeKuis();
    final userId = supabase.auth.currentUser?.id;
    final createdAt = DateTime.now().toIso8601String();

    try {
      setState(() => loading = true);

      await supabase.from('kelas').insert({
        // 'id': idMK, // Dihapus karena kolom id bertipe serial
        'mata_kuliah': mk,
        'kode_kuis': kodeKuis,
        'created_by': userId,
        'created_at': createdAt,
      });

      _mkController.clear();
      await _loadKelas(); // refresh list
    } catch (e) {
      debugPrint('Error saat insert kelas: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambahkan kelas: $e')));
      setState(() => loading = false);
    }
  }

  void _showKelasDetail(Map<String, dynamic> kelas) {
    final qrKey = GlobalKey();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('Detail Kelas: ${kelas['mata_kuliah']}'),
            content: SizedBox(
              width: 300,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Kode Kuis: ${kelas['kode_kuis']}'),
                    const SizedBox(height: 16),
                    RepaintBoundary(
                      key: qrKey,
                      child: QrImageView(data: kelas['kode_kuis'], size: 160),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push(
                          '/buat-soal',
                          extra: {'kodeKuis': kelas['kode_kuis']},
                        );
                      },
                      icon: const Icon(Icons.edit_note),
                      label: const Text("Buat / Kelola Soal"),
                    ),
                    const SizedBox(height: 8),
                    // ElevatedButton.icon(
                    //   onPressed:
                    //       () => _simpanQrSebagaiPng(qrKey, kelas['kode_kuis']),
                    //   icon: const Icon(Icons.download),
                    //   label: const Text("Simpan QR sebagai PNG"),
                    // ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  // Future<void> _simpanQrSebagaiPng(GlobalKey key, String kodeKuis) async {
  //   try {
  //     // Minta izin akses penyimpanan
  //     final status = await Permission.storage.request();
  //     if (!status.isGranted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Izin penyimpanan ditolak")),
  //       );
  //       return;
  //     }

  //     // Ambil render boundary dari RepaintBoundary
  //     RenderRepaintBoundary boundary =
  //         key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  //     final image = await boundary.toImage(pixelRatio: 3.0);
  //     final byteData = await image.toByteData(format: ImageByteFormat.png);
  //     final pngBytes = byteData!.buffer.asUint8List();

  //     // Simpan ke galeri
  //     final result = await ImageGallerySaver.saveImage(
  //       pngBytes,
  //       name: 'qr_$kodeKuis',
  //     );
  //     final success = result['isSuccess'];

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(success ? 'QR disimpan ke galeri' : 'Gagal simpan QR'),
  //       ),
  //     );
  //   } catch (e) {
  //     debugPrint('Gagal simpan QR: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child:
            loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Input / Kelola Kelas & Kuis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _mkController,
                              decoration: InputDecoration(
                                hintText: 'Masukkan Nama Mata Kuliah',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Wajib diisi'
                                          : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _createKelas,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Tambah'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Daftar Kelas:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: kelasList.length,
                        itemBuilder: (context, index) {
                          final item = kelasList[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
