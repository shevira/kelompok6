import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LihatNilaiPage extends StatefulWidget {
  const LihatNilaiPage({super.key});

  @override
  State<LihatNilaiPage> createState() => _LihatNilaiPageState();
}

class _LihatNilaiPageState extends State<LihatNilaiPage> {
  final supabase = Supabase.instance.client;
  bool loading = true;
  Map<String, List<int>> nilaiPerKuis = {};

  @override
  void initState() {
    super.initState();
    _loadNilai();
  }

  Future<void> _loadNilai() async {
    final nim = await _getNim();
    if (nim == null) {
      setState(() {
        loading = false;
        nilaiPerKuis = {};
      });
      return;
    }

    try {
      final response = await supabase.from('nilai').select().eq('nim', nim);

      final Map<String, List<int>> grouped = {};
      for (var row in response) {
        final kode = row['kode_kuis'];
        final nilai = row['nilai'];
        if (kode != null && nilai is int) {
          grouped.putIfAbsent(kode, () => []);
          grouped[kode]!.add(nilai);
        }
      }

      setState(() {
        nilaiPerKuis = grouped;
        loading = false;
      });
    } catch (e) {
      debugPrint('Gagal mengambil nilai: $e');
      setState(() {
        loading = false;
        nilaiPerKuis = {};
      });
    }
  }

  Future<String?> _getNim() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return null;

    final data =
        await supabase.from('users').select('nim').eq('id', uid).maybeSingle();

    return data?['nim'];
  }

  int _hitungRata2(List<int> nilai) {
    if (nilai.isEmpty) return 0;
    final total = nilai.reduce((a, b) => a + b);
    return (total / nilai.length).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nilai Kuis'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF121212),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : nilaiPerKuis.isEmpty
              ? const Center(
                child: Text(
                  'Belum ada nilai yang tersedia',
                  style: TextStyle(color: Colors.white70),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: nilaiPerKuis.length,
                itemBuilder: (context, index) {
                  final kodeKuis = nilaiPerKuis.keys.elementAt(index);
                  final nilaiList = nilaiPerKuis[kodeKuis]!;
                  final rata2 = _hitungRata2(nilaiList);

                  return Card(
                    color: Colors.white.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        'Kode Kuis: $kodeKuis',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Rata-rata Nilai: $rata2',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
