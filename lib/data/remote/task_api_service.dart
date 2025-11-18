import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/task.dart';

class TaskApiService {
  final String baseUrl;
  TaskApiService({required this.baseUrl});

  Future<List<Task>> fetchAll() async {
    final resp = await http.get(Uri.parse('$baseUrl/tasks'));
    _ensureSuccess(resp);
    final list = jsonDecode(resp.body) as List;
    return list.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Task> fetchById(String id) async {
    final resp = await http.get(Uri.parse('$baseUrl/tasks/$id'));
    _ensureSuccess(resp);
    return Task.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  Future<void> create(Task task) async {
    final resp = await http.post(Uri.parse('$baseUrl/tasks'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(task.toJson()));
    _ensureSuccess(resp);
  }

  Future<void> update(Task task) async {
    final resp = await http.put(Uri.parse('$baseUrl/tasks/${task.id}'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(task.toJson()));
    _ensureSuccess(resp);
  }

  Future<void> delete(String id) async {
    final resp = await http.delete(Uri.parse('$baseUrl/tasks/$id'));
    _ensureSuccess(resp);
  }

  void _ensureSuccess(http.Response resp) {
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('API error ${resp.statusCode}: ${resp.body}');
    }
  }
}
