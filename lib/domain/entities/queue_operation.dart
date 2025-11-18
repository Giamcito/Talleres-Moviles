import 'dart:convert';

class QueueOperation {
  final String id; // uuid
  final String entity; // 'task'
  final String entityId; // task id
  final String op; // CREATE | UPDATE | DELETE
  final String payload; // json string with fields
  final DateTime createdAt;
  final int attemptCount;
  final String? lastError;

  QueueOperation({
    required this.id,
    required this.entity,
    required this.entityId,
    required this.op,
    required this.payload,
    required this.createdAt,
    this.attemptCount = 0,
    this.lastError,
  });

  QueueOperation copyWith({int? attemptCount, String? lastError}) => QueueOperation(
        id: id,
        entity: entity,
        entityId: entityId,
        op: op,
        payload: payload,
        createdAt: createdAt,
        attemptCount: attemptCount ?? this.attemptCount,
        lastError: lastError ?? this.lastError,
      );

  Map<String, dynamic> toDb() => {
        'id': id,
        'entity': entity,
        'entity_id': entityId,
        'op': op,
        'payload': payload,
        'created_at': createdAt.millisecondsSinceEpoch,
        'attempt_count': attemptCount,
        'last_error': lastError,
      };

  factory QueueOperation.fromDb(Map<String, dynamic> row) => QueueOperation(
        id: row['id'] as String,
        entity: row['entity'] as String,
        entityId: row['entity_id'] as String,
        op: row['op'] as String,
        payload: row['payload'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
        attemptCount: row['attempt_count'] as int,
        lastError: row['last_error'] as String?,
      );

  @override
  String toString() => jsonEncode(toDb());
}
