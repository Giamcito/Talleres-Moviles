import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/joke.dart';
import '../services/chuck_service.dart';

enum LoadState { idle, loading, success, error }

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final ChuckService _service = ChuckService();
  List<Joke> _items = [];
  LoadState _state = LoadState.idle;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _fetchJokes();
  }

  Future<void> _fetchJokes() async {
    if (!mounted) return;
    print('ListScreen: _fetchJokes - iniciando');
    setState(() {
      _state = LoadState.loading;
      _errorMsg = '';
    });
    try {
      // Query ajustable; aquí usamos "dev" para ejemplos
      final results = await _service.searchJokes('dev');
      if (!mounted) return;
      print('ListScreen: _fetchJokes - resultados recibidos: ${results.length}');
      setState(() {
        _items = results;
        _state = LoadState.success;
      });
    } catch (e, st) {
      final msg = 'No se pudieron cargar los chistes. Revise su conexión.';
      print('ListScreen: _fetchJokes error - $e\n$st');
      if (!mounted) return;
      setState(() {
        _state = LoadState.error;
        _errorMsg = msg;
      });
      // Mostrar snackbar sólo si el widget sigue montado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado - Chuck Norris Jokes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchJokes,
          )
        ],
      ),
      body: Builder(builder: (context) {
        if (_state == LoadState.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (_state == LoadState.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_errorMsg),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _fetchJokes, child: const Text('Reintentar')),
              ],
            ),
          );
        } else if (_items.isEmpty) {
          return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('No se encontraron chistes para la búsqueda.'),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _fetchJokes, child: const Text('Buscar de nuevo')),
            ]),
          );
        } else {
          return ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final joke = _items[index];
              return ListTile(
                leading: joke.iconUrl.isNotEmpty
                    ? Image.network(
                        joke.iconUrl,
                        width: 48,
                        height: 48,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                      )
                    : const Icon(Icons.sentiment_very_satisfied),
                title: Text(
                  joke.value.length > 80 ? '${joke.value.substring(0, 80)}...' : joke.value,
                ),
                subtitle: joke.categories.isNotEmpty ? Text(joke.categories.join(', ')) : null,
                onTap: () {
                  print('ListScreen: navegación a detalle id=${joke.id} (push)');
                  // Navega a detalle empujando la ruta (preserva historial para poder volver)
                  context.push('/detail/${joke.id}', extra: joke);
                },
              );
            },
          );
        }
      }),
    );
  }
}
