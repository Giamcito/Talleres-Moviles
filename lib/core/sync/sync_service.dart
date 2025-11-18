import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_offline_app/core/di/repository_providers.dart';

import '../connectivity/connectivity_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(ref);
  service.init();
  return service;
});

class SyncService {
  final Ref ref;
  Timer? _timer;
  SyncService(this.ref);

  void init() {
    // Intento periódico simple.
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => trySync());
    // También intentar cuando vuelve conexión.
    ref.listen<bool>(connectivityOnlineProvider, (prev, next) {
      if (next) {
        trySync();
      }
    });
  }

  Future<void> trySync() async {
    final online = ref.read(connectivityOnlineProvider);
    if (!online) return;
    final repo = ref.read(taskRepositoryProvider);
    await repo.processQueue();
    // Después de procesar cola refrescar tareas remotas (LWW). La actualización
    // de UI dependerá de futuros triggers manuales o de un listener separado.
    try {
      await repo.refreshFromRemote();
    } catch (_) {
      // Ignorar fallos de actualización silenciosamente.
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}