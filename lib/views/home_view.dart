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
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (context) => const AddRoutineSheet(),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
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
            const _SectionHeader(title: '진행할 루틴'),
            const SizedBox(height: 12),
            ...inProgress.map(
              (r) => RoutineCard(
                routine: r,
                style: RoutineCardStyle.running,
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
            const _SectionHeader(title: '완료됨'),
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
    return '${now.month}월 ${now.day}일 $weekday요일';
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
              const _StatusColumn(
                label: '대기중',
                color: Color(0xFF4B5563),
              ),
              _StatusColumn(
                label: '진행중',
                color: const Color(0xFF6366F1),
                count: inProgressCount,
              ),
              _StatusColumn(
                label: '완료',
                color: const Color(0xFF22C55E),
                count: doneCount,
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
    required this.color,
    this.count = 0,
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

/// 루틴 추가 바텀시트
class AddRoutineSheet extends ConsumerStatefulWidget {
  const AddRoutineSheet({super.key});

  @override
  ConsumerState<AddRoutineSheet> createState() => _AddRoutineSheetState();
}

class _AddRoutineSheetState extends ConsumerState<AddRoutineSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  double _focusLevel = 3;
  int _estimatedMinutes = 25;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요.')),
      );
      return;
    }

    final notifier = ref.read(routinesProvider.notifier);
    final now = DateTime.now();
    final routine = Routine(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      focusLevel: _focusLevel.round(),
      estimatedTime: _estimatedMinutes,
      status: RoutineStatus.todo,
      createdAt: now,
    );

    notifier.addRoutine(routine);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: bottomInset + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const Text(
              '새 루틴 추가',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '설명 (선택)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '집중 레벨',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _focusLevel,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _focusLevel.round().toString(),
                    onChanged: (v) => setState(() => _focusLevel = v),
                  ),
                ),
                Text('Lv.${_focusLevel.round()}'),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '예상 시간(분)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _estimatedMinutes.toDouble(),
                    min: 5,
                    max: 120,
                    divisions: 23,
                    label: '$_estimatedMinutes분',
                    onChanged: (v) =>
                        setState(() => _estimatedMinutes = v.round()),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    '$_estimatedMinutes분',
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '추가하기',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
