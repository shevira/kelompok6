import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String _status = 'student';

  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final nama = _namaController.text.trim().toUpperCase();
      final nim = _nimController.text.trim();

      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw 'Gagal mendaftarkan akun';

      await Supabase.instance.client.from('users').insert({
        'id': user.id,
        'email': email,
        'nama_lengkap': nama,
        'nim_nip': nim,
        'status': _status,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil!')),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal registrasi: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildInput(_namaController, 'Nama Lengkap'),
              _buildInput(_nimController, 'NIM/NIP', inputType: TextInputType.number),
              _buildDropdownStatus(),
              _buildInput(_emailController, 'Email', inputType: TextInputType.emailAddress),
              _buildInput(_passwordController, 'Password', isPassword: true),
              _buildInput(_confirmController, 'Konfirmasi Password', isPassword: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label, {
    TextInputType inputType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return '$label wajib diisi';
          if (label == 'NIM/NIP' && value.length < 5) {
            return 'NIM/NIP minimal 5 digit';
          }
          if (label == 'Konfirmasi Password' &&
              value != _passwordController.text) {
            return 'Password tidak cocok';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownStatus() {
    return DropdownButtonFormField<String>(
      value: _status,
      items: const [
        DropdownMenuItem(value: 'student', child: Text('Student')),
        DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
      ],
      onChanged: (val) => setState(() => _status = val!),
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
      ),
    );
  }
}
