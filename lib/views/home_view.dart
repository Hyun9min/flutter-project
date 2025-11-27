import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/routine.dart';
import '../widgets/routine_card.dart';
import '../widgets/routine_form_sheet.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider);
    final todo = routines.where((r) => r.status == RoutineStatus.todo).toList();
    final inProgress =
        routines.where((r) => r.status == RoutineStatus.inProgress).toList();
    final done = routines.where((r) => r.status == RoutineStatus.done).toList();

    final total = routines.length;
    final completionRate = total == 0 ? 0.0 : done.length / total;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        _Header(
          dateLabel: _dateText(),
          onAdd: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (context) => const RoutineFormSheet(),
            );
          },
        ),
        const SizedBox(height: 20),
        _TodayProgressCard(
          completionRate: completionRate,
          waitingCount: todo.length,
          inProgressCount: inProgress.length,
          doneCount: done.length,
        ),
        const SizedBox(height: 24),
        if (inProgress.isNotEmpty || todo.isNotEmpty) ...[
          const _SectionHeader(title: '진행 중 루틴'),
          const SizedBox(height: 12),
          ...inProgress.map(
            (routine) => RoutineCard(
              routine: routine,
              style: RoutineCardStyle.running,
            ),
          ),
          ...todo.map(
            (routine) => RoutineCard(
              routine: routine,
              style: RoutineCardStyle.normal,
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (done.isNotEmpty) ...[
          const _SectionHeader(title: '완료된 루틴'),
          const SizedBox(height: 12),
          ...done.map(
            (routine) => RoutineCard(
              routine: routine,
              style: RoutineCardStyle.completed,
            ),
          ),
        ],
        if (routines.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: _EmptyState(),
          ),
      ],
    );
  }

  String _dateText() {
    final now = DateTime.now();
    const weekdayKo = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdayKo[now.weekday - 1];
    return '${now.month}월 ${now.day}일 $weekday요일';
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onAdd, required this.dateLabel});

  final VoidCallback onAdd;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '오늘',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateLabel,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF6366F1),
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _TodayProgressCard extends StatelessWidget {
  const _TodayProgressCard({
    required this.completionRate,
    required this.waitingCount,
    required this.inProgressCount,
    required this.doneCount,
  });

  final double completionRate;
  final int waitingCount;
  final int inProgressCount;
  final int doneCount;

  @override
  Widget build(BuildContext context) {
    final percentText = (completionRate * 100).toStringAsFixed(0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '오늘의 진행',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                '완료율',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              Text(
                '$percentText%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: completionRate.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: const Color(0xFFEAEAEA),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF8B5CF6)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatusColumn(
                label: '대기 중',
                count: waitingCount,
                color: const Color(0xFF94A3B8),
              ),
              _StatusColumn(
                label: '진행 중',
                count: inProgressCount,
                color: const Color(0xFF6366F1),
              ),
              _StatusColumn(
                label: '완료',
                count: doneCount,
                color: const Color(0xFF22C55E),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusColumn extends StatelessWidget {
  const _StatusColumn({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Divider(
            thickness: 0.6,
            color: Color(0xFFE2E8F0),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F4F7),
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.nightlight_round,
            size: 40,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 12),
          Text(
            '오늘의 루틴을 추가해 보세요',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '루틴을 등록하면 자동으로 진행 현황이 정리됩니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
