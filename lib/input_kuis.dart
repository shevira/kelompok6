// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:uuid/uuid.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class InputKuisPage extends StatefulWidget {
//   const InputKuisPage({super.key});

//   @override
//   State<InputKuisPage> createState() => _InputKuisPageState();
// }

// class _InputKuisPageState extends State<InputKuisPage> {
//   final supabase = Supabase.instance.client;
//   bool loading = true;
//   List<dynamic> kelasList = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadKelas();
//   }

//   Future<void> _loadKelas() async {
//     final data = await supabase.from('kelas').select();
//     setState(() {
//       kelasList = data;
//       loading = false;
//     });
//   }

//   Future<void> _tambahKelas(String mataKuliah) async {
//     final idMk = const Uuid().v4().substring(0, 8);
//     final kodeKuis = const Uuid().v4().substring(0, 6).toUpperCase();

//     await supabase.from('kelas').insert({
//       'id_mk': idMk,
//       'mata_kuliah': mataKuliah,
//       'kode_kuis': kodeKuis,
//     });

//     _loadKelas();
//   }

//   void _showTambahDialog() {
//     final controller = TextEditingController();

//     showDialog(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             title: const Text('Tambah Kelas'),
//             content: TextField(
//               controller: controller,
//               decoration: const InputDecoration(labelText: 'Mata Kuliah'),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Batal'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   if (controller.text.trim().isNotEmpty) {
//                     Navigator.pop(context);
//                     _tambahKelas(controller.text.trim());
//                   }
//                 },
//                 child: const Text('Simpan'),
//               ),
//             ],
//           ),
//     );
//   }

//   void _showQRDialog(String kodeKuis) {
//     showDialog(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             title: const Text('QR Kode Kuis'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 QrImageView(data: kodeKuis, size: 200),
//                 const SizedBox(height: 10),
//                 Text('Kode: $kodeKuis'),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Tutup'),
//               ),
//             ],
//           ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Input Kuis'),
//         actions: [
//           IconButton(icon: const Icon(Icons.add), onPressed: _showTambahDialog),
//         ],
//       ),
//       body:
//           loading
//               ? const Center(child: CircularProgressIndicator())
//               : kelasList.isEmpty
//               ? const Center(child: Text('Belum ada kelas'))
//               : ListView.builder(
//                 itemCount: kelasList.length,
//                 itemBuilder: (context, index) {
//                   final kelas = kelasList[index];
//                   return ListTile(
//                     title: Text(kelas['mata_kuliah']),
//                     subtitle: Text('Kode: ${kelas['kode_kuis']}'),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.qr_code),
//                           onPressed: () => _showQRDialog(kelas['kode_kuis']),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.edit_note),
//                           onPressed: () {
//                             Navigator.pushNamed(
//                               context,
//                               '/buat-soal',
//                               arguments: kelas['kode_kuis'],
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//     );
//   }
// }
