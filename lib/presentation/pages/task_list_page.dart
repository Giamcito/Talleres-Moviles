import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/connectivity/connectivity_service.dart';
import '../providers/task_filters_provider.dart';
import '../providers/task_list_provider.dart';
import 'edit_task_page.dart';

class TaskListPage extends ConsumerWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFiltered = ref.watch(filteredTasksProvider);
    final online = ref.watch(connectivityOnlineProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do Offline-First'),
        actions: [
          Icon(online ? Icons.cloud_done : Icons.cloud_off, color: online ? Colors.green : Colors.red),
          PopupMenuButton<TaskFilter>(
            onSelected: (f) => ref.read(taskFilterProvider.notifier).state = f,
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: TaskFilter.all, child: Text('Todas')),
              PopupMenuItem(value: TaskFilter.pending, child: Text('Pendientes')),
              PopupMenuItem(value: TaskFilter.completed, child: Text('Completadas')),
            ],
          )
        ],
      ),
      body: asyncFiltered.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (filtered) {
          if (filtered.isEmpty) {
            return const Center(child: Text('Sin tareas'));
          }
          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final t = filtered[i];
              return Dismissible(
                key: ValueKey(t.id),
                background: Container(color: Colors.red),
                onDismissed: (_) => ref.read(taskListProvider.notifier).deleteTask(t),
                child: ListTile(
                  title: Text(t.title, style: TextStyle(decoration: t.completed ? TextDecoration.lineThrough : null)),
                  subtitle: Text('Actualizada: ${t.updatedAt.toLocal()}'),
                  leading: IconButton(
                    icon: Icon(t.completed ? Icons.check_circle : Icons.circle_outlined, color: t.completed ? Colors.green : null),
                    onPressed: () => ref.read(taskListProvider.notifier).toggleComplete(t),
                  ),
                  onTap: () async {
                    final newTitle = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => EditTaskPage(task: t)));
                    if (newTitle != null && newTitle.isNotEmpty) {
                      await ref.read(taskListProvider.notifier).editTitle(t, newTitle);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final title = await _dialogNewTask(context);
          if (title != null && title.trim().isNotEmpty) {
            await ref.read(taskListProvider.notifier).addTask(title.trim());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<String?> _dialogNewTask(BuildContext context) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva tarea'),
        content: TextField(controller: ctrl, autofocus: true, decoration: const InputDecoration(hintText: 'Título')), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Crear')),
        ],
      ),
    );
  }
}
