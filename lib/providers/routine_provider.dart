import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';

class RoutineList extends Notifier<List<Routine>> {
  final _rng = Random();

  @override
  List<Routine> build() {
    // sample data
    return [
      Routine(
        id: 'r1',
        title: '아침 루틴',
        description: '물 마시기, 스트레칭',
        focusLevel: 2,
        status: RoutineStatus.todo,
        expected: const Duration(minutes: 15),
        createdAt: DateTime.now(),
      ),
      Routine(
        id: 'r2',
        title: '깊은 집중 작업',
        description: '핵심 모듈 구현',
        focusLevel: 5,
        status: RoutineStatus.doing,
        expected: const Duration(minutes: 90),
        startedAt: DateTime.now().subtract(const Duration(minutes: 20)),
        createdAt: DateTime.now(),
      ),
      Routine(
        id: 'r3',
        title: '리뷰 & 회고',
        description: '오늘 작업 점검',
        focusLevel: 3,
        status: RoutineStatus.done,
        expected: const Duration(minutes: 30),
        completedAt: DateTime.now().subtract(const Duration(hours: 1)),
        createdAt: DateTime.now(),
      ),
    ];
  }

  void addRoutine({required String title, int focusLevel = 3, Duration? expected}) {
    state = [
      ...state,
      Routine(
        id: 'r${_rng.nextInt(1<<30)}',
        title: title,
        focusLevel: focusLevel,
        expected: expected,
        createdAt: DateTime.now(),
      )
    ];
  }

  void startRoutine(Routine r) {
    state = [
      for (final x in state)
        if (x.id == r.id)
          x.copyWith(status: RoutineStatus.doing, startedAt: DateTime.now())
        else
          x
    ];
  }

  void completeRoutine(Routine r) {
    state = [
      for (final x in state)
        if (x.id == r.id)
          x.copyWith(status: RoutineStatus.done, completedAt: DateTime.now())
        else
          x
    ];
  }

  void restartRoutine(Routine r) {
    state = [
      for (final x in state)
        if (x.id == r.id)
          x.copyWith(status: RoutineStatus.todo, startedAt: null, completedAt: null)
        else
          x
    ];
  }

  void removeRoutine(Routine r) {
    state = [for (final x in state) if (x.id != r.id) x];
  }
}

final routineListProvider = NotifierProvider<RoutineList, List<Routine>>(() => RoutineList());
