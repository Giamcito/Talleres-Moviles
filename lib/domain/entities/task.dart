import 'dart:convert';

class Task {
  final String id;
  final String title;
  final bool completed;
  final DateTime updatedAt;
  final bool deleted;

  Task({
    required this.id,
    required this.title,
    required this.completed,
    required this.updatedAt,
    this.deleted = false,
  });

  Task copyWith({String? title, bool? completed, DateTime? updatedAt, bool? deleted}) => Task(
        id: id,
        title: title ?? this.title,
        completed: completed ?? this.completed,
        updatedAt: updatedAt ?? this.updatedAt,
        deleted: deleted ?? this.deleted,
      );

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        completed: (json['completed'] is bool)
            ? json['completed'] as bool
            : (json['completed'] == 1),
        updatedAt: DateTime.parse(json['updatedAt'] ?? json['updated_at'] as String),
        deleted: (json['deleted'] ?? 0) == 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'completed': completed,
        'updatedAt': updatedAt.toIso8601String(),
        'deleted': deleted ? 1 : 0,
      };

  static Task fromDb(Map<String, dynamic> row) => Task(
        id: row['id'] as String,
        title: row['title'] as String,
        completed: (row['completed'] as int) == 1,
        updatedAt: DateTime.parse(row['updated_at'] as String),
        deleted: (row['deleted'] as int) == 1,
      );

  Map<String, dynamic> toDb() => {
        'id': id,
        'title': title,
        'completed': completed ? 1 : 0,
        'updated_at': updatedAt.toIso8601String(),
        'deleted': deleted ? 1 : 0,
      };

  @override
  String toString() => jsonEncode(toJson());
}
