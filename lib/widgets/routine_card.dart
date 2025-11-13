import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/routine.dart';
import 'routine_form_sheet.dart';
import 'routine_timer.dart';

enum RoutineCardStyle {
  normal,
  running,
  completed,
}

enum _CardMenu { edit, delete }

class RoutineCard extends ConsumerWidget {
  const RoutineCard({
    super.key,
    required this.routine,
    this.style = RoutineCardStyle.normal,
  });

  final Routine routine;
  final RoutineCardStyle style;

  bool get _isPaused =>
      routine.status == RoutineStatus.inProgress &&
      routine.runningSince == null;

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

  String get _statusBadgeText {
    switch (style) {
      case RoutineCardStyle.running:
        return _isPaused ? '\uC77C\uC2DC\uC815\uC9C0' : '\uC9C4\uD589 \uC911';
      case RoutineCardStyle.completed:
        return '\uC644\uB8CC';
      case RoutineCardStyle.normal:
        return '\uB300\uAE30';
    }
  }

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

  String get _actionText {
    switch (style) {
      case RoutineCardStyle.running:
        return '\uC644\uB8CC';
      case RoutineCardStyle.completed:
        return '\uC644\uB8CC\uB428';
      case RoutineCardStyle.normal:
        return '\uC2DC\uC791';
    }
  }

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

  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes == 0) {
      return '$secs\uCD08';
    }
    return '$minutes\uBD84 ${secs.toString().padLeft(2, '0')}\uCD08';
  }

  String get _durationText {
    if (routine.status == RoutineStatus.done &&
        routine.actualSeconds != null) {
      final actual = routine.actualSeconds!;
      final display = _formatSeconds(actual);
      return '\uC2E4\uC81C $actual\uCD08 ($display) \u00B7 \uBAA9\uD45C ${routine.estimatedTime}\uBD84';
    }
    return '\uBAA9\uD45C ${routine.estimatedTime}\uBD84';
  }

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

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _onPrimaryPressed(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(routinesProvider.notifier);
    switch (style) {
      case RoutineCardStyle.normal:
        final started = notifier.startRoutine(routine);
        if (!started) {
          _showSnack(
            context,
            '\uC774\uBBF8 \uC9C4\uD589 \uC911\uC778 \uB8E8\uD2F4\uC774 \uC788\uC5B4\uC694.',
          );
        }
        break;
      case RoutineCardStyle.running:
        notifier.completeRoutine(routine);
        _showSnack(context, '\uB8E8\uD2F4\uC744 \uC644\uB8CC\uD588\uC5B4\uC694.');
        break;
      case RoutineCardStyle.completed:
        break;
    }
  }

  void _onPauseResume(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(routinesProvider.notifier);
    final success = _isPaused
        ? notifier.resumeRoutine(routine)
        : notifier.pauseRoutine(routine);
    if (!success) {
      _showSnack(
        context,
        '\uB2E4\uB978 \uB8E8\uD2F4\uC774 \uC9C4\uD589 \uC911\uC774\uB77C \uC870\uC791\uD560 \uC218 \uC5C6\uC5B4\uC694.',
      );
    }
  }

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

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('\uB8E8\uD2F4 \uC0AD\uC81C'),
          content: Text(
            '\u2018${routine.title}\u2019 \uB8E8\uD2F4\uC744 \uC0AD\uC81C\uD560\uAE4C\uC694?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('\uCDE8\uC18C'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('\uC0AD\uC81C'),
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;

    if (result == true) {
      ref.read(routinesProvider.notifier).deleteRoutine(routine.id);
      _showSnack(context, '\uB8E8\uD2F4\uC744 \uC0AD\uC81C\uD588\uC5B4\uC694.');
    }
  }

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              PopupMenuButton<_CardMenu>(
                onSelected: (menu) => _onMenuSelected(context, ref, menu),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _CardMenu.edit,
                    child: Text('\uD3B8\uC9D1'),
                  ),
                  PopupMenuItem(
                    value: _CardMenu.delete,
                    child: Text('\uC0AD\uC81C'),
                  ),
                ],
                icon: const Icon(Icons.more_horiz),
              ),
            ],
          ),
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
          if (routine.status == RoutineStatus.inProgress) ...[
            const SizedBox(height: 14),
            RoutineTimer(
              accumulatedSeconds: routine.accumulatedSeconds,
              runningSince: routine.runningSince,
              estimatedSeconds: routine.estimatedTime * 60,
            ),
          ],
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
                  '\uC2E4\uC81C ${_formatSeconds(routine.actualSeconds!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
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
              if (style == RoutineCardStyle.normal)
                _PrimaryActionButton(
                  label: _actionText,
                  icon: _actionIcon,
                  color: _accentColor,
                  onTap: () => _onPrimaryPressed(context, ref),
                )
              else if (style == RoutineCardStyle.running) ...[
                _SecondaryActionButton(
                  label: _isPaused ? '\uC7AC\uAC1C' : '\uC77C\uC2DC\uC815\uC9C0',
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
                _CompletedChip(color: _accentColor),
            ],
          ),
        ],
      ),
    );
  }
}

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
            '\uC644\uB8CC',
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
