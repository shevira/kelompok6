import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengerjaanKuisPage extends StatefulWidget {
  final String kode_kuis;
  const PengerjaanKuisPage({super.key, required this.kode_kuis});

  @override
  State<PengerjaanKuisPage> createState() => _PengerjaanKuisPageState();
}

class _PengerjaanKuisPageState extends State<PengerjaanKuisPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> soalList = [];
  Map<int, Set<String>> jawabanUser = {}; // id soal -> set opsi yg dipilih
  bool loading = true;
  int skorAkhir = 0;

  @override
  void initState() {
    super.initState();
    _loadSoal();
  }

  Future<void> _loadSoal() async {
    final data = await supabase
        .from('soal')
        .select()
        .eq('kode_kuis', widget.kode_kuis)
        .order('id');

    setState(() {
      soalList = List<Map<String, dynamic>>.from(data);
      loading = false;
    });
  }

  void _toggleJawaban(int soalId, String opsi) {
    setState(() {
      jawabanUser.putIfAbsent(soalId, () => <String>{});
      if (jawabanUser[soalId]!.contains(opsi)) {
        jawabanUser[soalId]!.remove(opsi);
      } else {
        jawabanUser[soalId]!.add(opsi);
      }
    });
  }

  Future<void> _submitJawaban() async {
    int totalSkor = 0;
    final user = supabase.auth.currentUser;
    final nim = user?.userMetadata?['nim_nip'] ?? 'unknown_nim';

    for (var soal in soalList) {
      final id = soal['id'] as int;
      final jawaban = jawabanUser[id] ?? {};

      int jumlahBenar = 0;
      Map<String, bool> kunci = {
        'A': soal['benar_a'] ?? false,
        'B': soal['benar_b'] ?? false,
        'C': soal['benar_c'] ?? false,
        'D': soal['benar_d'] ?? false,
        'E': soal['benar_e'] ?? false,
      };

      jumlahBenar = kunci.values.where((v) => v).length;

      double nilaiSoal = 0;
      if (jumlahBenar > 0) {
        for (var opsi in jawaban) {
          if (kunci[opsi] == true) {
            nilaiSoal += 10 / jumlahBenar;
          }
        }
      }

      await supabase.from('nilai').insert({
        'nim': nim,
        'kode_kuis': widget.kode_kuis,
        'id_pertanyaan': id,
        'nilai': double.parse(nilaiSoal.toStringAsFixed(2)),
      });

      totalSkor += nilaiSoal.toInt();
    }

    setState(() {
      skorAkhir = totalSkor;
    });

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Nilai Akhir'),
            content: Text('Skor kamu: $skorAkhir'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  Widget _buildOpsiCheckbox(int soalId, String label, String teks) {
    final isChecked = jawabanUser[soalId]?.contains(label) ?? false;
    return CheckboxListTile(
      value: isChecked,
      onChanged: (_) => _toggleJawaban(soalId, label),
      title: Text('$label. $teks'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kuis: ${widget.kode_kuis}')),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : soalList.isEmpty
              ? const Center(child: Text('Tidak ada soal'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: soalList.length + 1,
                itemBuilder: (context, index) {
                  if (index == soalList.length) {
                    return ElevatedButton(
                      onPressed: _submitJawaban,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Submit Jawaban'),
                    );
                  }

                  final soal = soalList[index];
                  final id = soal['id'] as int;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No. ${index + 1}: ${soal['pertanyaan'] ?? ''}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (soal['gambar_url'] != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Image.network(
                                soal['gambar_url'],
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          _buildOpsiCheckbox(id, 'A', soal['opsi_a'] ?? ''),
                          _buildOpsiCheckbox(id, 'B', soal['opsi_b'] ?? ''),
                          _buildOpsiCheckbox(id, 'C', soal['opsi_c'] ?? ''),
                          _buildOpsiCheckbox(id, 'D', soal['opsi_d'] ?? ''),
                          _buildOpsiCheckbox(id, 'E', soal['opsi_e'] ?? ''),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
