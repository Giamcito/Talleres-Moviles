import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  // For registration
  final _nameCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  bool _isRegister = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Autenticación JWT')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isRegister)
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu nombre' : null,
                    ),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@')) ? 'Email inválido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passCtrl,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                  ),
                  if (_isRegister) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pass2Ctrl,
                      decoration: const InputDecoration(labelText: 'Confirmar contraseña'),
                      obscureText: true,
                      validator: (v) => (v != _passCtrl.text) ? 'Las contraseñas no coinciden' : null,
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (auth.status == AuthStatus.loading)
                    const Center(child: CircularProgressIndicator()),
                  if (auth.status != AuthStatus.loading) ...[
                    ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        FocusScope.of(context).unfocus();
                        if (_isRegister) {
                          final ok = await context.read<AuthProvider>().register(
                                _nameCtrl.text.trim(),
                                _emailCtrl.text.trim(),
                                _passCtrl.text,
                                _pass2Ctrl.text,
                              );
                          if (ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Usuario creado. Ahora inicia sesión.')),
                            );
                            setState(() => _isRegister = false);
                          }
                        } else {
                          final ok = await context.read<AuthProvider>().login(
                                _emailCtrl.text.trim(),
                                _passCtrl.text,
                              );
                          if (ok && mounted) {
                            if (!mounted) return;
                            Navigator.of(context).pushReplacementNamed('/evidence');
                          }
                        }
                      },
                      child: Text(_isRegister ? 'Crear usuario' : 'Iniciar sesión'),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _isRegister = !_isRegister),
                      child: Text(_isRegister ? '¿Ya tienes cuenta? Inicia sesión' : 'Crear usuario nuevo'),
                    ),
                  ],
                  if (auth.status == AuthStatus.error && auth.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      auth.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
