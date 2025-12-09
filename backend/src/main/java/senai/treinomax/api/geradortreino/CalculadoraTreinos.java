package senai.treinomax.api.geradortreino;

import senai.treinomax.api.auth.model.AtivacaoMuscular;
import senai.treinomax.api.auth.model.Exercicio;
import senai.treinomax.api.auth.model.GrupoMuscular;

import java.util.*;
import java.util.stream.Collectors;

public class CalculadoraTreinos {

    public double calcularNota(
            List<GrupoMuscular> requisitos,
            List<Exercicio> treinoCandidato) {
        List<Double> pesosPorGrupo = requisitos.stream()
                .map(req -> 1.0)
                .collect(Collectors.toList());

        double somaPesos = pesosPorGrupo.stream().mapToDouble(Double::doubleValue).sum();
        List<Double> notasPorGrupo = new ArrayList<>();

        for (GrupoMuscular grupoRequisito : requisitos) {
            double somaLogQualidade = 0.0;

            for (Exercicio exercicio : treinoCandidato) {
                double qualidadeExercicioParaGrupo = 0.0;
                for (AtivacaoMuscular ativacao : exercicio.getAtivacaoMuscular()) {
                    if (ativacao.getGrupoMuscular() == grupoRequisito) {
                        qualidadeExercicioParaGrupo += Math.max(0, ativacao.getPeso() != null ? ativacao.getPeso() : 0);
                    }
                }

                if (qualidadeExercicioParaGrupo > 0) {
                    double qualidadeNormalizada = 1.0 + (qualidadeExercicioParaGrupo * 9.0);
                    somaLogQualidade += Math.log(qualidadeNormalizada) / Math.log(2.0);
                }
            }
            notasPorGrupo.add(somaLogQualidade);
        }

        double produtoPonderado = 1.0;
        for (int i = 0; i < notasPorGrupo.size(); i++) {
            double nota = notasPorGrupo.get(i);
            double peso = pesosPorGrupo.get(i);

            if (nota <= 0) {
                return 0.0;
            }

            produtoPonderado *= Math.pow(nota, peso);
        }

        return Math.pow(produtoPonderado, 1.0 / somaPesos);
    }

    public List<Exercicio> encontrarMelhorCombinacao(
            List<Exercicio> todos,
            List<GrupoMuscular> requisitos,
            int numero_exercicios
    ) {

        if (numero_exercicios <= 0 || numero_exercicios > todos.size()) return Collections.emptyList();

        MelhorTreino melhor = new MelhorTreino();

        gerarCombinacoes(todos, requisitos, numero_exercicios, 0, new ArrayList<>(), melhor);

        return melhor.combinacao;
    }

    private void gerarCombinacoes(
            List<Exercicio> todos,
            List<GrupoMuscular> requisitos,
            int k,
            int start,
            List<Exercicio> atual,
            MelhorTreino melhor
    ) {

        if (atual.size() == k) {
            double nota = calcularNota(requisitos, atual);
            if (nota > melhor.nota) {
                melhor.nota = nota;
                melhor.combinacao = new ArrayList<>(atual);
            }
            return;
        }

        for (int i = start; i < todos.size(); i++) {
            atual.add(todos.get(i));
            gerarCombinacoes(todos, requisitos, k, i + 1, atual, melhor);
            atual.remove(atual.size() - 1);
        }
    }

    private static class MelhorTreino {
        double nota = -1.0;
        List<Exercicio> combinacao = Collections.emptyList();
    }
}
