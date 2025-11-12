import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/routine_provider.dart';
import '../models/routine.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routineListProvider);
    final total = routines.length;
    final done = routines.where((r) => r.status == RoutineStatus.done).length;
    final completionRate = total == 0 ? 0.0 : (done / total);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('완료율'),
              subtitle: Text('${(completionRate * 100).toStringAsFixed(1)}%'),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 60,
                sections: [
                  PieChartSectionData(value: done.toDouble(), title: '완료 $done'),
                  PieChartSectionData(value: (total - done).toDouble(), title: '미완료 ${total - done}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
