import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class InputSoalPage extends StatefulWidget {
  final String kodeKuis;

  const InputSoalPage({super.key, required this.kodeKuis});

  @override
  State<InputSoalPage> createState() => _InputSoalPageState();
}

class _InputSoalPageState extends State<InputSoalPage> {
  final supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  List<dynamic> soalList = [];
  File? imageFile;

  final pertanyaanController = TextEditingController();
  final opsi = List.generate(5, (_) => TextEditingController());
  final nilai = List.generate(5, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _loadSoal();
  }

  Future<void> _loadSoal() async {
    final data = await supabase.from(widget.kodeKuis).select().order('id');
    setState(() => soalList = data);
  }

  Future<String?> _uploadImage(File file) async {
    final fileName = '${const Uuid().v4()}.jpg';
    final bytes = await file.readAsBytes();
    final path = '${widget.kodeKuis}/$fileName';

    final response = await supabase.storage
        .from('soal_gambar')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    if (response.isNotEmpty) {
      final publicUrl = supabase.storage.from('soal_gambar').getPublicUrl(path);
      return publicUrl;
    }

    return null;
  }

  void _showTambahSoalDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Tambah Soal'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: pertanyaanController,
                      decoration: const InputDecoration(
                        labelText: 'Pertanyaan',
                      ),
                      validator:
                          (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(5, (i) {
                      return TextFormField(
                        controller: opsi[i],
                        decoration: InputDecoration(
                          labelText: 'Jawaban ${String.fromCharCode(65 + i)}',
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    ...List.generate(5, (i) {
                      return TextFormField(
                        controller: nilai[i],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:
                              'Nilai Jawaban ${String.fromCharCode(65 + i)}',
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (picked != null) {
                          setState(() => imageFile = File(picked.path));
                        }
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('Upload Gambar (Opsional)'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: _simpanSoal,
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  Future<void> _simpanSoal() async {
    if (!formKey.currentState!.validate()) return;

    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile!);
    }

    final data = {
      'pertanyaan': pertanyaanController.text,
      'gambar': imageUrl,
      'jawaban_a': opsi[0].text,
      'jawaban_b': opsi[1].text,
      'jawaban_c': opsi[2].text,
      'jawaban_d': opsi[3].text,
      'jawaban_e': opsi[4].text,
      'nilai_a': int.tryParse(nilai[0].text) ?? 0,
      'nilai_b': int.tryParse(nilai[1].text) ?? 0,
      'nilai_c': int.tryParse(nilai[2].text) ?? 0,
      'nilai_d': int.tryParse(nilai[3].text) ?? 0,
      'nilai_e': int.tryParse(nilai[4].text) ?? 0,
    };

    await supabase.from(widget.kodeKuis).insert(data);
    Navigator.pop(context);
    _resetForm();
    _loadSoal();
  }

  void _resetForm() {
    pertanyaanController.clear();
    for (var c in opsi) c.clear();
    for (var n in nilai) n.clear();
    imageFile = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Soal - ${widget.kodeKuis}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showTambahSoalDialog,
          ),
        ],
      ),
      body:
          soalList.isEmpty
              ? const Center(child: Text('Belum ada soal'))
              : ListView.builder(
                itemCount: soalList.length,
                itemBuilder: (context, index) {
                  final soal = soalList[index];
                  return ListTile(
                    title: Text(soal['pertanyaan'] ?? '-'),
                    subtitle:
                        soal['gambar'] != null
                            ? Image.network(soal['gambar'], height: 100)
                            : null,
                  );
                },
              ),
    );
  }
}
