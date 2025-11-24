import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TextScale { small, normal, large }

final textScaleProvider = StateNotifierProvider<TextScaleNotifier, TextScale>((ref) {
  return TextScaleNotifier();
});

class TextScaleNotifier extends StateNotifier<TextScale> {
  TextScaleNotifier() : super(TextScale.normal);

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString('text_scale');
    if (val == 'small') {
      state = TextScale.small;
    } else if (val == 'large') {
      state = TextScale.large;
    } else {
      state = TextScale.normal;
    }
  }

  Future<void> _save(TextScale scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('text_scale', scale.name);
  }

  Future<void> setSmall() async {
    state = TextScale.small;
    await _save(state);
  }

  Future<void> setNormal() async {
    state = TextScale.normal;
    await _save(state);
  }

  Future<void> setLarge() async {
    state = TextScale.large;
    await _save(state);
  }
  // Tamanho do texto
  double factor() {
    switch (state) {
      case TextScale.small:
        return 0.8;
      case TextScale.normal:
        return 1.0;
      case TextScale.large:
        return 1.25;
    }
  }
}