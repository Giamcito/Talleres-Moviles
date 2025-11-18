import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/connectivity/connectivity_service.dart';
import 'core/sync/sync_service.dart';
import 'presentation/pages/task_list_page.dart';
import 'presentation/providers/task_list_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Inicializar servicios una sola vez.
    Future.microtask(() {
      ref.read(connectivityServiceProvider); // inicia escucha
      ref.read(syncServiceProvider); // inicia sync periódico
      ref.read(taskListProvider.notifier).loadInitial();
      _initialized = true;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do Offline-First',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo), useMaterial3: true),
      home: _initialized ? const TaskListPage() : const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}