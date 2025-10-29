import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class EvidenceView extends StatefulWidget {
  const EvidenceView({super.key});

  @override
  State<EvidenceView> createState() => _EvidenceViewState();
}

class _EvidenceViewState extends State<EvidenceView> {
  Map<String, String?> _data = const {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final info = await context.read<AuthProvider>().evidence();
    setState(() {
      _data = info;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidencia de almacenamiento'),
        actions: [
          IconButton(onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _loading
                ? const CircularProgressIndicator()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Row(label: 'Nombre', value: _data['name'] ?? '—'),
                      const SizedBox(height: 8),
                      _Row(label: 'Email', value: _data['email'] ?? '—'),
                      const SizedBox(height: 8),
                      _Row(label: 'Sesión', value: _data['token'] == 'presente' ? 'token presente' : 'sin token'),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          await context.read<AuthProvider>().logout();
                          if (!mounted) return;
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        child: const Text('Cerrar sesión'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Flexible(child: Text(value, textAlign: TextAlign.right)),
      ],
    );
  }
}
