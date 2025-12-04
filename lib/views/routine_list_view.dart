import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/routine.dart';
import '../widgets/routine_card.dart';

class RoutineListView extends ConsumerWidget {
  const RoutineListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 전체 루틴 상태 가져오기
    final routines = ref.watch(routinesProvider);
    // 상태별로 루틴 나누기
    final todo = routines.where((r) => r.status == RoutineStatus.todo).toList();
    final inProgress =
        routines.where((r) => r.status == RoutineStatus.inProgress).toList();
    final done = routines.where((r) => r.status == RoutineStatus.done).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _Section(
          // 대기 중인 루틴 섹션
          title: '대기',
          count: todo.length,
          children: todo
              .map(
                (routine) => RoutineCard(
                  routine: routine,
                  style: RoutineCardStyle.normal,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        _Section(
          // 진행 중인 루틴 섹션
          title: '진행 중',
          count: inProgress.length,
          children: inProgress
              .map(
                (routine) => RoutineCard(
                  routine: routine,
                  style: RoutineCardStyle.running,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        _Section(
          // 완료된 루틴 섹션
          title: '완료',
          count: done.length,
          children: done
              .map(
                (routine) => RoutineCard(
                  routine: routine,
                  style: RoutineCardStyle.completed,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// 각 상태별 섹션 공용 위젯
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.count,
    required this.children,
  });
  // 섹션 제목 (대기 / 진행 중 / 완료)
  final String title;
  // 해당 섹션에 포함된 루틴 개수
  final int count;
  // 실제로 보여줄 루틴 카드 위젯 리스트
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 상단 헤더 (제목 + 개수)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '$count개',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}
