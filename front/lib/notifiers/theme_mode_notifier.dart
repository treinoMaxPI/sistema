import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark);

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString('theme_mode');
    if (val == 'light') {
      state = ThemeMode.light;
    } else if (val == 'dark') {
      state = ThemeMode.dark;
    }
  }

  Future<void> _save(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode == ThemeMode.light ? 'light' : 'dark');
  }

  Future<void> setLight() async {
    state = ThemeMode.light;
    await _save(state);
  }

  Future<void> setDark() async {
    state = ThemeMode.dark;
    await _save(state);
  }
}