// lib/models/routine.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RoutineStatus { todo, inProgress, done }

extension RoutineStatusLabel on RoutineStatus {
  String get label {
    switch (this) {
      case RoutineStatus.todo:
        return '할 일';
      case RoutineStatus.inProgress:
        return '진행 중';
      case RoutineStatus.done:
        return '완료';
    }
  }

  String get apiValue {
    switch (this) {
      case RoutineStatus.todo:
        return 'todo';
      case RoutineStatus.inProgress:
        return 'in-progress';
      case RoutineStatus.done:
        return 'done';
    }
  }
}

class Routine {
  final String id;
  final String title;
  final String? description;
  final int focusLevel; // 1-5
  final int estimatedTime; // minutes
  final int? actualTime; // minutes
  final RoutineStatus status;
  final DateTime createdAt;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? completedAt;

  const Routine({
    required this.id,
    required this.title,
    this.description,
    required this.focusLevel,
    required this.estimatedTime,
    this.actualTime,
    required this.status,
    required this.createdAt,
    this.startTime,
    this.endTime,
    this.completedAt,
  });

  Routine copyWith({
    String? id,
    String? title,
    String? description,
    int? focusLevel,
    int? estimatedTime,
    int? actualTime,
    RoutineStatus? status,
    DateTime? createdAt,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? completedAt,
  }) {
    return Routine(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      focusLevel: focusLevel ?? this.focusLevel,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      actualTime: actualTime ?? this.actualTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class RoutineListNotifier extends StateNotifier<List<Routine>> {
  RoutineListNotifier() : super([]);

  void addRoutine(Routine routine) {
    state = [...state, routine];
  }

  void updateRoutine(Routine routine) {
    state = [
      for (final r in state)
        if (r.id == routine.id) routine else r,
    ];
  }

  void deleteRoutine(String id) {
    state = state.where((r) => r.id != id).toList();
  }

  void startRoutine(Routine routine) {
    updateRoutine(
      routine.copyWith(
        status: RoutineStatus.inProgress,
        startTime: DateTime.now(),
      ),
    );
  }

  void completeRoutine(Routine routine, {int? actualMinutes}) {
    updateRoutine(
      routine.copyWith(
        status: RoutineStatus.done,
        completedAt: DateTime.now(),
        endTime: DateTime.now(),
        actualTime:
            actualMinutes ?? routine.actualTime ?? routine.estimatedTime,
      ),
    );
  }
}

final routinesProvider =
    StateNotifierProvider<RoutineListNotifier, List<Routine>>((ref) {
  return RoutineListNotifier();
});
