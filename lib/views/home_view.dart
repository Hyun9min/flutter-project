import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';
import '../widgets/routine_card.dart';

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
    final doneCount = done.length;
    final completionRate = total == 0 ? 0.0 : doneCount / total;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 "오늘" + 날짜 + 플로팅 플러스 버튼
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '오늘',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dateText(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF6366F1),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // "오늘의 진행" 카드
          _TodayProgressCard(
            completionRate: completionRate,
            waitingCount: todo.length,
            inProgressCount: inProgress.length,
            doneCount: done.length,
          ),

          const SizedBox(height: 24),

          // 진행할 루틴 섹션
          if (inProgress.isNotEmpty || todo.isNotEmpty) ...[
            _SectionHeader(title: '진행할 루틴'),
            const SizedBox(height: 12),
            ...inProgress.map(
              (r) => RoutineCard(
                routine: r,
                style: RoutineCardStyle.running, // 아래에서 새로 정의
              ),
            ),
            ...todo.map(
              (r) => RoutineCard(
                routine: r,
                style: RoutineCardStyle.normal,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // 완료된 루틴
          if (done.isNotEmpty) ...[
            _SectionHeader(title: '완료됨'),
            const SizedBox(height: 12),
            ...done.map(
              (r) => RoutineCard(
                routine: r,
                style: RoutineCardStyle.completed,
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _dateText() {
    final now = DateTime.now();
    const weekdayKo = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdayKo[now.weekday - 1];
    return '${now.month}월 ${now.day}일 ${weekday}요일';
  }
}

class _TodayProgressCard extends StatelessWidget {
  final double completionRate;
  final int waitingCount;
  final int inProgressCount;
  final int doneCount;

  const _TodayProgressCard({
    required this.completionRate,
    required this.waitingCount,
    required this.inProgressCount,
    required this.doneCount,
  });

  @override
  Widget build(BuildContext context) {
    final percentText = (completionRate * 100).toStringAsFixed(0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 텍스트 라인
          Row(
            children: [
              const Text(
                '오늘의 진행',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                '상세보기',
                style: TextStyle(
                  color: const Color(0xFF6366F1),
                  fontSize: 12,
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
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 진행 막대
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: completionRate,
              minHeight: 6,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF8B5CF6)),
            ),
          ),

          const SizedBox(height: 16),

          // 상태 3개
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatusColumn(
                label: '대기중',
                count: waitingCount,
                color: const Color(0xFF4B5563),
              ),
              _StatusColumn(
                label: '진행중',
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
  final String label;
  final int count;
  final Color color;

  const _StatusColumn({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
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
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}
