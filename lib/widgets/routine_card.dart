import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routine_timer.dart';
import '../models/routine.dart';

/// Figma 스타일에 맞게 카드 모양을 조금 더 세분화
enum RoutineCardStyle {
  normal, // 기본 대기/일반 카드
  running, // 진행중
  completed, // 완료
}

class RoutineCard extends ConsumerWidget {
  final Routine routine;
  final RoutineCardStyle style;

  const RoutineCard({
    super.key,
    required this.routine,
    this.style = RoutineCardStyle.normal,
  });

  Color get _accentColor {
    switch (style) {
      case RoutineCardStyle.running:
        return const Color(0xFF2563EB); // 파랑
      case RoutineCardStyle.completed:
        return const Color(0xFF16A34A); // 초록
      case RoutineCardStyle.normal:
        return const Color(0xFFF97316); // 주황
    }
  }

  String get _statusBadgeText {
    switch (style) {
      case RoutineCardStyle.running:
        return '진행중';
      case RoutineCardStyle.completed:
        return '완료';
      case RoutineCardStyle.normal:
        return '대기';
    }
  }

  Color get _statusBadgeColor {
    switch (style) {
      case RoutineCardStyle.running:
        return const Color(0xFF6366F1);
      case RoutineCardStyle.completed:
        return const Color(0xFF22C55E);
      case RoutineCardStyle.normal:
        return const Color(0xFFF97316);
    }
  }

  String get _actionText {
    switch (style) {
      case RoutineCardStyle.running:
        return '완료';
      case RoutineCardStyle.completed:
        return '완료됨';
      case RoutineCardStyle.normal:
        return '시작';
    }
  }

  Color get _actionColor {
    switch (style) {
      case RoutineCardStyle.running:
        return const Color(0xFF2563EB);
      case RoutineCardStyle.completed:
        return const Color(0xFF16A34A);
      case RoutineCardStyle.normal:
        return const Color(0xFF2563EB);
    }
  }

  void _onPrimaryPressed(WidgetRef ref) {
    final notifier = ref.read(routinesProvider.notifier);

    switch (style) {
      case RoutineCardStyle.normal:
        // 대기 → 진행중
        notifier.startRoutine(routine);
        break;
      case RoutineCardStyle.running:
        // 진행중 → 완료
        notifier.completeRoutine(routine);
        break;
      case RoutineCardStyle.completed:
        // 완료 카드는 버튼이 없으니까 여기 안 옴
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durationText = '${routine.estimatedTime}분';

    final progressValue = switch (style) {
      RoutineCardStyle.normal => 0.0,
      RoutineCardStyle.running => 0.5,
      RoutineCardStyle.completed => 1.0,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 + 상태 뱃지
          Row(
            children: [
              Expanded(
                child: Text(
                  routine.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBadgeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 14,
                      color: _statusBadgeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _statusBadgeText,
                      style: TextStyle(
                        fontSize: 11,
                        color: _statusBadgeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (routine.status == RoutineStatus.inProgress &&
              routine.startTime != null) ...[
            const SizedBox(height: 8),
            RoutineTimer(
              startTime: routine.startTime!,
              estimatedMinutes: routine.estimatedTime,
            ),
            const SizedBox(height: 8),
          ],

          if (routine.description != null &&
              routine.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              routine.description!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // 진행 바
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 6,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation(_accentColor),
            ),
          ),

          const SizedBox(height: 12),

          // 시간 + 액션 버튼
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                durationText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              if (style != RoutineCardStyle.completed)
                _PrimaryActionButton(
                  label: _actionText,
                  color: _actionColor,
                  onTap: () => _onPrimaryPressed(ref),
                )
              else
                _CompletedChip(color: _accentColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.play_arrow_rounded,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedChip extends StatelessWidget {
  final Color color;

  const _CompletedChip({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          const Text(
            '완료',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
