import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/routine.dart';
import 'services/routine_storage.dart';
import 'views/home_view.dart';
import 'views/routine_list_view.dart';
import 'views/statistics_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storage = RoutineStorage(prefs);

  runApp(
    ProviderScope(
      overrides: [
        routinePersistenceProvider.overrideWithValue(storage),
      ],
      child: const FocusFlowApp(),
    ),
  );
}

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6366F1); // 메인 컬러

    return MaterialApp(
      title: 'FocusFlow',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FB),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
      ),
      home: const MainScaffold(),
    );
  }
}

// 하단 네비게이션 바(홈/루틴/통계)
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      HomeView(),
      RoutineListView(),
      StatisticsView(),
    ];

    return PopScope(
      // 뒤로가기를 눌렀을 때 동작 제어
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: pages[_currentIndex],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            // 탭을 눌렀을 때 현재 인덱스를 변경
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: const Color(0xFF6366F1),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.view_list_outlined),
                label: '루틴',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                label: '통계',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
