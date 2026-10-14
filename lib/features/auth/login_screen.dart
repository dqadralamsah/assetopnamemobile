import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/providers.dart';

/// Login: email + password (dummy). SSO menyusul.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController(text: 'petugas@perusahaan.co.id');
  final _password = TextEditingController(text: 'password');
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    ref.read(authProvider.notifier).login(_email.text);
    context.go('/beranda');
  }

  void _sso() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login SSO menyusul (perlu info dari IT)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.forest,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Hero(),
                    const Spacer(),
                    _form(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _form() {
    const labelStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    );
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        24,
        20,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Masuk',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          const Text('Email', style: labelStyle),
          const SizedBox(height: 6),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'nama@perusahaan.co.id',
            ),
          ),
          const SizedBox(height: 12),
          const Text('Password', style: labelStyle),
          const SizedBox(height: 6),
          TextField(
            controller: _password,
            obscureText: _obscure,
            onSubmitted: (_) => _login(),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: _login,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Masuk'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'atau',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: _sso,
            child: const Text('Masuk dengan Akun Kantor (SSO)'),
          ),
          const SizedBox(height: 16),
          const Text(
            'v0.1.0 · dummy',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.muted,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.lime,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.verified_outlined, color: AppColors.forest),
          ),
          const SizedBox(height: 20),
          const Text(
            'Opname\nAset',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              height: 1.05,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Cek aset di lapangan — scan, catat, selesai.\n'
            'Tetap jalan tanpa sinyal.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
