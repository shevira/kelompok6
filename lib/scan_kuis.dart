import 'dart:ui';
import 'package:flutter/material.dart';

class ScanKuisPage extends StatefulWidget {
  const ScanKuisPage({super.key});

  @override
  State<ScanKuisPage> createState() => _ScanKuisPageState();
}

class _ScanKuisPageState extends State<ScanKuisPage> {
  final kodeController = TextEditingController();

  void _submitKode() {
    final kode = kodeController.text.trim();
    if (kode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode kuis tidak boleh kosong')),
      );
      return;
    }

    // TODO: Lakukan pengecekan kuis di Supabase berdasarkan kode
    // Navigasi ke halaman pengerjaan kuis
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kuis dengan kode "$kode" ditemukan!')),
    );
  }

  void _scanQRCode() {
    // TODO: Integrasi dengan plugin scan QR (seperti `qr_code_scanner`)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur scan QR belum diimplementasikan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Masukkan Kode Kuis'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 340,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_2, size: 60, color: Colors.white),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: kodeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Masukkan kode kuis',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _submitKode,
                    icon: const Icon(Icons.send),
                    label: const Text('Submit Kode'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _scanQRCode,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan QR Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
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
