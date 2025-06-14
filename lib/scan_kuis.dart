import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanKuisPage extends StatefulWidget {
  const ScanKuisPage({super.key});

  @override
  State<ScanKuisPage> createState() => _ScanKuisPageState();
}

class _ScanKuisPageState extends State<ScanKuisPage> {
  final kodeController = TextEditingController();
  bool loading = false;

  void _submitKode(String kode) async {
    if (kode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode kuis tidak boleh kosong')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final data = await Supabase.instance.client
          .from('kelas')
          .select('kode_kuis')
          .eq('kode_kuis', kode)
          .limit(1);

      if (data.isNotEmpty) {
        context.push('/kerjakan-kuis', extra: {'kode_kuis': kode});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kode kuis tidak ditemukan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  void _scanQRCode() async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Scan QR Code'),
            content: SizedBox(
              width: 300,
              height: 300,
              child: MobileScanner(
                onDetect: (capture) {
                  final code = capture.barcodes.first.rawValue;
                  if (code != null) {
                    Navigator.pop(context);
                    _submitKode(code);
                  }
                },
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: 340,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_2, size: 60, color: Colors.teal),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: kodeController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan kode kuis',
                      prefixIcon: const Icon(Icons.code),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed:
                        loading ? null : () => _submitKode(kodeController.text),
                    icon: const Icon(Icons.send),
                    label: const Text('Submit Kode'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: loading ? null : _scanQRCode,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan QR Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
