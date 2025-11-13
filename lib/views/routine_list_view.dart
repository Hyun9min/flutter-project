import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/routine.dart';
import '../widgets/routine_card.dart';

class RoutineListView extends ConsumerWidget {
  const RoutineListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider);

    final todo = routines.where((r) => r.status == RoutineStatus.todo).toList();
    final inProgress =
        routines.where((r) => r.status == RoutineStatus.inProgress).toList();
    final done =
        routines.where((r) => r.status == RoutineStatus.done).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _Section(
          title: '\uB300\uAE30',
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
          title: '\uC9C4\uD589 \uC911',
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
          title: '\uC644\uB8CC',
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

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.count,
    required this.children,
  });

  final String title;
  final int count;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              '$count\uAC1C',
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
