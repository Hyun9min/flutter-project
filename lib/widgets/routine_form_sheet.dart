import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/routine.dart';

class RoutineFormSheet extends ConsumerStatefulWidget {
  const RoutineFormSheet({super.key, this.initialRoutine});

  final Routine? initialRoutine;

  @override
  ConsumerState<RoutineFormSheet> createState() => _RoutineFormSheetState();
}

class _RoutineFormSheetState extends ConsumerState<RoutineFormSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  double _focusLevel = 3;
  int _estimatedMinutes = 25;
  String? _errorMessage;
  bool get _isEditing => widget.initialRoutine != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRoutine;
    if (initial != null) {
      _titleController.text = initial.title;
      _descriptionController.text = initial.description ?? '';
      _focusLevel = initial.focusLevel.toDouble();
      _estimatedMinutes = initial.estimatedTime;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // 폼을 제출할 때 호출되는 메서드
  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해 주세요.')),
      );
      return;
    }

    final notifier = ref.read(routinesProvider.notifier);
    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();

    if (_isEditing) {
      // 수정 모드
      final updated = widget.initialRoutine!.copyWith(
        title: title,
        description: description,
        focusLevel: _focusLevel.round(),
        estimatedTime: _estimatedMinutes,
      );
      notifier.updateRoutine(updated);
    } else {
      // 추가 모드 (중복 체크)
      final now = DateTime.now();
      final routine = Routine(
        id: now.millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        focusLevel: _focusLevel.round(),
        estimatedTime: _estimatedMinutes,
        status: RoutineStatus.todo,
        createdAt: now,
        accumulatedSeconds: 0,
      );
      final added = notifier.addRoutine(routine);

      // 이미 있는 제목이면 추가 실패 + 안내
      if (!added) {
        setState(() {
          _errorMessage = '이미 같은 이름의 루틴이 있어요. 다른 이름으로 만들어 주세요.';
        });
        return; // 닫지 않고 폼 그대로 유지
      }
    }

    // 성공했으면 에러 메시지 초기화하고 닫기
    setState(() {
      _errorMessage = null;
    });
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
            Text(
              _isEditing ? '루틴 수정' : '새 루틴 추가',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            // 제목 입력
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
                errorText: _errorMessage,
              ),
            ),
            const SizedBox(height: 12),
            // 설명 입력 (선택 사항)
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '설명 (선택)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // 집중도 레벨 슬라이더
            const Text(
              '집중도 레벨',
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
            // 예상 시간(분 단위) 슬라이더
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
                  width: 52,
                  child: Text(
                    '$_estimatedMinutes분',
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 제출 버튼 (추가/수정 공용)
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
                child: Text(
                  _isEditing ? '수정하기' : '추가하기',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
