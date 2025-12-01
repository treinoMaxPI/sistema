/// Enum correspondente ao GrupoMuscular do backend
/// Mantém a mesma ordem e valores do enum Java
/// Backend: PEITO, OMBRO, BRAÇO, COSTAS, PERNA, GLUTEOS, TRICEPS, BICEPS, ABDOMEN
/// Nota: Usa BRACO (sem Ç) no identificador, mas retorna "BRAÇO" no value para compatibilidade
enum GrupoMuscular {
  PEITO,
  OMBRO,
  BRACO, // Identificador ASCII, mas value retorna "BRAÇO"
  COSTAS,
  PERNA,
  GLUTEOS,
  TRICEPS,
  BICEPS,
  ABDOMEN;

  /// Retorna o valor correto para o backend (com caracteres especiais)
  String get value {
    switch (this) {
      case GrupoMuscular.BRACO:
        return 'BRAÇO';
      default:
        return name;
    }
  }

  /// Lista todos os valores do enum
  static List<GrupoMuscular> get all => GrupoMuscular.values;

  /// Lista todos os valores como strings (com caracteres especiais corretos)
  static List<String> get allAsString => 
      GrupoMuscular.values.map((e) => e.value).toList();

  /// Converte string para enum (aceita tanto "BRAÇO" quanto "BRACO")
  static GrupoMuscular? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final upperValue = value.toUpperCase();
    // Mapeamento especial para BRAÇO
    if (upperValue == 'BRAÇO' || upperValue == 'BRACO') {
      return GrupoMuscular.BRACO;
    }
    
    try {
      return GrupoMuscular.values.firstWhere(
        (e) => e.name == upperValue,
        orElse: () => throw StateError('Value not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Converte lista de strings para lista de enums
  static List<GrupoMuscular> fromStringList(List<String>? values) {
    if (values == null || values.isEmpty) return [];
    return values
        .map((v) => GrupoMuscular.fromString(v))
        .whereType<GrupoMuscular>()
        .toList();
  }
}

