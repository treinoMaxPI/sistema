import * as treino from './treino';

const calcularNota = (
    requisitos: treino.GrupoMuscular[],
    candidato: treino.Exercicio[]
): number => {
    const pesosPorGrupo = requisitos.map(() => 1);
    const somaPesos = pesosPorGrupo.reduce((sum, p) => sum + p, 0);
    
    const notasPorGrupo = requisitos.map(grupoRequisito => {
        const musculosDoGrupo = treino.GruposMusculares[grupoRequisito];
        let somaLogQualidade = 0;
        
        candidato.forEach(exercicio => {
            const ativacoes = treino.Exercicios[exercicio];
            let qualidadeExercicio = 0;
            
            musculosDoGrupo.forEach(musculo => {
                if (ativacoes[musculo]) {
                    qualidadeExercicio += ativacoes[musculo];
                }
            });
            
            if (qualidadeExercicio > 0) {
                const qualidadeNormalizada = 1 + (qualidadeExercicio * 9);
                somaLogQualidade += Math.log2(qualidadeNormalizada);
            }
        });
        
        return somaLogQualidade;
    });
    
    let produtoPonderado = 1;
    notasPorGrupo.forEach((nota, index) => {
        const peso = pesosPorGrupo[index];
        produtoPonderado *= Math.pow(nota, peso);
    });
    
    const notaFinal = Math.pow(produtoPonderado, 1 / somaPesos);
    return notaFinal;
}

for (const [key, value] of Object.entries(treino.RequisitoTreino)) {
  console.log(`\n${'='.repeat(80)}`);
  console.log(`  TREINO ${key.toUpperCase()}`);
  console.log(`  Requisitos: ${value.requisitos.join(', ')}`);
  console.log(`  Exercícios necessários: ${value.num_exercicios}`);
  console.log(`${'='.repeat(80)}\n`);
  
  const candidatos = value.candidatos;
  
  for (let i = 0; i < candidatos.length; i++) {
    const candidato = candidatos[i];
    const nota = calcularNota(value.requisitos, candidato.conteudo);
    
    // Determina o status visual baseado na nota
    const status = nota >= 0.8 ? '✅' : nota >= 0.5 ? '⚠️' : '❌';
    const notaFormatada = (nota * 100).toFixed(1);
    
    console.log(`${i + 1}. ${status} ${candidato.nome}`);
    console.log(`   Nota: ${notaFormatada}`);
    console.log(`   ${candidato.conteudo.join(' → ')}`);
    console.log();
  }
  
  console.log(`${'-'.repeat(80)}\n`);
}
