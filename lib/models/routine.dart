enum RoutineStatus { todo, doing, done }

class Routine {
  final String id;
  final String title;
  final String? description;
  final int focusLevel; // 1~5
  final Duration? expected; // 예정 시간
  final RoutineStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const Routine({
    required this.id,
    required this.title,
    this.description,
    this.focusLevel = 3,
    this.expected,
    this.status = RoutineStatus.todo,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  Routine copyWith({
    String? id,
    String? title,
    String? description,
    int? focusLevel,
    Duration? expected,
    RoutineStatus? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return Routine(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      focusLevel: focusLevel ?? this.focusLevel,
      expected: expected ?? this.expected,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
