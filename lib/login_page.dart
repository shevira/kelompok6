import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw 'Email atau password salah.';

      // Ambil data user dari tabel 'users'
      final userData =
          await Supabase.instance.client
              .from('users')
              .select('status')
              .eq('id', user.id)
              .single();

      final role = userData['status'];

      // Arahkan berdasarkan status
      if (role == 'student') {
        Navigator.pushReplacementNamed(context, '/dashboard-student');
      } else if (role == 'teacher') {
        Navigator.pushReplacementNamed(context, '/dashboard-teacher');
      } else {
        throw 'Status pengguna tidak valid.';
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login gagal: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInput(
                _emailController,
                'Email',
                TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _buildInput(
                _passwordController,
                'Password',
                TextInputType.visiblePassword,
                isPassword: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child:
                    _loading
                        ? const CircularProgressIndicator()
                        : const Text('Masuk'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label,
    TextInputType inputType, {
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator:
          (value) =>
              value == null || value.isEmpty ? '$label wajib diisi' : null,
    );
  }
}
