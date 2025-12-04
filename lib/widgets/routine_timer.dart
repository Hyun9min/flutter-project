import 'dart:async';

import 'package:flutter/material.dart';

// 루틴 카드 안에서 사용하는 실시간 타이머 위젯
class RoutineTimer extends StatefulWidget {
  const RoutineTimer({
    super.key,
    required this.accumulatedSeconds,
    required this.runningSince,
    required this.estimatedSeconds,
  });
  // 이전까지 누적된 시간(초)
  final int accumulatedSeconds;
  // 현재 진행을 시작한 시각 (null이면 일시정지 상태)
  final DateTime? runningSince;
  // 목표 시간(초 단위) – 루틴 생성 시 설정한 분 * 60
  final int estimatedSeconds;

  @override
  State<RoutineTimer> createState() => _RoutineTimerState();
}

class _RoutineTimerState extends State<RoutineTimer> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _setupTicker(); // 처음 마운트될 때 타이머 세팅
  }

  @override
  void didUpdateWidget(RoutineTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // runningSince 값이 바뀌었을 때(시작/일시정지/재시작) 타이머 재설정
    if (oldWidget.runningSince != widget.runningSince) {
      _setupTicker();
    }
  }

  // 타이머를 생성하거나 정리하는 함수
  void _setupTicker() {
    _ticker?.cancel(); // 기존 타이머 정리
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
    _ticker?.cancel(); // 위젯이 사라질 때 타이머 정리
    super.dispose();
  }

  // 지금까지의 총 경과 시간(초)
  int get _elapsedSeconds {
    if (widget.runningSince == null) {
      return widget.accumulatedSeconds;
    }
    final diff = DateTime.now().difference(widget.runningSince!).inSeconds;
    return widget.accumulatedSeconds + diff;
  }

  // 화면에 표시할 시계 텍스트 (MM:SS)
  String get _clockText {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final estimated = widget.estimatedSeconds;
    // 진행률: 0.0 ~ 1.0
    final progress =
        estimated == 0 ? 0.0 : (_elapsedSeconds / estimated).clamp(0.0, 1.0);
    // 목표 시간 초과 여부
    final isOvertime = estimated > 0 && _elapsedSeconds > estimated;
    // 일시정지 여부
    final isPaused = widget.runningSince == null;
    // 진행 바 색상: 초과 시 빨간색, 그 외는 파란색 계열
    final barColor = isOvertime ? Colors.red : const Color(0xFF2563EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단: 아이콘 + 시간 텍스트 + 목표 시간 텍스트
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // 일시정지/진행 상태에 따른 아이콘
                Icon(
                  isPaused ? Icons.pause_circle_filled : Icons.access_time,
                  size: 16,
                  color: isPaused
                      ? Colors.grey
                      : (isOvertime ? Colors.red : const Color(0xFF2563EB)),
                ),
                const SizedBox(width: 6),
                // MM:SS 형태의 타이머 텍스트
                Text(
                  _clockText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isPaused
                        ? Colors.grey[600]
                        : (isOvertime ? Colors.red : const Color(0xFF2563EB)),
                  ),
                ),
              ],
            ),
            // 우측에 목표 시간 표시 (분 단위)
            Text(
              '목표 ${estimated ~/ 60}분',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // 진행 바 (목표 시간 대비 진행률)
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation(barColor),
          ),
        ),
        // 상태에 따른 보조 메시지 (일시정지 / 초과)
        if (isPaused) ...[
          const SizedBox(height: 4),
          const Text(
            '일시정지 중',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ] else if (isOvertime) ...[
          const SizedBox(height: 4),
          const Text(
            '⚠️ 예상 시간을 초과했어요',
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
