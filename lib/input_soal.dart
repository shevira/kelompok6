import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class BuatSoalPage extends StatefulWidget {
  final String kodeKuis;

  const BuatSoalPage({super.key, required this.kodeKuis});

  @override
  State<BuatSoalPage> createState() => _BuatSoalPageState();
}

class _BuatSoalPageState extends State<BuatSoalPage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  final picker = ImagePicker();

  File? _pickedImage;
  String? _uploadedImageUrl;
  bool isEditing = false;
  int? editingId;

  final _pertanyaan = TextEditingController();
  final _a = TextEditingController();
  final _b = TextEditingController();
  final _c = TextEditingController();
  final _d = TextEditingController();
  final _e = TextEditingController();

  final _nilaiA = TextEditingController();
  final _nilaiB = TextEditingController();
  final _nilaiC = TextEditingController();
  final _nilaiD = TextEditingController();
  final _nilaiE = TextEditingController();

  Map<String, bool> jawabanBenar = {
    'A': false,
    'B': false,
    'C': false,
    'D': false,
    'E': false,
  };

  List<Map<String, dynamic>> daftarSoal = [];

  @override
  void initState() {
    super.initState();
    _loadSoal();
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      final fileBytes = await file.readAsBytes();
      final filename = 'soal_${const Uuid().v4()}.jpg';

      final response = await supabase.storage
          .from(widget.kodeKuis)
          .uploadBinary(
            filename,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      if (response.isNotEmpty) {
        final url = supabase.storage
            .from(widget.kodeKuis)
            .getPublicUrl(filename);
        setState(() {
          _pickedImage = file;
          _uploadedImageUrl = url;
        });
      }
    }
  }

  Future<void> _loadSoal() async {
    final res = await supabase
        .from('soal')
        .select()
        .eq('kode_kuis', widget.kodeKuis)
        .order('id');

    setState(() {
      daftarSoal = List<Map<String, dynamic>>.from(res);
    });
  }

  void _isiUlangForm(Map<String, dynamic> soal) {
    setState(() {
      editingId = soal['id'];
      isEditing = true;
      _pertanyaan.text = soal['pertanyaan'] ?? '';
      _a.text = soal['opsi_a'] ?? '';
      _b.text = soal['opsi_b'] ?? '';
      _c.text = soal['opsi_c'] ?? '';
      _d.text = soal['opsi_d'] ?? '';
      _e.text = soal['opsi_e'] ?? '';
      _nilaiA.text = (soal['nilai_a'] ?? '').toString();
      _nilaiB.text = (soal['nilai_b'] ?? '').toString();
      _nilaiC.text = (soal['nilai_c'] ?? '').toString();
      _nilaiD.text = (soal['nilai_d'] ?? '').toString();
      _nilaiE.text = (soal['nilai_e'] ?? '').toString();
      _uploadedImageUrl = soal['gambar_url'];
      jawabanBenar = {
        'A': soal['benar_a'] ?? false,
        'B': soal['benar_b'] ?? false,
        'C': soal['benar_c'] ?? false,
        'D': soal['benar_d'] ?? false,
        'E': soal['benar_e'] ?? false,
      };
    });
  }

  Future<void> _simpanSoal() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'kode_kuis': widget.kodeKuis,
      'pertanyaan': _pertanyaan.text.trim(),
      'gambar_url': _uploadedImageUrl,
      'opsi_a': _a.text.trim(),
      'opsi_b': _b.text.trim(),
      'opsi_c': _c.text.trim(),
      'opsi_d': _d.text.trim(),
      'opsi_e': _e.text.trim(),
      'nilai_a': int.tryParse(_nilaiA.text) ?? 0,
      'nilai_b': int.tryParse(_nilaiB.text) ?? 0,
      'nilai_c': int.tryParse(_nilaiC.text) ?? 0,
      'nilai_d': int.tryParse(_nilaiD.text) ?? 0,
      'nilai_e': int.tryParse(_nilaiE.text) ?? 0,
      'benar_a': jawabanBenar['A'],
      'benar_b': jawabanBenar['B'],
      'benar_c': jawabanBenar['C'],
      'benar_d': jawabanBenar['D'],
      'benar_e': jawabanBenar['E'],
    };

    if (isEditing && editingId != null) {
      await supabase.from('soal').update(data).eq('id', editingId!);
    } else {
      await supabase.from('soal').insert(data);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Soal diperbarui' : 'Soal ditambahkan'),
      ),
    );

    _formKey.currentState!.reset();
    setState(() {
      isEditing = false;
      editingId = null;
      _pickedImage = null;
      _uploadedImageUrl = null;

      _pertanyaan.clear();
      _a.clear();
      _b.clear();
      _c.clear();
      _d.clear();
      _e.clear();
      _nilaiA.clear();
      _nilaiB.clear();
      _nilaiC.clear();
      _nilaiD.clear();
      _nilaiE.clear();

      jawabanBenar = {
        'A': false,
        'B': false,
        'C': false,
        'D': false,
        'E': false,
      };
    });
    _loadSoal();
  }

  Future<void> _hapusSoal(int id) async {
    await supabase.from('soal').delete().eq('id', id);
    _loadSoal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kelola Soal - ${widget.kodeKuis}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _pertanyaan,
                    decoration: const InputDecoration(labelText: 'Pertanyaan'),
                    validator:
                        (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Upload Gambar (opsional)'),
                  ),
                  if (_uploadedImageUrl != null)
                    Image.network(_uploadedImageUrl!, height: 150),
                  const SizedBox(height: 12),
                  ...['A', 'B', 'C', 'D', 'E'].map((opsi) {
                    final ctrl =
                        {'A': _a, 'B': _b, 'C': _c, 'D': _d, 'E': _e}[opsi]!;
                    final nilaiCtrl =
                        {
                          'A': _nilaiA,
                          'B': _nilaiB,
                          'C': _nilaiC,
                          'D': _nilaiD,
                          'E': _nilaiE,
                        }[opsi]!;

                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: ctrl,
                            decoration: InputDecoration(
                              labelText: 'Opsi $opsi',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 60,
                          child: TextFormField(
                            controller: nilaiCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Nilai',
                            ),
                          ),
                        ),
                        Checkbox(
                          value: jawabanBenar[opsi],
                          onChanged:
                              (val) =>
                                  setState(() => jawabanBenar[opsi] = val!),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _simpanSoal,
                    child: Text(isEditing ? 'Update Soal' : 'Simpan Soal'),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            const Text(
              'Daftar Soal:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...daftarSoal.map(
              (s) => Card(
                child: ListTile(
                  title: Text(s['pertanyaan'] ?? '-'),
                  subtitle: Text('Opsi A: ${s['opsi_a'] ?? '-'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _isiUlangForm(s),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _hapusSoal(s['id']),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
