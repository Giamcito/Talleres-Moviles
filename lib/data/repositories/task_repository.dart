import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../domain/entities/queue_operation.dart';
import '../../domain/entities/task.dart';
import '../local/queue_dao.dart';
import '../local/task_dao.dart';
import '../remote/task_api_service.dart';

class TaskRepository {
  final TaskDao taskDao;
  final QueueDao queueDao;
  final TaskApiService api;
  final Uuid _uuid = const Uuid();

  TaskRepository({required this.taskDao, required this.queueDao, required this.api});

  Future<List<Task>> getAllLocal() => taskDao.getAll();

  Future<void> refreshFromRemote() async {
    final remote = await api.fetchAll();
    for (final task in remote) {
      await taskDao.upsert(task);
    }
  }

  Future<Task> create(String title) async {
    final now = DateTime.now();
    final task = Task(id: _uuid.v4(), title: title, completed: false, updatedAt: now);
    await taskDao.upsert(task);
    await _enqueue('task', task.id, 'CREATE', task.toJson());
    return task;
  }

  Future<void> update(Task task, {String? title, bool? completed}) async {
    final updated = task.copyWith(
      title: title,
      completed: completed,
      updatedAt: DateTime.now(),
    );
    await taskDao.upsert(updated);
    await _enqueue('task', updated.id, 'UPDATE', updated.toJson());
  }

  Future<void> delete(Task task) async {
    final updated = task.copyWith(updatedAt: DateTime.now(), deleted: true);
    await taskDao.upsert(updated);
    await _enqueue('task', updated.id, 'DELETE', {'id': updated.id, 'updatedAt': updated.updatedAt.toIso8601String()});
  }

  Future<void> _enqueue(String entity, String eid, String op, Object payload) async {
    final q = QueueOperation(
      id: _uuid.v4(),
      entity: entity,
      entityId: eid,
      op: op,
      payload: jsonEncode(payload),
      createdAt: DateTime.now(),
    );
    await queueDao.add(q);
  }

  // Procesar cola con política LWW (last write wins por updatedAt).
  Future<void> processQueue() async {
    final pending = await queueDao.pending();
    for (final op in pending) {
      try {
        final data = jsonDecode(op.payload) as Map<String, dynamic>;
        if (op.op == 'CREATE') {
          final task = Task.fromJson(data);
          await api.create(task);
        } else if (op.op == 'UPDATE') {
          final task = Task.fromJson(data);
          await api.update(task);
        } else if (op.op == 'DELETE') {
          final id = data['id'] as String;
          await api.delete(id);
        }
        await queueDao.remove(op.id);
      } catch (e) {
        final updated = op.copyWith(attemptCount: op.attemptCount + 1, lastError: e.toString());
        await queueDao.update(updated);
      }
    }
  }
}
