import 'dart:async';
import 'package:flutter/material.dart';

class RoutineTimer extends StatefulWidget {
  final DateTime startTime;
  final int estimatedMinutes;

  const RoutineTimer({
    super.key,
    required this.startTime,
    required this.estimatedMinutes,
  });

  @override
  State<RoutineTimer> createState() => _RoutineTimerState();
}

class _RoutineTimerState extends State<RoutineTimer> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _elapsed = DateTime.now().difference(widget.startTime);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = DateTime.now().difference(widget.startTime);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = _elapsed.inSeconds;
    final minutes = seconds ~/ 60;
    final sec = seconds % 60;

    final estimatedSeconds = widget.estimatedMinutes * 60;
    final isOvertime = seconds > estimatedSeconds && estimatedSeconds > 0;
    final progress = estimatedSeconds == 0
        ? 0.0
        : (seconds / estimatedSeconds).clamp(0.0, 1.0);

    final timeText =
        '${minutes.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';

    final barColor = isOvertime ? Colors.red : const Color(0xFF2563EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: isOvertime ? Colors.red : const Color(0xFF2563EB),
                ),
                const SizedBox(width: 6),
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isOvertime ? Colors.red : const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            Text(
              '목표: ${widget.estimatedMinutes}분',
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
        if (isOvertime) ...[
          const SizedBox(height: 4),
          const Text(
            '⚠️ 예상 시간을 초과했습니다',
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
