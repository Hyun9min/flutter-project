import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/routine_provider.dart';
import '../widgets/routine_card.dart';

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routineListProvider);

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemBuilder: (_, i) => RoutineCard(routine: routines[i]),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: routines.length,
    );
  }
}
