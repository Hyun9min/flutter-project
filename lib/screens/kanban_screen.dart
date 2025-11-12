import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/routine_provider.dart';
import '../models/routine.dart';

class KanbanScreen extends ConsumerWidget {
  const KanbanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routineListProvider);
    final columns = {
      RoutineStatus.todo: routines.where((r) => r.status == RoutineStatus.todo).toList(),
      RoutineStatus.doing: routines.where((r) => r.status == RoutineStatus.doing).toList(),
      RoutineStatus.done: routines.where((r) => r.status == RoutineStatus.done).toList(),
    };

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          for (final entry in columns.entries) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_title(entry.key), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: ListView(
                        children: [
                          for (final r in entry.value)
                            Card(
                              child: ListTile(
                                title: Text(r.title),
                                subtitle: r.description != null ? Text(r.description!) : null,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ]
        ],
      ),
    );
  }

  String _title(RoutineStatus s) {
    switch (s) {
      case RoutineStatus.todo: return '할 일';
      case RoutineStatus.doing: return '진행중';
      case RoutineStatus.done: return '완료';
    }
  }
}
