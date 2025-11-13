import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/routine.dart';

class RoutineFormSheet extends ConsumerStatefulWidget {
  const RoutineFormSheet({super.key, this.initialRoutine});

  final Routine? initialRoutine;

  @override
  ConsumerState<RoutineFormSheet> createState() =>
      _RoutineFormSheetState();
}

class _RoutineFormSheetState
    extends ConsumerState<RoutineFormSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  double _focusLevel = 3;
  int _estimatedMinutes = 25;

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

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('\uC81C\uBAA9\uC744 \uC785\uB825\uD574 \uC8FC\uC138\uC694.')),
      );
      return;
    }

    final notifier = ref.read(routinesProvider.notifier);
    final description =
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim();

    if (_isEditing) {
      final updated = widget.initialRoutine!.copyWith(
        title: title,
        description: description,
        focusLevel: _focusLevel.round(),
        estimatedTime: _estimatedMinutes,
      );
      notifier.updateRoutine(updated);
    } else {
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
      notifier.addRoutine(routine);
    }

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
              _isEditing ? '\uB8E8\uD2F4 \uC218\uC815' : '\uC0C8 \uB8E8\uD2F4 \uCD94\uAC00',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '\uC81C\uBAA9',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '\uC124\uBA85 (\uC120\uD0DD)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '\uC9E7\uC740 \uC911\uC810 \uB808\uBCA8',
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
              '\uC608\uC0C1 \uC2DC\uAC04(\uBD84)',
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
                    label: '$_estimatedMinutes\uBD84',
                    onChanged: (v) =>
                        setState(() => _estimatedMinutes = v.round()),
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Text(
                    '$_estimatedMinutes\uBD84',
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
                child: Text(
                  _isEditing ? '\uC218\uC815\uD558\uAE30' : '\uCD94\uAC00\uD558\uAE30',
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
