package senai.treinomax.api.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import senai.treinomax.api.auth.model.Exercicio;
import senai.treinomax.api.repository.ExercicioRepository;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class ExercicioService {

    private final ExercicioRepository exercicioRepository;

    @Transactional
    public Exercicio criarExercicio(Exercicio exercicio) {
        return exercicioRepository.save(exercicio);
    }

    public Exercicio buscarPorId(UUID id) {
        return exercicioRepository.findById(id).orElse(null);
    }

    public List<Exercicio> listarTodos() {
        return exercicioRepository.findAll();
    }

    @Transactional
    public Exercicio atualizarExercicio(UUID id, Exercicio exercicioAtualizado) {
        return exercicioRepository.findById(id)
                .map(exercicio -> {
                    exercicio.setNome(exercicioAtualizado.getNome());
                    exercicio.setDescricao(exercicioAtualizado.getDescricao());
                    exercicio.setAtivacaoMuscular(exercicioAtualizado.getAtivacaoMuscular());
                    return exercicioRepository.save(exercicio);
                })
                .orElse(null);
    }

    @Transactional
    public boolean deletarExercicio(UUID id) {
        if (exercicioRepository.existsById(id)) {
            exercicioRepository.deleteById(id);
            return true;
        }
        return false;
    }
}