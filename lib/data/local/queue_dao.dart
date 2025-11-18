import 'package:sqflite/sqflite.dart';

import '../../domain/entities/queue_operation.dart';
import 'app_database.dart';

class QueueDao {
  Future<Database> get _db async => AppDatabase.instance();

  Future<void> add(QueueOperation op) async {
    final db = await _db;
    await db.insert('queue_operations', op.toDb(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<QueueOperation>> pending({int limit = 50}) async {
    final db = await _db;
    final rows = await db.query('queue_operations', orderBy: 'created_at ASC', limit: limit);
    return rows.map(QueueOperation.fromDb).toList();
  }

  Future<void> update(QueueOperation op) async {
    final db = await _db;
    await db.update('queue_operations', op.toDb(), where: 'id = ?', whereArgs: [op.id]);
  }

  Future<void> remove(String id) async {
    final db = await _db;
    await db.delete('queue_operations', where: 'id = ?', whereArgs: [id]);
  }
}
