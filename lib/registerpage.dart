// register

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
      backgroundColor: const Color(0xFFF4F6F8),
      body: Center(
        child: SingleChildScrollView(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 380,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Daftar Akun',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),
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
                        style: const TextStyle(color: Colors.black87),
                        dropdownColor: Colors.white,
                        iconEnabledColor: Colors.black54,
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
                            () => _showConfirmPassword = !_showConfirmPassword,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00695C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Daftar Sekarang'),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sudah punya akun?',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Masuk',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
    fillColor: Colors.grey[100],
    hintStyle: const TextStyle(color: Colors.black54),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.teal),
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
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black54),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    show ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey[700],
                  ),
                  onPressed: onToggle,
                )
                : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return '$hint wajib diisi';
        if (hint == 'Email' && !value.contains('@')) return 'Email tidak valid';
        if (hint == 'Password' && value.length < 6) return 'Minimal 6 karakter';
        if (hint == 'Konfirmasi Password' && value != passwordController.text) {
          return 'Password tidak cocok';
        }
        return null;
      },
    );
  }
}
