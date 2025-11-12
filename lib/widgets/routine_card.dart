import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';
import '../providers/routine_provider.dart';

class RoutineCard extends ConsumerWidget {
  final Routine routine;
  const RoutineCard({super.key, required this.routine});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _focusColor(routine.focusLevel);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(child: Text(routine.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                if (routine.status == RoutineStatus.todo)
                  TextButton(onPressed: () => ref.read(routineListProvider.notifier).startRoutine(routine), child: const Text('시작'))
                else if (routine.status == RoutineStatus.doing)
                  FilledButton(onPressed: () => ref.read(routineListProvider.notifier).completeRoutine(routine), child: const Text('완료'))
                else
                  OutlinedButton(onPressed: () => ref.read(routineListProvider.notifier).restartRoutine(routine), child: const Text('다시'))
              ],
            ),
            if (routine.description != null) ...[
              const SizedBox(height: 6),
              Text(routine.description!),
            ],
            if (routine.expected != null) ...[
              const SizedBox(height: 6),
              Text('예상: ${routine.expected!.inMinutes}분'),
            ],
          ],
        ),
      ),
    );
  }

  Color _focusColor(int level) {
    switch (level) {
      case 1: return Colors.green;
      case 2: return Colors.lightGreen;
      case 3: return Colors.amber;
      case 4: return Colors.deepOrange;
      case 5: return Colors.red;
      default: return Colors.grey;
    }
  }
}
