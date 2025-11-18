import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TaskFilter { all, pending, completed }

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);
