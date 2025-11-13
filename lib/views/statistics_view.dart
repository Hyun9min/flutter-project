import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/routine.dart';

class StatisticsView extends ConsumerWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider);
    final completed =
        routines.where((r) => r.status == RoutineStatus.done).toList();
    final total = routines.length;

    final completionRate =
        total > 0 ? ((completed.length / total) * 100).round() : 0;

    final avgFocus = completed.isNotEmpty
        ? (completed.fold<int>(0, (sum, r) => sum + r.focusLevel) /
                completed.length)
            .toStringAsFixed(1)
        : '0.0';

    final totalMinutes = completed.fold<int>(
      0,
      (sum, r) => sum + (r.actualTime ?? r.estimatedTime),
    );
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    final onTimeCount = completed
        .where((r) => (r.actualTime ?? r.estimatedTime) <= r.estimatedTime)
        .length;

    final todoCount =
        routines.where((r) => r.status == RoutineStatus.todo).length;
    final inProgressCount =
        routines.where((r) => r.status == RoutineStatus.inProgress).length;
    final doneCount =
        routines.where((r) => r.status == RoutineStatus.done).length;

    final chartSections = _buildChartSections(
      todo: todoCount,
      inProgress: inProgressCount,
      done: doneCount,
    );

    final todayText = _todayLabel();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 iOS 스타일 네비
            Container(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 8, bottom: 12),
              color: const Color(0xFFF2F2F7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '통계',
                        style: TextStyle(
                          fontSize: 34,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: 데일리 요약 바텀시트 연결
                        },
                        child: const Text(
                          '요약보기',
                          style: TextStyle(
                            color: Color(0xFF007AFF),
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    todayText,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  // 도넛 차트 카드
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x11000000),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '진행률',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: Stack(
                            children: [
                              PieChart(
                                PieChartData(
                                  sections: chartSections,
                                  centerSpaceRadius: 60,
                                  sectionsSpace: 2,
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$completionRate%',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        color: Color(0xFF007AFF),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      '완료율',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _LegendDot(
                              color: const Color(0xFF8E8E93),
                              label: '대기 $todoCount',
                            ),
                            _LegendDot(
                              color: const Color(0xFFFF9500),
                              label: '진행 $inProgressCount',
                            ),
                            _LegendDot(
                              color: const Color(0xFF34C759),
                              label: '완료 $doneCount',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 네 개의 통계 카드
                  GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _StatCard(
                        icon: Icons.flag_rounded,
                        iconBg: const Color(0xFFE4FBEA),
                        iconColor: const Color(0xFF34C759),
                        value: '$completionRate%',
                        label: '완료율',
                      ),
                      _StatCard(
                        icon: Icons.bolt_rounded,
                        iconBg: const Color(0xFFE3F2FF),
                        iconColor: const Color(0xFF007AFF),
                        value: avgFocus,
                        label: '평균 집중도',
                      ),
                      _StatCard(
                        icon: Icons.access_time_filled_rounded,
                        iconBg: const Color(0xFFF3E8FF),
                        iconColor: const Color(0xFF8E5CFF),
                        value:
                            hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m',
                        label: '총 소요시간',
                      ),
                      _StatCard(
                        icon: Icons.emoji_events_rounded,
                        iconBg: const Color(0xFFFFF3E0),
                        iconColor: const Color(0xFFFF9500),
                        value: '$onTimeCount',
                        label: '시간 준수',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  if (completed.isNotEmpty)
                    _TopFocusRoutinesSection(routines: completed),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections({
    required int todo,
    required int inProgress,
    required int done,
  }) {
    final total = todo + inProgress + done;
    if (total == 0) {
      return [
        PieChartSectionData(
          value: 1,
          color: const Color(0xFFE5E7EB),
          radius: 40,
        ),
      ];
    }

    return [
      if (done > 0)
        PieChartSectionData(
          value: done.toDouble(),
          color: const Color(0xFF34C759),
          radius: 40,
        ),
      if (inProgress > 0)
        PieChartSectionData(
          value: inProgress.toDouble(),
          color: const Color(0xFFFF9500),
          radius: 40,
        ),
      if (todo > 0)
        PieChartSectionData(
          value: todo.toDouble(),
          color: const Color(0xFF8E8E93),
          radius: 40,
        ),
    ];
  }

  String _todayLabel() {
    final now = DateTime.now();
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[now.weekday - 1];
    return '${now.month}월 ${now.day}일 $weekday요일';
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopFocusRoutinesSection extends StatelessWidget {
  final List<Routine> routines;

  const _TopFocusRoutinesSection({required this.routines});

  @override
  Widget build(BuildContext context) {
    final sorted = [...routines]
      ..sort((a, b) => b.focusLevel.compareTo(a.focusLevel));
    final top5 = sorted.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.trending_up, size: 18, color: Colors.grey),
              SizedBox(width: 6),
              Text(
                '최고 집중 루틴',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...top5.asMap().entries.map((entry) {
            final index = entry.key;
            final routine = entry.value;
            final duration = routine.actualTime ?? routine.estimatedTime;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF007AFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      routine.title,
                      style: const TextStyle(fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lv.${routine.focusLevel}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF007AFF),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${duration}분',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
