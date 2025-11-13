// lib/models/routine.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RoutineStatus { todo, inProgress, done }

extension RoutineStatusLabel on RoutineStatus {
  String get label {
    switch (this) {
      case RoutineStatus.todo:
        return '대기';
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
  final int? actualSeconds; // seconds
  final int accumulatedSeconds; // seconds
  final RoutineStatus status;
  final DateTime createdAt;
  final DateTime? startTime;
  final DateTime? runningSince;
  final DateTime? endTime;
  final DateTime? completedAt;

  const Routine({
    required this.id,
    required this.title,
    this.description,
    required this.focusLevel,
    required this.estimatedTime,
    this.actualSeconds,
    this.accumulatedSeconds = 0,
    required this.status,
    required this.createdAt,
    this.startTime,
    this.runningSince,
    this.endTime,
    this.completedAt,
  });

  Routine copyWith({
    String? id,
    String? title,
    String? description,
    int? focusLevel,
    int? estimatedTime,
    int? actualSeconds,
    int? accumulatedSeconds,
    RoutineStatus? status,
    DateTime? createdAt,
    DateTime? startTime,
    DateTime? runningSince,
    DateTime? endTime,
    DateTime? completedAt,
  }) {
    return Routine(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      focusLevel: focusLevel ?? this.focusLevel,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      actualSeconds: actualSeconds ?? this.actualSeconds,
      accumulatedSeconds: accumulatedSeconds ?? this.accumulatedSeconds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startTime: startTime ?? this.startTime,
      runningSince: runningSince ?? this.runningSince,
      endTime: endTime ?? this.endTime,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory Routine.fromJson(Map<String, dynamic> json) {
    final legacyActualMinutes = json['actualTime'] as int?;
    return Routine(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      focusLevel: json['focusLevel'] as int,
      estimatedTime: json['estimatedTime'] as int,
      actualSeconds: (json['actualSeconds'] as int?) ??
          (legacyActualMinutes != null
              ? legacyActualMinutes * 60
              : null),
      accumulatedSeconds: json['accumulatedSeconds'] as int? ?? 0,
      status: RoutineStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => RoutineStatus.todo,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      startTime: (json['startTime'] as String?) != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      runningSince: (json['runningSince'] as String?) != null
          ? DateTime.parse(json['runningSince'] as String)
          : null,
      endTime: (json['endTime'] as String?) != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      completedAt: (json['completedAt'] as String?) != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'focusLevel': focusLevel,
      'estimatedTime': estimatedTime,
      'actualSeconds': actualSeconds,
      'accumulatedSeconds': accumulatedSeconds,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'runningSince': runningSince?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

abstract class RoutinePersistence {
  Future<List<Routine>> load();
  Future<void> save(List<Routine> routines);
}

class RoutineListNotifier extends StateNotifier<List<Routine>> {
  RoutineListNotifier(this._persistence) : super(const <Routine>[]) {
    _loadInitial();
  }

  final RoutinePersistence _persistence;

  Future<void> _loadInitial() async {
    final stored = await _persistence.load();
    state = stored;
  }

  void addRoutine(Routine routine) {
    state = [...state, routine];
    _persist();
  }

  void updateRoutine(Routine routine) {
    state = [
      for (final r in state)
        if (r.id == routine.id) routine else r,
    ];
    _persist();
  }

  void deleteRoutine(String id) {
    state = state.where((r) => r.id != id).toList();
    _persist();
  }

  bool startRoutine(Routine routine) {
    final hasAnotherRunning = state.any(
      (r) => r.id != routine.id && r.status == RoutineStatus.inProgress,
    );
    if (hasAnotherRunning) {
      return false;
    }

    final now = DateTime.now();
    final updated = routine.copyWith(
      status: RoutineStatus.inProgress,
      startTime: routine.startTime ?? now,
      runningSince: now,
      endTime: null,
      completedAt: null,
      actualSeconds: null,
      accumulatedSeconds: 0,
    );
    updateRoutine(updated);
    return true;
  }

  bool pauseRoutine(Routine routine) {
    if (routine.status != RoutineStatus.inProgress ||
        routine.runningSince == null) {
      return false;
    }

    final now = DateTime.now();
    final elapsed = now.difference(routine.runningSince!).inSeconds;
    updateRoutine(
      routine.copyWith(
        accumulatedSeconds: routine.accumulatedSeconds + elapsed,
        runningSince: null,
      ),
    );
    return true;
  }

  bool resumeRoutine(Routine routine) {
    if (routine.status != RoutineStatus.inProgress ||
        routine.runningSince != null) {
      return false;
    }

    final hasAnotherActive = state.any(
      (r) =>
          r.id != routine.id &&
          r.status == RoutineStatus.inProgress &&
          r.runningSince != null,
    );
    if (hasAnotherActive) {
      return false;
    }

    updateRoutine(
      routine.copyWith(runningSince: DateTime.now()),
    );
    return true;
  }

  void completeRoutine(Routine routine) {
    final now = DateTime.now();
    final runningSeconds = routine.runningSince != null
        ? now.difference(routine.runningSince!).inSeconds
        : 0;
    final totalSeconds =
        routine.accumulatedSeconds + runningSeconds;

    final updated = routine.copyWith(
      status: RoutineStatus.done,
      completedAt: now,
      endTime: now,
      actualSeconds: totalSeconds,
      runningSince: null,
      accumulatedSeconds: 0,
    );
    updateRoutine(updated);
  }

  void _persist() {
    _persistence.save(state);
  }
}

final routinePersistenceProvider = Provider<RoutinePersistence>((ref) {
  throw UnimplementedError('routinePersistenceProvider must be overridden');
});

final routinesProvider =
    StateNotifierProvider<RoutineListNotifier, List<Routine>>((ref) {
  final persistence = ref.watch(routinePersistenceProvider);
  return RoutineListNotifier(persistence);
});


