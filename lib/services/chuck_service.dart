import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/joke.dart';

class ChuckService {
  static const String _host = 'api.chucknorris.io';

  // Busca chistes por query (usa /jokes/search?query=...)
  Future<List<Joke>> searchJokes(String query) async {
    final uri = Uri.https(_host, '/jokes/search', {'query': query});
    print('ChuckService: searchJokes start - query="$query" uri=$uri');
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      print('ChuckService: searchJokes http status=${res.statusCode}');
      if (res.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(res.body) as Map<String, dynamic>;
        final List<dynamic> results = body['result'] ?? [];
        print('ChuckService: searchJokes success - found ${results.length} items');
        return results.map((e) => Joke.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        print('ChuckService: searchJokes server error ${res.statusCode}');
        throw Exception('Error en servidor: ${res.statusCode}');
      }
    } on TimeoutException catch (te) {
      print('ChuckService: searchJokes timeout - $te');
      throw Exception('Tiempo de espera agotado al consultar la API.');
    } catch (e, st) {
      print('ChuckService: searchJokes error - $e\n$st');
      throw Exception('Error al obtener chistes: $e');
    }
  }

  // Obtiene chiste por id (/jokes/{id})
  Future<Joke> getJokeById(String id) async {
    if (id.isEmpty) {
      print('ChuckService: getJokeById called with empty id');
      throw Exception('ID inválido');
    }
    final uri = Uri.https(_host, '/jokes/$id');
    print('ChuckService: getJokeById start - id=$id uri=$uri');
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      print('ChuckService: getJokeById http status=${res.statusCode}');
      if (res.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(res.body) as Map<String, dynamic>;
        print('ChuckService: getJokeById success - id=$id');
        return Joke.fromJson(body);
      } else {
        print('ChuckService: getJokeById server error ${res.statusCode}');
        throw Exception('Error en servidor: ${res.statusCode}');
      }
    } on TimeoutException catch (te) {
      print('ChuckService: getJokeById timeout - $te');
      throw Exception('Tiempo de espera agotado al obtener detalle.');
    } catch (e, st) {
      print('ChuckService: getJokeById error - $e\n$st');
      throw Exception('Error al obtener detalle: $e');
    }
  }
}
