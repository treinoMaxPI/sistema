enum GrupoMuscular {
  PEITO,
  OMBRO,
  COSTAS,
  PERNA,
  GLUTEOS,
  TRICEPS,
  BICEPS,
  ABDOMEN;

  String get value {
    return name;
  }

  static List<GrupoMuscular> get all => GrupoMuscular.values;

  static List<String> get allAsString =>
      GrupoMuscular.values.map((e) => e.value).toList();

  static GrupoMuscular? fromString(String? value) {
    if (value == null || value.isEmpty) return null;

    final upperValue = value.toUpperCase();
    try {
      return GrupoMuscular.values.firstWhere(
        (e) => e.name == upperValue,
        orElse: () => throw StateError('Value not found'),
      );
    } catch (e) {
      return null;
    }
  }

  static List<GrupoMuscular> fromStringList(List<String>? values) {
    if (values == null || values.isEmpty) return [];
    return values
        .map((v) => GrupoMuscular.fromString(v))
        .whereType<GrupoMuscular>()
        .toList();
  }
}
