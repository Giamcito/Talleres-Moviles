import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/queue_dao.dart';
import '../../data/local/task_dao.dart';
import '../../data/remote/task_api_service.dart';
import '../../data/repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(
    taskDao: TaskDao(),
    queueDao: QueueDao(),
    api: TaskApiService(
      baseUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000'),
    ),
  );
});
