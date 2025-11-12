import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/routine_provider.dart';
import '../widgets/routine_card.dart';
import '../widgets/routine_timer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routineListProvider);
    final doing = routines.where((r) => r.status.name == 'doing').toList();
    final todo = routines.where((r) => r.status.name == 'todo').toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: [
          if (doing.isNotEmpty) ...[
            const Text('진행 중', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...doing.map((r) => RoutineTimer(routine: r)),
            const Divider(),
          ],
          const Text('오늘의 루틴', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...todo.map((r) => RoutineCard(routine: r)),
        ],
      ),
    );
  }
}
