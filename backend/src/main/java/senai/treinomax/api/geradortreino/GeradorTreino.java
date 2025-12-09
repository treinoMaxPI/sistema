package senai.treinomax.api.geradortreino;

import java.util.Collection;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import lombok.AllArgsConstructor;
import lombok.RequiredArgsConstructor;
import senai.treinomax.api.auth.model.Exercicio;
import senai.treinomax.api.auth.model.GrupoMuscular;
import senai.treinomax.api.repository.ExercicioRepository;

@Service
@RequiredArgsConstructor
public class GeradorTreino {

    private final ExercicioRepository exercicioRepository;

    private CalculadoraTreinos calculadora = new CalculadoraTreinos();

    public List<UUID> gerarTreino(List<GrupoMuscular> gruposMusculares) {
        List<Exercicio> exercicios = exercicioRepository.findAll();

        List<Exercicio> melhorCombinacao = calculadora.encontrarMelhorCombinacao(exercicios, gruposMusculares, 5);

        return melhorCombinacao.stream().map(Exercicio::getId).toList();
    }
}
