import 'dart:async';

import 'package:flutter/material.dart';

class RoutineTimer extends StatefulWidget {
  const RoutineTimer({
    super.key,
    required this.accumulatedSeconds,
    required this.runningSince,
    required this.estimatedSeconds,
  });

  final int accumulatedSeconds;
  final DateTime? runningSince;
  final int estimatedSeconds;

  @override
  State<RoutineTimer> createState() => _RoutineTimerState();
}

class _RoutineTimerState extends State<RoutineTimer> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _setupTicker();
  }

  @override
  void didUpdateWidget(RoutineTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.runningSince != widget.runningSince) {
      _setupTicker();
    }
  }

  void _setupTicker() {
    _ticker?.cancel();
    if (widget.runningSince != null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  int get _elapsedSeconds {
    if (widget.runningSince == null) {
      return widget.accumulatedSeconds;
    }
    final diff = DateTime.now().difference(widget.runningSince!).inSeconds;
    return widget.accumulatedSeconds + diff;
  }

  String get _clockText {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final estimated = widget.estimatedSeconds;
    final progress = estimated == 0
        ? 0.0
        : (_elapsedSeconds / estimated).clamp(0.0, 1.0);
    final isOvertime =
        estimated > 0 && _elapsedSeconds > estimated;
    final isPaused = widget.runningSince == null;
    final barColor =
        isOvertime ? Colors.red : const Color(0xFF2563EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isPaused ? Icons.pause_circle_filled : Icons.access_time,
                  size: 16,
                  color: isPaused
                      ? Colors.grey
                      : (isOvertime ? Colors.red : const Color(0xFF2563EB)),
                ),
                const SizedBox(width: 6),
                Text(
                  _clockText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isPaused
                        ? Colors.grey[600]
                        : (isOvertime
                            ? Colors.red
                            : const Color(0xFF2563EB)),
                  ),
                ),
              ],
            ),
            Text(
              '\uBAA9\uD45C ${estimated ~/ 60}\uBD84',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation(barColor),
          ),
        ),
        if (isPaused) ...[
          const SizedBox(height: 4),
          const Text(
            '\uC77C\uC2DC\uC815\uC9C0 \uC911',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ] else if (isOvertime) ...[
          const SizedBox(height: 4),
          const Text(
            '\u26A0\uFE0F \uC608\uC0C1 \uC2DC\uAC04\uC744 \uCD08\uACFC\uD588\uC5B4\uC694',
            style: TextStyle(
              fontSize: 11,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}
