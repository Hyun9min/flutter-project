import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';
import '../providers/routine_provider.dart';

class RoutineTimer extends ConsumerStatefulWidget {
  final Routine routine;
  const RoutineTimer({super.key, required this.routine});

  @override
  ConsumerState<RoutineTimer> createState() => _RoutineTimerState();
}

class _RoutineTimerState extends ConsumerState<RoutineTimer> {
  late Timer _tick;
  Duration elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (widget.routine.startedAt != null) {
        setState(() {
          elapsed = DateTime.now().difference(widget.routine.startedAt!);
        });
      }
    });
  }

  @override
  void dispose() {
    _tick.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.routine;
    final expected = r.expected ?? const Duration(minutes: 25);
    final over = elapsed > expected;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.timer_outlined),
        title: Text(r.title),
        subtitle: Text('경과: ${elapsed.inMinutes}분 ${elapsed.inSeconds % 60}초 / 예상 ${expected.inMinutes}분'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!over) const Icon(Icons.check_circle_outline)
            else const Icon(Icons.error_outline),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => ref.read(routineListProvider.notifier).completeRoutine(r),
              child: const Text('완료'),
            )
          ],
        ),
      ),
    );
  }
}
