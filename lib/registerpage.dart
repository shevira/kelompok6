import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final nimController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String selectedStatus = 'student';

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (authResponse.user == null) throw 'Register gagal. Coba lagi.';
      final uid = authResponse.user!.id;

      await Supabase.instance.client.from('users').insert({
        'id': uid,
        'full_name': nameController.text.trim(),
        'nim_nip': nimController.text.trim(),
        'email': emailController.text.trim(),
        'status': selectedStatus,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil! Silakan login.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal daftar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF2C2C2C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  width: 380,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Image.asset('assets/logoElkom2.png', height: 120),
                        const SizedBox(height: 12),
                        Text(
                          'Daftar Akun',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildInput(
                          nameController,
                          'Nama Lengkap',
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 12),
                        _buildInput(
                          nimController,
                          'NIM / NIP',
                          inputType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: _dropdownDecoration(),
                          style: const TextStyle(color: Colors.white),
                          dropdownColor: Colors.black,
                          iconEnabledColor: Colors.white,
                          items: const [
                            DropdownMenuItem(
                              value: 'student',
                              child: Text('Student'),
                            ),
                            DropdownMenuItem(
                              value: 'teacher',
                              child: Text('Teacher'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedStatus = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildInput(
                          emailController,
                          'Email',
                          inputType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        _buildInput(
                          passwordController,
                          'Password',
                          isPassword: true,
                          show: _showPassword,
                          onToggle: () {
                            setState(() => _showPassword = !_showPassword);
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildInput(
                          confirmPasswordController,
                          'Konfirmasi Password',
                          isPassword: true,
                          show: _showConfirmPassword,
                          onToggle: () {
                            setState(
                              () =>
                                  _showConfirmPassword = !_showConfirmPassword,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Daftar Sekarang'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text(
                            'Sudah punya akun? Masuk',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration() => InputDecoration(
    filled: true,
    fillColor: Colors.white.withOpacity(0.05),
    hintStyle: const TextStyle(color: Colors.white70),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white30),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(10),
    ),
  );

  Widget _buildInput(
    TextEditingController controller,
    String hint, {
    TextInputType inputType = TextInputType.text,
    bool isPassword = false,
    bool show = false,
    VoidCallback? onToggle,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !show,
      keyboardType: inputType,
      textCapitalization: textCapitalization,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    show ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white70,
                  ),
                  onPressed: onToggle,
                )
                : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return '$hint wajib diisi';
        if (hint == 'Email' && !value.contains('@')) return 'Email tidak valid';
        if (hint == 'Password') {
          if (value.length < 6) return 'Minimal 6 karakter';
        }
        if (hint == 'Konfirmasi Password' && value != passwordController.text) {
          return 'Password tidak cocok';
        }
        return null;
      },
    );
  }
}
