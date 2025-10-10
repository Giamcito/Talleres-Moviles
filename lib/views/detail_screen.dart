import 'package:flutter/material.dart';

import '../models/joke.dart';
import '../services/chuck_service.dart';

class DetailScreen extends StatefulWidget {
  final String jokeId;
  final Joke? initialJoke;
  const DetailScreen({super.key, required this.jokeId, this.initialJoke});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ChuckService _service = ChuckService();
  Joke? _joke;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialJoke != null) {
      _joke = widget.initialJoke;
    } else {
      _loadById();
    }
  }

  Future<void> _loadById() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final j = await _service.getJokeById(widget.jokeId);
      setState(() => _joke = j);
    } catch (e) {
      setState(() => _error = 'No se pudo cargar el detalle.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_error!)));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        leading: BackButton(onPressed: () {
          // demuestra comportamiento del botón atrás
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).maybePop();
          }
        }),
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _error != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _loadById, child: const Text('Reintentar')),
                    ],
                  )
                : _joke == null
                    ? const Text('Sin datos')
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_joke!.iconUrl.isNotEmpty)
                              Center(
                                child: Image.network(
                                  _joke!.iconUrl,
                                  width: 96,
                                  height: 96,
                                  errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 96),
                                ),
                              ),
                            const SizedBox(height: 16),
                            Text(_joke!.value, style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 12),
                            Text('ID: ${_joke!.id}', style: const TextStyle(color: Colors.grey)),
                            if (_joke!.categories.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text('Categorías: ${_joke!.categories.join(', ')}'),
                            ],
                          ],
                        ),
                      ),
      ),
    );
  }
}
