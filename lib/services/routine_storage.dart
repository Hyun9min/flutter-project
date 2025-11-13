import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/routine.dart';

class RoutineStorage implements RoutinePersistence {
  RoutineStorage(this._prefs);

  static const _key = 'focusflow_routines_v1';

  final SharedPreferences _prefs;

  @override
  Future<List<Routine>> load() async {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return const <Routine>[];
    }

    try {
      final data = jsonDecode(raw) as List<dynamic>;
      return data
          .map((item) =>
              Routine.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const <Routine>[];
    }
  }

  @override
  Future<void> save(List<Routine> routines) async {
    final encoded =
        jsonEncode(routines.map((r) => r.toJson()).toList());
    await _prefs.setString(_key, encoded);
  }
}
