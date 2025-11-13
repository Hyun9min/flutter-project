import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';

/// Figma 스타일에 맞게 카드 모양을 조금 더 세분화
enum RoutineCardStyle {
  normal, // 기본 대기/일반 카드
  running, // 진행중 (파란 버튼/바)
  completed, // 완료 (녹색)
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
      default:
        return const Color(0xFFF97316); // 주황 (중요/불꽃 느낌)
    }
  }

  String get _statusBadgeText {
    switch (style) {
      case RoutineCardStyle.running:
        return '중간';
      case RoutineCardStyle.completed:
        return '보통';
      case RoutineCardStyle.normal:
      default:
        return '홀로';
    }
  }

  Color get _statusBadgeColor {
    switch (style) {
      case RoutineCardStyle.running:
        return const Color(0xFFFACC15); // 노랑
      case RoutineCardStyle.completed:
        return const Color(0xFF4ADE80); // 연한 초록
      case RoutineCardStyle.normal:
      default:
        return const Color(0xFFF97316); // 주황
    }
  }

  String get _actionText {
    switch (style) {
      case RoutineCardStyle.running:
        return '일시정지';
      case RoutineCardStyle.completed:
        return '완료됨';
      case RoutineCardStyle.normal:
      default:
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
      default:
        return const Color(0xFF2563EB);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durationText = '${routine.estimatedTime}분';

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

          // 상단 진행 바 (진행중 카드일 때만 보여줘도 되고, 지금은 전부)
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: style == RoutineCardStyle.completed
                  ? 1
                  : (style == RoutineCardStyle.running ? 0.5 : 0.0),
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

  const _PrimaryActionButton({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
