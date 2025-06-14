// manual_token_reset.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManualTokenResetPage extends StatefulWidget {
  final String email;
  const ManualTokenResetPage({Key? key, required this.email}) : super(key: key);

  @override
  State<ManualTokenResetPage> createState() => _ManualTokenResetPageState();
}

class _ManualTokenResetPageState extends State<ManualTokenResetPage> {
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final supabase = Supabase.instance.client;

  Future<void> resetPassword() async {
    final token = tokenController.text.trim();
    final newPassword = passwordController.text;
    final confirmPassword = confirmController.text;

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password dan konfirmasi tidak sama")),
      );
      return;
    }

    try {
      await supabase.auth.verifyOTP(
        type: OtpType.recovery,
        email: widget.email,
        token: token,
      );

      await supabase.auth.updateUser(UserAttributes(password: newPassword));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password berhasil diubah, silakan login"),
        ),
      );

      context.go('/'); // kembali ke login
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal reset password: \$e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password Manual")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: tokenController,
              decoration: const InputDecoration(
                labelText: "Kode Token dari Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password Baru",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Konfirmasi Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetPassword,
              child: const Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }
}
