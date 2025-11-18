import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_offline_app/core/di/repository_providers.dart';

import '../../data/repositories/task_repository.dart';
import '../../domain/entities/task.dart';
import 'task_filters_provider.dart';

final taskListProvider = StateNotifierProvider<TaskListNotifier, AsyncValue<List<Task>>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return TaskListNotifier(ref: ref, repository: repo);
});

class TaskListNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final Ref ref;
  final TaskRepository repository;
  bool _loading = false;
  TaskListNotifier({required this.ref, required this.repository}) : super(const AsyncValue.data([]));

  Future<void> loadInitial() async {
    if (_loading) return; // evitar doble llamada
    _loading = true;
    try {
      final local = await repository.getAllLocal();
      state = AsyncValue.data(local);
      _backgroundRemoteRefresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _loading = false;
    }
  }

  Future<void> _backgroundRemoteRefresh() async {
    try {
      await repository.refreshFromRemote();
      final local2 = await repository.getAllLocal();
      state = AsyncValue.data(local2);
    } catch (e) {
      // Log sencillo para diagnosticar fallos de red (puede conectarse a logger en futuro)
      // debugPrint('Background refresh failed: $e');
    }
  }

  Future<void> reloadFromLocal() async {
    final local = await repository.getAllLocal();
    state = AsyncValue.data(local);
  }

  Future<void> addTask(String title) async {
    final current = (state.value ?? []);
    final task = await repository.create(title);
    state = AsyncValue.data([task, ...current]);
  }

  Future<void> toggleComplete(Task task) async {
    await repository.update(task, completed: !task.completed);
    await reloadFromLocal();
  }

  Future<void> editTitle(Task task, String title) async {
    await repository.update(task, title: title);
    await reloadFromLocal();
  }

  Future<void> deleteTask(Task task) async {
    await repository.delete(task);
    await reloadFromLocal();
  }

  // La lógica de filtrado se mueve a un provider derivado para evitar
  // inconsistencias y uso de ref.watch dentro del notifier.
}

final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(taskListProvider);
  final filter = ref.watch(taskFilterProvider);
  return tasksAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (tasks) {
      List<Task> list;
      switch (filter) {
        case TaskFilter.all:
          list = tasks.where((t) => !t.deleted).toList();
          break;
        case TaskFilter.pending:
          list = tasks.where((t) => !t.deleted && !t.completed).toList();
          break;
        case TaskFilter.completed:
          list = tasks.where((t) => !t.deleted && t.completed).toList();
          break;
      }
      return AsyncValue.data(list);
    },
  );
});
