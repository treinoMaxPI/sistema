// Enums para grupos musculares específicos
enum GrupoPeitoral {
  SuperiorPeito = 'superior-peito',
  MeioPeito = 'meio-peito',
  InferiorPeito = 'inferior-peito'
}

enum GrupoCostas {
  DorsalSuperior = 'dorsal-superior',
  DorsalMedio = 'dorsal-medio',
  DorsalInferior = 'dorsal-inferior',
  Lombar = 'lombar'
}

enum GrupoOmbros {
  DeltoideAnterior = 'deltoide-anterior',
  DeltoideLateral = 'deltoide-lateral',
  DeltoidePosterior = 'deltoide-posterior'
}

enum GrupoBiceps {
  BicepsCabecaCurta = 'biceps-cabeca-curta',
  BicepsCabecaLonga = 'biceps-cabeca-longa'
}

enum GrupoTriceps {
  TricepsCabecaLonga = 'triceps-cabeca-longa',
  TricepsCabecaLateral = 'triceps-cabeca-lateral',
  TricepsCabecaMedial = 'triceps-cabeca-medial'
}

enum GrupoAntebraccos {
  FlexoresAntebraco = 'flexores-antebraco',
  ExtensoresAntebraco = 'extensores-antebraco'
}

enum GrupoQuadriceps {
  RetoFemoral = 'reto-femoral',
  VastoLateral = 'vasto-lateral',
  VastoMedial = 'vasto-medial',
  VastoIntermedio = 'vasto-intermedio'
}

enum GrupoPosterioresCoxa {
  BicepsFemoral = 'biceps-femoral',
  Semitendinoso = 'semitendinoso',
  Semimembranoso = 'semimembranoso'
}

enum GrupoGluteos {
  GluteoMaximo = 'gluteo-maximo',
  GluteoMedio = 'gluteo-medio',
  GluteoMinimo = 'gluteo-minimo'
}

enum GrupoPanturrilhas {
  Gastrocnemio = 'gastrocnemio',
  Soleo = 'soleo'
}

enum GrupoAbdomen {
  RetoAbdominal = 'reto-abdominal',
  ObliquoExterno = 'obliquo-externo',
  ObliquoInterno = 'obliquo-interno',
  Transverso = 'transverso'
}

enum GrupoCore {
  CoreAnterior = 'core-anterior',
  CoreLateral = 'core-lateral',
  CorePosterior = 'core-posterior'
}

// Enum principal para categorias de grupos musculares
enum GrupoMuscular {
  Peitoral = 'Peitoral',
  Costas = 'Costas',
  Ombros = 'Ombros',
  Biceps = 'Bíceps',
  Triceps = 'Tríceps',
  Antebraccos = 'Antebraços',
  Quadriceps = 'Quadríceps',
  PosterioresCoxa = 'Posteriores de Coxa',
  Gluteos = 'Glúteos',
  Panturrilhas = 'Panturrilhas',
  Abdomen = 'Abdômen',
  Core = 'Core'
}

// Enum para exercícios
enum Exercicio {
  // Peitoral
  SupinoReto = 'Supino Reto',
  SupinoInclinado = 'Supino Inclinado',
  SupinoDeclinado = 'Supino Declinado',
  Crucifixo = 'Crucifixo',
  Flexao = 'Flexão',
  
  // Costas
  BarraFixa = 'Barra Fixa',
  RemadaCurvada = 'Remada Curvada',
  PuxadaFrontal = 'Puxada Frontal',
  RemadaBaixa = 'Remada Baixa',
  LevantamentoTerra = 'Levantamento Terra',
  
  // Ombros
  Desenvolvimento = 'Desenvolvimento',
  ElevacaoLateral = 'Elevação Lateral',
  ElevacaoFrontal = 'Elevação Frontal',
  CrucifixoInvertido = 'Crucifixo Invertido',
  
  // Bíceps
  RoscaDireta = 'Rosca Direta',
  RoscaAlternada = 'Rosca Alternada',
  RoscaMartelo = 'Rosca Martelo',
  RoscaScott = 'Rosca Scott',
  RoscaPunho = 'Rosca Punho',
  
  // Tríceps
  TricepsTesta = 'Tríceps Testa',
  TricepsPulley = 'Tríceps Pulley',
  Mergulho = 'Mergulho',
  TricepsFrances = 'Tríceps Francês',
  TricepsCorda = 'Tríceps Corda',
  
  // Pernas
  Agachamento = 'Agachamento',
  LegPress = 'Leg Press',
  CadeiraExtensora = 'Cadeira Extensora',
  MesaFlexora = 'Mesa Flexora',
  Stiff = 'Stiff',
  CadeiraAbdutora = 'Cadeira Abdutora',
  CadeiraAdutora = 'Cadeira Adutora',
  ElevacaoPelvica = 'Elevação Pélvica',
  
  // Panturrilha
  PanturrilhaEmPe = 'Panturrilha em Pé',
  PanturrilhaSentado = 'Panturrilha Sentado',
  
  // Abdômen
  Abdominal = 'Abdominal',
  Prancha = 'Prancha',
  AbdominalObliquo = 'Abdominal Oblíquo',
  AbdominalCanivete = 'Abdominal Canivete'
}

// Enum para tipos de treino
enum TipoTreino {
  A = 'A',
  B = 'B',
  C = 'C'
}

// Tipos auxiliares
type MuscleActivation = {
  [key: string]: number;
};

type GruposMusculares = {
  [key in GrupoMuscular]: string[];
};

type ExerciciosMap = {
  [key in Exercicio]: MuscleActivation;
};

type CandidatoTreino = {
  nome: string;
  conteudo: Exercicio[];
};

type RequisitoTreinoConfig = {
  requisitos: GrupoMuscular[];
  num_exercicios: number;
  candidatos: CandidatoTreino[];
};
type RequisitoTreinoMap = {
  [key in TipoTreino]: RequisitoTreinoConfig;
};

// Definição dos grupos musculares
const GruposMusculares: GruposMusculares = {
  [GrupoMuscular.Peitoral]: [
    GrupoPeitoral.SuperiorPeito,
    GrupoPeitoral.MeioPeito,
    GrupoPeitoral.InferiorPeito
  ],
  [GrupoMuscular.Costas]: [
    GrupoCostas.DorsalSuperior,
    GrupoCostas.DorsalMedio,
    GrupoCostas.DorsalInferior,
    GrupoCostas.Lombar
  ],
  [GrupoMuscular.Ombros]: [
    GrupoOmbros.DeltoideAnterior,
    GrupoOmbros.DeltoideLateral,
    GrupoOmbros.DeltoidePosterior
  ],
  [GrupoMuscular.Biceps]: [
    GrupoBiceps.BicepsCabecaCurta,
    GrupoBiceps.BicepsCabecaLonga
  ],
  [GrupoMuscular.Triceps]: [
    GrupoTriceps.TricepsCabecaLonga,
    GrupoTriceps.TricepsCabecaLateral,
    GrupoTriceps.TricepsCabecaMedial
  ],
  [GrupoMuscular.Antebraccos]: [
    GrupoAntebraccos.FlexoresAntebraco,
    GrupoAntebraccos.ExtensoresAntebraco
  ],
  [GrupoMuscular.Quadriceps]: [
    GrupoQuadriceps.RetoFemoral,
    GrupoQuadriceps.VastoLateral,
    GrupoQuadriceps.VastoMedial,
    GrupoQuadriceps.VastoIntermedio
  ],
  [GrupoMuscular.PosterioresCoxa]: [
    GrupoPosterioresCoxa.BicepsFemoral,
    GrupoPosterioresCoxa.Semitendinoso,
    GrupoPosterioresCoxa.Semimembranoso
  ],
  [GrupoMuscular.Gluteos]: [
    GrupoGluteos.GluteoMaximo,
    GrupoGluteos.GluteoMedio,
    GrupoGluteos.GluteoMinimo
  ],
  [GrupoMuscular.Panturrilhas]: [
    GrupoPanturrilhas.Gastrocnemio,
    GrupoPanturrilhas.Soleo
  ],
  [GrupoMuscular.Abdomen]: [
    GrupoAbdomen.RetoAbdominal,
    GrupoAbdomen.ObliquoExterno,
    GrupoAbdomen.ObliquoInterno,
    GrupoAbdomen.Transverso
  ],
  [GrupoMuscular.Core]: [
    GrupoCore.CoreAnterior,
    GrupoCore.CoreLateral,
    GrupoCore.CorePosterior
  ]
};

// Definição dos exercícios e ativação muscular
const Exercicios: ExerciciosMap = {
  // PEITORAL
  [Exercicio.SupinoReto]: {
    [GrupoPeitoral.MeioPeito]: 0.7,
    [GrupoPeitoral.SuperiorPeito]: 0.2,
    [GrupoPeitoral.InferiorPeito]: 0.1,
    [GrupoOmbros.DeltoideAnterior]: 0.3,
    [GrupoTriceps.TricepsCabecaLateral]: 0.4
  },
  [Exercicio.SupinoInclinado]: {
    [GrupoPeitoral.SuperiorPeito]: 0.7,
    [GrupoPeitoral.MeioPeito]: 0.3,
    [GrupoOmbros.DeltoideAnterior]: 0.4,
    [GrupoTriceps.TricepsCabecaLateral]: 0.3
  },
  [Exercicio.SupinoDeclinado]: {
    [GrupoPeitoral.InferiorPeito]: 0.7,
    [GrupoPeitoral.MeioPeito]: 0.3,
    [GrupoTriceps.TricepsCabecaLateral]: 0.4
  },
  [Exercicio.Crucifixo]: {
    [GrupoPeitoral.MeioPeito]: 0.6,
    [GrupoPeitoral.SuperiorPeito]: 0.2,
    [GrupoPeitoral.InferiorPeito]: 0.2
  },
  [Exercicio.Flexao]: {
    [GrupoPeitoral.MeioPeito]: 0.6,
    [GrupoPeitoral.InferiorPeito]: 0.2,
    [GrupoOmbros.DeltoideAnterior]: 0.3,
    [GrupoTriceps.TricepsCabecaLateral]: 0.4,
    [GrupoCore.CoreAnterior]: 0.3
  },

  // COSTAS
  [Exercicio.BarraFixa]: {
    [GrupoCostas.DorsalSuperior]: 0.7,
    [GrupoCostas.DorsalMedio]: 0.5,
    [GrupoBiceps.BicepsCabecaLonga]: 0.5,
    [GrupoOmbros.DeltoidePosterior]: 0.3
  },
  [Exercicio.RemadaCurvada]: {
    [GrupoCostas.DorsalMedio]: 0.7,
    [GrupoCostas.DorsalSuperior]: 0.4,
    [GrupoOmbros.DeltoidePosterior]: 0.4,
    [GrupoBiceps.BicepsCabecaLonga]: 0.3,
    [GrupoCostas.Lombar]: 0.3
  },
  [Exercicio.PuxadaFrontal]: {
    [GrupoCostas.DorsalSuperior]: 0.8,
    [GrupoCostas.DorsalMedio]: 0.4,
    [GrupoBiceps.BicepsCabecaLonga]: 0.4
  },
  [Exercicio.RemadaBaixa]: {
    [GrupoCostas.DorsalMedio]: 0.7,
    [GrupoCostas.DorsalInferior]: 0.4,
    [GrupoBiceps.BicepsCabecaCurta]: 0.3,
    [GrupoOmbros.DeltoidePosterior]: 0.3
  },
  [Exercicio.LevantamentoTerra]: {
    [GrupoCostas.Lombar]: 0.8,
    [GrupoGluteos.GluteoMaximo]: 0.7,
    [GrupoPosterioresCoxa.BicepsFemoral]: 0.6,
    [GrupoCostas.DorsalInferior]: 0.5,
    [GrupoCore.CorePosterior]: 0.6
  },

  // OMBROS
  [Exercicio.Desenvolvimento]: {
    [GrupoOmbros.DeltoideAnterior]: 0.6,
    [GrupoOmbros.DeltoideLateral]: 0.4,
    [GrupoTriceps.TricepsCabecaLateral]: 0.3,
    [GrupoPeitoral.SuperiorPeito]: 0.2
  },
  [Exercicio.ElevacaoLateral]: {
    [GrupoOmbros.DeltoideLateral]: 0.9,
    [GrupoOmbros.DeltoideAnterior]: 0.1
  },
  [Exercicio.ElevacaoFrontal]: {
    [GrupoOmbros.DeltoideAnterior]: 0.8,
    [GrupoPeitoral.SuperiorPeito]: 0.2
  },
  [Exercicio.CrucifixoInvertido]: {
    [GrupoOmbros.DeltoidePosterior]: 0.8,
    [GrupoCostas.DorsalSuperior]: 0.3
  },

  // BÍCEPS
  [Exercicio.RoscaDireta]: {
    [GrupoBiceps.BicepsCabecaCurta]: 0.7,
    [GrupoBiceps.BicepsCabecaLonga]: 0.5,
    [GrupoAntebraccos.FlexoresAntebraco]: 0.3
  },
  [Exercicio.RoscaAlternada]: {
    [GrupoBiceps.BicepsCabecaCurta]: 0.6,
    [GrupoBiceps.BicepsCabecaLonga]: 0.6,
    [GrupoAntebraccos.FlexoresAntebraco]: 0.3
  },
  [Exercicio.RoscaMartelo]: {
    [GrupoBiceps.BicepsCabecaLonga]: 0.7,
    [GrupoAntebraccos.FlexoresAntebraco]: 0.5
  },
  [Exercicio.RoscaScott]: {
    [GrupoBiceps.BicepsCabecaCurta]: 0.8,
    [GrupoBiceps.BicepsCabecaLonga]: 0.4
  },
  [Exercicio.RoscaPunho]: {
    [GrupoAntebraccos.FlexoresAntebraco]: 0.9,
    [GrupoAntebraccos.ExtensoresAntebraco]: 0.2
  },

  // TRÍCEPS
  [Exercicio.TricepsTesta]: {
    [GrupoTriceps.TricepsCabecaLonga]: 0.8,
    [GrupoTriceps.TricepsCabecaLateral]: 0.4
  },
  [Exercicio.TricepsPulley]: {
    [GrupoTriceps.TricepsCabecaLateral]: 0.7,
    [GrupoTriceps.TricepsCabecaMedial]: 0.5
  },
  [Exercicio.Mergulho]: {
    [GrupoTriceps.TricepsCabecaLateral]: 0.7,
    [GrupoTriceps.TricepsCabecaLonga]: 0.5,
    [GrupoPeitoral.InferiorPeito]: 0.4,
    [GrupoOmbros.DeltoideAnterior]: 0.3
  },
  [Exercicio.TricepsFrances]: {
    [GrupoTriceps.TricepsCabecaLonga]: 0.9,
    [GrupoTriceps.TricepsCabecaLateral]: 0.3
  },
  [Exercicio.TricepsCorda]: {
    [GrupoTriceps.TricepsCabecaLateral]: 0.8,
    [GrupoTriceps.TricepsCabecaMedial]: 0.6,
    [GrupoTriceps.TricepsCabecaLonga]: 0.3
  },

  // PERNAS
  [Exercicio.Agachamento]: {
    [GrupoQuadriceps.RetoFemoral]: 0.7,
    [GrupoQuadriceps.VastoLateral]: 0.7,
    [GrupoQuadriceps.VastoMedial]: 0.7,
    [GrupoGluteos.GluteoMaximo]: 0.6,
    [GrupoCore.CoreAnterior]: 0.4
  },
  [Exercicio.LegPress]: {
    [GrupoQuadriceps.RetoFemoral]: 0.8,
    [GrupoQuadriceps.VastoLateral]: 0.8,
    [GrupoQuadriceps.VastoMedial]: 0.8,
    [GrupoGluteos.GluteoMaximo]: 0.5
  },
  [Exercicio.CadeiraExtensora]: {
    [GrupoQuadriceps.RetoFemoral]: 0.8,
    [GrupoQuadriceps.VastoLateral]: 0.7,
    [GrupoQuadriceps.VastoMedial]: 0.7,
    [GrupoQuadriceps.VastoIntermedio]: 0.6
  },
  [Exercicio.MesaFlexora]: {
    [GrupoPosterioresCoxa.BicepsFemoral]: 0.9,
    [GrupoPosterioresCoxa.Semitendinoso]: 0.7,
    [GrupoPosterioresCoxa.Semimembranoso]: 0.7
  },
  [Exercicio.Stiff]: {
    [GrupoPosterioresCoxa.BicepsFemoral]: 0.8,
    [GrupoPosterioresCoxa.Semitendinoso]: 0.7,
    [GrupoGluteos.GluteoMaximo]: 0.6,
    [GrupoCostas.Lombar]: 0.4
  },
  [Exercicio.CadeiraAbdutora]: {
    [GrupoGluteos.GluteoMedio]: 0.8,
    [GrupoGluteos.GluteoMinimo]: 0.6
  },
  [Exercicio.CadeiraAdutora]: {
    [GrupoQuadriceps.VastoMedial]: 0.5
  },
  [Exercicio.ElevacaoPelvica]: {
    [GrupoGluteos.GluteoMaximo]: 0.9,
    [GrupoPosterioresCoxa.BicepsFemoral]: 0.5
  },

  // PANTURRILHA
  [Exercicio.PanturrilhaEmPe]: {
    [GrupoPanturrilhas.Gastrocnemio]: 0.9,
    [GrupoPanturrilhas.Soleo]: 0.3
  },
  [Exercicio.PanturrilhaSentado]: {
    [GrupoPanturrilhas.Soleo]: 0.9,
    [GrupoPanturrilhas.Gastrocnemio]: 0.2
  },

  // ABDÔMEN
  [Exercicio.Abdominal]: {
    [GrupoAbdomen.RetoAbdominal]: 0.8,
    [GrupoAbdomen.ObliquoExterno]: 0.3
  },
  [Exercicio.Prancha]: {
    [GrupoAbdomen.RetoAbdominal]: 0.7,
    [GrupoAbdomen.Transverso]: 0.8,
    [GrupoCore.CoreAnterior]: 0.9
  },
  [Exercicio.AbdominalObliquo]: {
    [GrupoAbdomen.ObliquoExterno]: 0.8,
    [GrupoAbdomen.ObliquoInterno]: 0.7,
    [GrupoAbdomen.RetoAbdominal]: 0.4
  },
  [Exercicio.AbdominalCanivete]: {
    [GrupoAbdomen.RetoAbdominal]: 0.9,
    [GrupoCore.CoreAnterior]: 0.6
  }
};

// Definição dos requisitos de treino
const RequisitoTreino: RequisitoTreinoMap = {
  [TipoTreino.A]: {
    requisitos: [GrupoMuscular.Peitoral, GrupoMuscular.Ombros, GrupoMuscular.Triceps],
    num_exercicios: 5,
    candidatos: [
      {
        nome: 'Treino A - Push Completo',
        conteudo: [
          Exercicio.SupinoReto,
          Exercicio.SupinoInclinado,
          Exercicio.Desenvolvimento,
          Exercicio.ElevacaoLateral,
          Exercicio.TricepsTesta
        ]
      },
      {
        nome: 'Treino A - Sem Tríceps Isolado',
        conteudo: [
          Exercicio.SupinoReto,
          Exercicio.Crucifixo,
          Exercicio.Desenvolvimento,
          Exercicio.ElevacaoLateral,
          Exercicio.ElevacaoFrontal
        ]
      },
      {
        nome: 'Treino A - Push Balanceado',
        conteudo: [
          Exercicio.SupinoInclinado,
          Exercicio.Crucifixo,
          Exercicio.ElevacaoFrontal,
          Exercicio.CrucifixoInvertido,
          Exercicio.TricepsPulley
        ]
      },
      {
        nome: 'Treino A - Sem Peito',
        conteudo: [
          Exercicio.Desenvolvimento,
          Exercicio.ElevacaoLateral,
          Exercicio.ElevacaoFrontal,
          Exercicio.TricepsTesta,
          Exercicio.TricepsCorda
        ]
      },
      {
        nome: 'Treino A - Push Funcional',
        conteudo: [
          Exercicio.Flexao,
          Exercicio.SupinoReto,
          Exercicio.Desenvolvimento,
          Exercicio.ElevacaoLateral,
          Exercicio.Mergulho
        ]
      },
      {
        nome: 'Treino A - Sem Ombros',
        conteudo: [
          Exercicio.SupinoReto,
          Exercicio.SupinoDeclinado,
          Exercicio.Crucifixo,
          Exercicio.TricepsTesta,
          Exercicio.TricepsPulley
        ]
      },
      {
        nome: 'Treino A - Totalmente Errado (Pernas)',
        conteudo: [
          Exercicio.Agachamento,
          Exercicio.LegPress,
          Exercicio.MesaFlexora,
          Exercicio.CadeiraExtensora,
          Exercicio.PanturrilhaEmPe
        ]
      }
    ]
  },
  [TipoTreino.B]: {
    requisitos: [GrupoMuscular.Costas, GrupoMuscular.Biceps, GrupoMuscular.Antebraccos],
    num_exercicios: 5,
    candidatos: [
      {
        nome: 'Treino B - Pull Completo',
        conteudo: [
          Exercicio.BarraFixa,
          Exercicio.RemadaCurvada,
          Exercicio.PuxadaFrontal,
          Exercicio.RoscaDireta,
          Exercicio.RoscaMartelo
        ]
      },
      {
        nome: 'Treino B - Sem Antebraço',
        conteudo: [
          Exercicio.BarraFixa,
          Exercicio.RemadaCurvada,
          Exercicio.PuxadaFrontal,
          Exercicio.RoscaDireta,
          Exercicio.RoscaAlternada
        ]
      },
      {
        nome: 'Treino B - Pull com Terra',
        conteudo: [
          Exercicio.LevantamentoTerra,
          Exercicio.RemadaBaixa,
          Exercicio.BarraFixa,
          Exercicio.RoscaAlternada,
          Exercicio.RoscaScott
        ]
      },
      {
        nome: 'Treino B - Sem Costas',
        conteudo: [
          Exercicio.RoscaDireta,
          Exercicio.RoscaAlternada,
          Exercicio.RoscaScott,
          Exercicio.RoscaMartelo,
          Exercicio.RoscaPunho
        ]
      },
      {
        nome: 'Treino B - Pull Tradicional',
        conteudo: [
          Exercicio.PuxadaFrontal,
          Exercicio.RemadaCurvada,
          Exercicio.RemadaBaixa,
          Exercicio.RoscaMartelo,
          Exercicio.RoscaDireta
        ]
      },
      {
        nome: 'Treino B - Sem Bíceps Isolado',
        conteudo: [
          Exercicio.BarraFixa,
          Exercicio.RemadaCurvada,
          Exercicio.PuxadaFrontal,
          Exercicio.RemadaBaixa,
          Exercicio.RoscaMartelo
        ]
      },
      {
        nome: 'Treino B - Totalmente Errado (Push)',
        conteudo: [
          Exercicio.SupinoReto,
          Exercicio.Desenvolvimento,
          Exercicio.ElevacaoLateral,
          Exercicio.TricepsTesta,
          Exercicio.TricepsPulley
        ]
      }
    ]
  },
  [TipoTreino.C]: {
    requisitos: [
      GrupoMuscular.Quadriceps,
      GrupoMuscular.PosterioresCoxa,
      GrupoMuscular.Gluteos,
      GrupoMuscular.Panturrilhas,
      GrupoMuscular.Abdomen
    ],
    num_exercicios: 6,
    candidatos: [
      {
        nome: 'Treino C - Pernas Completo',
        conteudo: [
          Exercicio.Agachamento,
          Exercicio.LegPress,
          Exercicio.MesaFlexora,
          Exercicio.ElevacaoPelvica,
          Exercicio.PanturrilhaEmPe,
          Exercicio.Abdominal
        ]
      },
      {
        nome: 'Treino C - Sem Posteriores',
        conteudo: [
          Exercicio.Agachamento,
          Exercicio.LegPress,
          Exercicio.CadeiraExtensora,
          Exercicio.ElevacaoPelvica,
          Exercicio.PanturrilhaEmPe,
          Exercicio.Prancha
        ]
      },
      {
        nome: 'Treino C - Pernas Isolado',
        conteudo: [
          Exercicio.LegPress,
          Exercicio.CadeiraExtensora,
          Exercicio.Stiff,
          Exercicio.CadeiraAbdutora,
          Exercicio.PanturrilhaSentado,
          Exercicio.Prancha
        ]
      },
      {
        nome: 'Treino C - Sem Glúteos',
        conteudo: [
          Exercicio.Agachamento,
          Exercicio.LegPress,
          Exercicio.CadeiraExtensora,
          Exercicio.MesaFlexora,
          Exercicio.PanturrilhaEmPe,
          Exercicio.Abdominal
        ]
      },
      {
        nome: 'Treino C - Pernas e Core',
        conteudo: [
          Exercicio.Agachamento,
          Exercicio.CadeiraExtensora,
          Exercicio.Stiff,
          Exercicio.ElevacaoPelvica,
          Exercicio.PanturrilhaEmPe,
          Exercicio.AbdominalObliquo
        ]
      },
      {
        nome: 'Treino C - Sem Panturrilha',
        conteudo: [
          Exercicio.Agachamento,
          Exercicio.LegPress,
          Exercicio.MesaFlexora,
          Exercicio.ElevacaoPelvica,
          Exercicio.CadeiraAbdutora,
          Exercicio.Prancha
        ]
      },
      {
        nome: 'Treino C - Totalmente Errado (Pull)',
        conteudo: [
          Exercicio.BarraFixa,
          Exercicio.RemadaCurvada,
          Exercicio.PuxadaFrontal,
          Exercicio.RoscaDireta,
          Exercicio.RoscaMartelo,
          Exercicio.RemadaBaixa
        ]
      }
    ]
  }
};

export {
  GrupoMuscular,
  GrupoPeitoral,
  GrupoCostas,
  GrupoOmbros,
  GrupoBiceps,
  GrupoTriceps,
  GrupoAntebraccos,
  GrupoQuadriceps,
  GrupoPosterioresCoxa,
  GrupoGluteos,
  GrupoPanturrilhas,
  GrupoAbdomen,
  GrupoCore,
  Exercicio,
  TipoTreino,
  GruposMusculares,
  Exercicios,
  RequisitoTreino
};

export type {
  MuscleActivation,
  GruposMusculares as GruposMuscularesType,
  ExerciciosMap,
  RequisitoTreinoConfig,
  RequisitoTreinoMap
};