import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/routine_provider.dart';
import 'screens/home_screen.dart';
import 'screens/list_screen.dart';
import 'screens/kanban_screen.dart';
import 'screens/stats_screen.dart';

void main() {
  runApp(const ProviderScope(child: FocusFlowApp()));
}

class FocusFlowApp extends StatefulWidget {
  const FocusFlowApp({super.key});

  @override
  State<FocusFlowApp> createState() => _FocusFlowAppState();
}

class _FocusFlowAppState extends State<FocusFlowApp> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      HomeScreen(),
      ListScreen(),
      KanbanScreen(),
      StatsScreen(),
    ];
    return MaterialApp(
      title: 'FocusFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FocusFlow Routine Manager'),
        ),
        body: pages[_tab],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: '홈'),
            NavigationDestination(icon: Icon(Icons.view_list_outlined), label: '리스트'),
            NavigationDestination(icon: Icon(Icons.view_kanban_outlined), label: '칸반'),
            NavigationDestination(icon: Icon(Icons.query_stats_outlined), label: '통계'),
          ],
          onDestinationSelected: (i) => setState(() => _tab = i),
        ),
        floatingActionButton: _tab == 0 || _tab == 1
            ? const _AddRoutineFab()
            : null,
      ),
    );
  }
}

class _AddRoutineFab extends ConsumerWidget {
  const _AddRoutineFab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () async {
        final controller = TextEditingController();
        int focus = 3;
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('루틴 추가'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: '제목'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('집중도'),
                    Expanded(
                      child: Slider(
                        min: 1,
                        max: 5,
                        divisions: 4,
                        value: focus.toDouble(),
                        label: focus.toString(),
                        onChanged: (v) {
                          focus = v.toInt();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('저장')),
            ],
          ),
        );
        if (ok == true && controller.text.trim().isNotEmpty) {
          ref.read(routineListProvider.notifier).addRoutine(
            title: controller.text.trim(),
            focusLevel: focus,
          );
        }
      },
      icon: const Icon(Icons.add),
      label: const Text('루틴 추가'),
    );
  }
}
