import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/routine.dart';

// 통계 탭 화면
class StatisticsView extends ConsumerWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 전체 루틴 상태 가져오기
    final routines = ref.watch(routinesProvider);
    // 완료된 루틴만 추려서 사용
    final completed =
        routines.where((r) => r.status == RoutineStatus.done).toList();
    // 완료율 계산 (전체 중 완료된 비율, %)
    final total = routines.length;
    final completionRate =
        total == 0 ? 0 : ((completed.length / total) * 100).round();
    // 완료된 루틴들 기준 평균 집중도 (1~5 레벨 평균)
    final avgFocus = completed.isEmpty
        ? '0.0'
        : (completed.fold<int>(0, (sum, r) => sum + r.focusLevel) /
                completed.length)
            .toStringAsFixed(1);
    // 총 집중 시간 계산 (실제 시간 사용, 없으면 목표 시간 사용)
    final totalSeconds = completed.fold<int>(
      0,
      (sum, r) => sum + (r.actualSeconds ?? r.estimatedTime * 60),
    );
    final duration = Duration(seconds: totalSeconds);
    final timeLabel = duration.inHours > 0
        ? '${duration.inHours}시간 ${duration.inMinutes % 60}분'
        : duration.inMinutes > 0
            ? '${duration.inMinutes}분 ${duration.inSeconds % 60}초'
            : '${duration.inSeconds}초';
    // 목표 시간 안에 끝낸 루틴 개수
    final onTimeCount = completed
        .where((r) =>
            (r.actualSeconds ?? r.estimatedTime * 60) <= r.estimatedTime * 60)
        .length;
    // 상태별 개수 (대기 / 진행 / 완료)
    final todoCount =
        routines.where((r) => r.status == RoutineStatus.todo).length;
    final inProgressCount =
        routines.where((r) => r.status == RoutineStatus.inProgress).length;
    final doneCount = completed.length;

    // 파이 차트에 들어갈 섹션 데이터
    final chartSections = _buildChartSections(
      todo: todoCount,
      inProgress: inProgressCount,
      done: doneCount,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F7),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _Header(dateLabel: _todayLabel()),
            const SizedBox(height: 16),
            // 상단 4개 통계 카드 (2x2 Grid)
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              children: [
                _StatCard(
                  icon: Icons.flag_rounded,
                  label: '완료율',
                  value: '$completionRate%',
                  iconBg: const Color(0xFFE8FBF1),
                  iconColor: const Color(0xFF2ECC71),
                ),
                _StatCard(
                  icon: Icons.bolt_rounded,
                  label: '평균 집중도',
                  value: avgFocus,
                  iconBg: const Color(0xFFE3F2FF),
                  iconColor: const Color(0xFF007AFF),
                ),
                _StatCard(
                  icon: Icons.access_time_filled_rounded,
                  label: '총 집중 시간',
                  value: timeLabel,
                  iconBg: const Color(0xFFF3E8FF),
                  iconColor: const Color(0xFF8E5CFF),
                ),
                _StatCard(
                  icon: Icons.emoji_events_rounded,
                  label: '완료 횟수',
                  value: '$onTimeCount회',
                  iconBg: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFFF9F0A),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 상태 분포 파이 차트
            _ChartCard(sections: chartSections),
            const SizedBox(height: 20),
            // 목표 시간 대비 더 빠르게 끝낸 상위 루틴 목록
            _TopFocusRoutinesSection(routines: completed),
          ],
        ),
      ),
    );
  }
}

// 통계 화면 상단 헤더
class _Header extends StatelessWidget {
  const _Header({required this.dateLabel});

  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '통계',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(Icons.bar_chart_rounded, color: Color(0xFF6366F1)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          dateLabel,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }
}

// 상단 통계 카드 하나 (완료율, 평균 집중도 등)
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconBg,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// 상태 분포 파이 차트 카드
class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.sections});

  final List<PieChartSectionData> sections;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '상태 분포',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: sections,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 12,
            children: [
              _LegendDot(color: Color(0xFFE2E8F0), label: '대기'),
              _LegendDot(color: Color(0xFF6366F1), label: '진행 중'),
              _LegendDot(color: Color(0xFF34C759), label: '완료'),
            ],
          )
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// "최고 집중 루틴" 영역
class _TopFocusRoutinesSection extends StatelessWidget {
  const _TopFocusRoutinesSection({required this.routines});
  // 완료된 루틴 리스트 (상위에서 필터링해서 내려줌)
  final List<Routine> routines;

  @override
  Widget build(BuildContext context) {
    // 완료된 루틴 자체가 없을 때
    if (routines.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: const Text(
          '완료된 루틴이 아직 없어요.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // 설정 시간보다 빨리 끝낸 루틴만 필터링
    final fasterRoutines = routines.where((r) {
      final estimatedSeconds = r.estimatedTime * 60;
      final actualSeconds = r.actualSeconds;
      if (actualSeconds == null) return false;
      if (estimatedSeconds <= 0) return false;
      return actualSeconds < estimatedSeconds;
    }).toList();

    // 빠르게 끝낸 루틴이 하나도 없을 때
    if (fasterRoutines.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: const Text(
          '설정한 시간보다 빠르게 완료한 루틴이 아직 없어요.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // "절약 비율(%)" 기준으로 정렬
    fasterRoutines.sort((a, b) {
      final estA = a.estimatedTime * 60;
      final estB = b.estimatedTime * 60;
      final actA = a.actualSeconds!;
      final actB = b.actualSeconds!;

      final ratioA = (estA - actA) / estA; // 0.0 ~ 1.0
      final ratioB = (estB - actB) / estB;

      final cmpRatio = ratioB.compareTo(ratioA); // 큰 비율 먼저
      if (cmpRatio != 0) return cmpRatio;

      // 비율 같으면 집중도 높은 순
      final cmpFocus = b.focusLevel.compareTo(a.focusLevel);
      if (cmpFocus != 0) return cmpFocus;

      // 그래도 같으면 제목 순
      return a.title.compareTo(b.title);
    });
    // 상위 5개까지만 표시
    final top5 = fasterRoutines.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, size: 18, color: Colors.grey),
              SizedBox(width: 6),
              Text(
                '최고 집중 루틴',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...top5.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final routine = entry.value;

            final est = routine.estimatedTime * 60;
            final act = routine.actualSeconds ?? est;
            final ratio = est > 0 ? (est - act) / est : 0.0;
            final savedPercent = (ratio * 100).toStringAsFixed(2); // 퍼센트 단위

            final seconds = act;
            final timeLabel = seconds >= 60
                ? '${seconds ~/ 60}분 ${seconds % 60}초'
                : '$seconds초';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F7),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFFE0E7FF),
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4C54D2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 루틴 정보 (제목, 집중도, 목표 대비 절약 비율)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routine.title,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        // 실제 소요 시간(완료 시간)
                        Text(
                          'Lv.${routine.focusLevel} · 목표 시간(${routine.estimatedTime}분) 대비 ${savedPercent}％ 단축',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    timeLabel,
                    style: const TextStyle(
                      fontSize: 12,
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

// 파이 차트에 사용할 섹션 데이터 만들기
List<PieChartSectionData> _buildChartSections({
  required int todo,
  required int inProgress,
  required int done,
}) {
  // total이 0일 때도 0으로 나누는 상황을 피하기 위해 최소값 1로 clamp
  final total = (todo + inProgress + done).clamp(1, 1 << 30);

  return [
    PieChartSectionData(
      color: const Color(0xFFE2E8F0), // 대기
      value: todo.toDouble(),
      title: '',
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(0xFF475569),
      ),
      radius: 65,
    ),
    PieChartSectionData(
      color: const Color(0xFF6366F1), // 진행 중
      value: inProgress.toDouble(),
      title: '',
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      radius: 65,
    ),
    PieChartSectionData(
      color: const Color(0xFF34C759), // 완료
      value: done.toDouble(),
      title: '',
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      radius: 65,
    ),
  ];
}

// 상단에 표시할 "오늘 날짜" 텍스트
String _todayLabel() {
  final now = DateTime.now();
  return '${now.year}년 ${now.month}월 ${now.day}일';
}
