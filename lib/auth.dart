import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tubesmob/manual_token_reset.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _secureStorage = FlutterSecureStorage();

  /// Login biasa pakai email & password
  Future<bool> loginWithEmail({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw 'Login gagal';

      // Ambil role dari tabel users
      final userData =
          await supabase
              .from('users')
              .select('status')
              .eq('id', user.id)
              .single();

      final status = userData['status'];

      // Simpan info ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('password', password);
      await prefs.setString('role', status);

      // Arahkan ke dashboard
      _goToDashboard(context, status);
      return true;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login gagal: ${e.toString()}")));
      return false;
    }
  }

  /// Autentikasi sidik jari
  Future<void> authenticateWithFingerprint(BuildContext context) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Verifikasi sidik jari untuk masuk',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!didAuthenticate) return;

      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('email');
      final savedPassword = prefs.getString('password');
      final savedRole = prefs.getString('role');

      if (savedEmail != null && savedPassword != null && savedRole != null) {
        final response = await supabase.auth.signInWithPassword(
          email: savedEmail,
          password: savedPassword,
        );

        if (response.user == null) {
          throw Exception("User tidak ditemukan");
        }

        _goToDashboard(context, savedRole);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data login belum tersimpan")),
        );
      }
    } catch (e) {
      print("Fingerprint auth error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Autentikasi gagal: ${e.toString()}")),
      );
    }
  }

  Future<void> sendResetToken(BuildContext context, String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token reset telah dikirim ke email")),
      );
      // Navigasi ke halaman input token
      context.go('/reset-token?email=$email');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengirim token: $e")));
    }
  }

  void _goToDashboard(BuildContext context, String role) {
    if (role == 'student') {
      context.go('/dashboard-student');
    } else {
      context.go('/dashboard-teacher');
    }
  }
}
