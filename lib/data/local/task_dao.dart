import 'package:sqflite/sqflite.dart';

import '../../domain/entities/task.dart';
import 'app_database.dart';

class TaskDao {
  Future<Database> get _db async => AppDatabase.instance();

  Future<List<Task>> getAll() async {
    final db = await _db;
    final rows = await db.query('tasks', orderBy: 'updated_at DESC');
    return rows.map(Task.fromDb).toList();
  }

  Future<void> upsert(Task task) async {
    final db = await _db;
    await db.insert('tasks', task.toDb(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Task?> getById(String id) async {
    final db = await _db;
    final rows = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Task.fromDb(rows.first);
  }

  Future<void> deleteHard(String id) async {
    final db = await _db;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markDeleted(String id, DateTime updatedAt) async {
    final db = await _db;
    await db.update('tasks', {'deleted': 1, 'updated_at': updatedAt.toIso8601String()}, where: 'id = ?', whereArgs: [id]);
  }
}
