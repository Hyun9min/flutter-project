import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/routine.dart';
import 'routine_form_sheet.dart';
import 'routine_timer.dart';

// 카드 스타일 종류
enum RoutineCardStyle {
  normal,
  running,
  completed,
}

// 카드에서 사용하는 팝업 메뉴 항목 (편집 / 삭제
enum _CardMenu { edit, delete }

// 개별 루틴을 카드 형태로 보여주는 위젯
class RoutineCard extends ConsumerWidget {
  const RoutineCard({
    super.key,
    required this.routine,
    this.style = RoutineCardStyle.normal,
  });
  // 표시할 루틴 데이터
  final Routine routine;
  // 카드가 어떤 상태로 보여질지 결정하는 스타일
  final RoutineCardStyle style;

  // 진행 중 상태인데 runningSince가 null이면 일시정지 상태로 봄
  bool get _isPaused =>
      routine.status == RoutineStatus.inProgress &&
      routine.runningSince == null;
  // 카드에서 사용하는 포인트 색상
  Color get _accentColor {
    switch (style) {
      case RoutineCardStyle.running:
        return const Color(0xFF2563EB);
      case RoutineCardStyle.completed:
        return const Color(0xFF16A34A);
      case RoutineCardStyle.normal:
        return const Color(0xFF0EA5E9);
    }
  }

  // 상태 뱃지에 표시할 텍스트
  String get _statusBadgeText {
    switch (style) {
      case RoutineCardStyle.running:
        return _isPaused ? '일시정지' : '진행 중';
      case RoutineCardStyle.completed:
        return '완료';
      case RoutineCardStyle.normal:
        return '대기';
    }
  }

  // 상태 뱃지의 색상
  Color get _statusBadgeColor {
    switch (style) {
      case RoutineCardStyle.running:
        return _isPaused ? Colors.grey : const Color(0xFF6366F1);
      case RoutineCardStyle.completed:
        return const Color(0xFF22C55E);
      case RoutineCardStyle.normal:
        return const Color(0xFF0EA5E9);
    }
  }

  // 우측 액션 버튼에 들어갈 텍스트
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

  // 우측 액션 버튼에 들어갈 아이콘
  IconData get _actionIcon {
    switch (style) {
      case RoutineCardStyle.running:
        return Icons.check_rounded;
      case RoutineCardStyle.completed:
        return Icons.check_circle_rounded;
      case RoutineCardStyle.normal:
        return Icons.play_arrow_rounded;
    }
  }

  // 초 단위를 "X분 XX초" 형태로 포맷팅하는 함수
  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes == 0) {
      return '$secs초';
    }
    return '$minutes분 ${secs.toString().padLeft(2, '0')}초';
  }

  // 하단 "목표 / 실제" 설명 텍스트
  String get _durationText {
    if (routine.status == RoutineStatus.done && routine.actualSeconds != null) {
      final actual = routine.actualSeconds!;
      final display = _formatSeconds(actual);
      return '실제 $actual초 ($display) · 목표 ${routine.estimatedTime}분';
    }
    return '목표 ${routine.estimatedTime}분';
  }

  // 진행 바 값 (0.0 ~ 1.0)
  double get _progressValue {
    if (style == RoutineCardStyle.completed) {
      return 1;
    }
    if (style == RoutineCardStyle.running) {
      final estimatedSeconds = routine.estimatedTime * 60;
      if (estimatedSeconds == 0) {
        return 0;
      }
      final runningSeconds = routine.runningSince != null
          ? DateTime.now().difference(routine.runningSince!).inSeconds
          : 0;
      final elapsed = routine.accumulatedSeconds + runningSeconds;
      return (elapsed / estimatedSeconds).clamp(0.0, 1.0);
    }
    return 0;
  }

  // 스낵바로 안내 메시지 보여주기 공용 함수
  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // 하단 메인 액션 버튼 "시작 / 완료 / 완료됨" 눌렀을 때 동작
  void _onPrimaryPressed(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(routinesProvider.notifier);
    switch (style) {
      case RoutineCardStyle.normal:
        final started = notifier.startRoutine(routine);
        if (!started) {
          _showSnack(
            context,
            '이미 진행 중인 루틴이 있어요.',
          );
        }
        break;
      case RoutineCardStyle.running:
        notifier.completeRoutine(routine);
        _showSnack(context, '루틴을 완료했어요.');
        break;
      case RoutineCardStyle.completed:
        break;
    }
  }

  // "일시정지 / 다시 시작" 버튼 동작 처리
  void _onPauseResume(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(routinesProvider.notifier);

    // 현재 카드가 일시정지 상태인지 저장
    final bool wasPaused = _isPaused;

    // 일시정지였다면 재개, 아니면 일시정지
    final success = wasPaused
        ? notifier.resumeRoutine(routine)
        : notifier.pauseRoutine(routine);

    if (!success) {
      _showSnack(
        context,
        '다른 루틴이 진행 중이라 조작할 수 없어요.',
      );
      return;
    }

    // 성공적으로 상태가 변경된 경우 안내 메시지 표시
    if (wasPaused) {
      _showSnack(context, '할 일을 시작합니다.');
    } else {
      _showSnack(context, '할 일을 중단합니다.');
    }
  }

  // 편집용 바텀시트 열기 (루틴 수정)
  void _openForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => RoutineFormSheet(initialRoutine: routine),
    );
  }

  // 삭제 확인 다이얼로그 띄우고, 확인 시 루틴 삭제
  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('루틴 삭제'),
          content: Text(
            '‘${routine.title}’ 루틴을 삭제할까요?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
    // 다이얼로그 닫힌 후 context가 여전히 유효한지 확인
    if (!context.mounted) return;

    if (result == true) {
      ref.read(routinesProvider.notifier).deleteRoutine(routine.id);
      _showSnack(context, '루틴을 삭제했어요.');
    }
  }

  // 카드 우측 상단 메뉴(편집 / 삭제) 선택 시 동작
  void _onMenuSelected(BuildContext context, WidgetRef ref, _CardMenu menu) {
    switch (menu) {
      case _CardMenu.edit:
        _openForm(context);
        break;
      case _CardMenu.delete:
        _confirmDelete(context, ref);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 제목 / 집중 레벨 / 상태 뱃지 / 더보기 메뉴
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 + 집중 레벨
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.bolt_rounded,
                          size: 14,
                          color: Color(0xFFFFA500),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Lv.${routine.focusLevel}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFFFA500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 상태 뱃지 (대기 / 진행 중 / 일시정지 / 완료)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _overlayColor(_statusBadgeColor, 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusBadgeText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _statusBadgeColor,
                  ),
                ),
              ),
              // 우측 상단 더보기 메뉴 (편집/삭제)
              PopupMenuButton<_CardMenu>(
                onSelected: (menu) => _onMenuSelected(context, ref, menu),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _CardMenu.edit,
                    child: Text('편집'),
                  ),
                  PopupMenuItem(
                    value: _CardMenu.delete,
                    child: Text('삭제'),
                  ),
                ],
                icon: const Icon(Icons.more_horiz),
              ),
            ],
          ),
          // 설명이 있을 때만 표시
          if (routine.description != null &&
              routine.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              routine.description!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ],
          // 진행 중인 루틴이면 Timer UI 표시, 아니면 진행 바 표시
          if (routine.status == RoutineStatus.inProgress) ...[
            const SizedBox(height: 14),
            RoutineTimer(
              accumulatedSeconds: routine.accumulatedSeconds,
              runningSince: routine.runningSince,
              estimatedSeconds: routine.estimatedTime * 60,
            ),
          ] else ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: _progressValue,
                minHeight: 6,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation(_accentColor),
              ),
            ),
          ],
          // 완료된 루틴인 경우 실제 소요 시간 텍스트 표시
          if (routine.status == RoutineStatus.done &&
              routine.actualSeconds != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.timelapse_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '실제 ${_formatSeconds(routine.actualSeconds!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          // 하단: "목표/실제 시간 정보" + 액션 버튼 영역
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _durationText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              // 상태에 따라 다른 버튼 세트 표시
              if (style == RoutineCardStyle.normal)
                // 대기 상태: "시작" 버튼만
                _PrimaryActionButton(
                  label: _actionText,
                  icon: _actionIcon,
                  color: _accentColor,
                  onTap: () => _onPrimaryPressed(context, ref),
                )
              else if (style == RoutineCardStyle.running) ...[
                // 진행 중 상태: "일시정지 / 시작" + "완료" 버튼
                _SecondaryActionButton(
                  label: _isPaused ? '시작' : '일시정지',
                  icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause,
                  onTap: () => _onPauseResume(context, ref),
                ),
                const SizedBox(width: 8),
                _PrimaryActionButton(
                  label: _actionText,
                  icon: _actionIcon,
                  color: _accentColor,
                  onTap: () => _onPrimaryPressed(context, ref),
                ),
              ] else
                // 완료 상태: "완료" Chip만 표시
                _CompletedChip(color: _accentColor),
            ],
          ),
        ],
      ),
    );
  }
}

// 메인 액션 버튼(보라색/파란색 배경 버튼)
class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

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
            Icon(icon, size: 18, color: Colors.white),
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

// 서브 액션 버튼(파란색 테두리 아웃라인 버튼)
class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF2563EB),
        side: const BorderSide(color: Color(0xFFE0E7FF)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: const StadiumBorder(),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// 완료된 루틴일 때 우측에 보여주는 "완료" 칩
class _CompletedChip extends StatelessWidget {
  const _CompletedChip({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _overlayColor(color, 0.08),
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

Color _overlayColor(Color color, double opacity) {
  final normalized = opacity.clamp(0.0, 1.0);
  final alpha = (normalized * 255).round().clamp(0, 255);
  return color.withAlpha(alpha);
}
