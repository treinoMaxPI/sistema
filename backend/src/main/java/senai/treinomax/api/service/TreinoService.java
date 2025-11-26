package senai.treinomax.api.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import senai.treinomax.api.auth.model.Exercicio;
import senai.treinomax.api.auth.model.ItemTreino;
import senai.treinomax.api.auth.model.Treino;
import senai.treinomax.api.auth.model.Usuario;
import senai.treinomax.api.auth.repository.UsuarioRepository;
import senai.treinomax.api.repository.ExercicioRepository;
import senai.treinomax.api.repository.TreinoRepository;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class TreinoService {

    private final TreinoRepository treinoRepository;
    private final UsuarioRepository usuarioRepository;
    private final ExercicioRepository exercicioRepository;

    @Transactional
    public Treino criarTreino(Treino treino, UUID usuarioId, List<Map<String, Object>> itensRequest) {
        Usuario usuario = usuarioRepository.findById(usuarioId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
        treino.setUsuario(usuario);

        // Processar itens do treino
        if (itensRequest != null && !itensRequest.isEmpty()) {
            List<ItemTreino> itens = new ArrayList<>();
            for (Map<String, Object> itemMap : itensRequest) {
                ItemTreino item = new ItemTreino();

                // Extrair exercício
                Object exercicioObj = itemMap.get("exercicio");
                UUID exercicioId;
                if (exercicioObj instanceof Map) {
                    exercicioId = UUID.fromString(((Map<?, ?>) exercicioObj).get("id").toString());
                } else {
                    exercicioId = UUID.fromString(exercicioObj.toString());
                }

                Exercicio exercicio = exercicioRepository.findById(exercicioId)
                        .orElseThrow(() -> new RuntimeException("Exercício não encontrado: " + exercicioId));
                item.setExercicio(exercicio);

                // Extrair outros campos
                item.setOrdem((Integer) itemMap.get("ordem"));
                item.setSeries((Integer) itemMap.get("series"));
                item.setRepeticoes((String) itemMap.get("repeticoes"));

                if (itemMap.get("tempoDescanso") != null) {
                    item.setTempoDescanso(itemMap.get("tempoDescanso").toString());
                }

                if (itemMap.get("observacao") != null) {
                    item.setObservacao(itemMap.get("observacao").toString());
                }

                item.setTreino(treino);
                itens.add(item);
            }
            treino.setItens(itens);
        }

        return treinoRepository.save(treino);
    }

    @Transactional(readOnly = true)
    public Treino buscarPorId(UUID id) {
        return treinoRepository.findById(id).orElse(null);
    }

    @Transactional(readOnly = true)
    public List<Treino> listarTodos() {
        return treinoRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<Treino> listarPorUsuario(UUID usuarioId) {
        return treinoRepository.findByUsuarioId(usuarioId);
    }

    public List<Usuario> listarUsuariosComTreinos() {
        return treinoRepository.findDistinctUsuariosWithTreinos();
    }

    @Transactional
    public Treino atualizarTreino(UUID id, Treino treinoAtualizado, List<Map<String, Object>> itensRequest) {
        return treinoRepository.findById(id)
                .map(treino -> {
                    treino.setNome(treinoAtualizado.getNome());
                    treino.setTipoTreino(treinoAtualizado.getTipoTreino());
                    treino.setDescricao(treinoAtualizado.getDescricao());
                    treino.setNivel(treinoAtualizado.getNivel());

                    // Processar novos itens
                    if (itensRequest != null && !itensRequest.isEmpty()) {
                        // Limpar itens existentes (orphanRemoval cuidará da remoção)
                        treino.getItens().clear();

                        List<ItemTreino> novosItens = new ArrayList<>();
                        for (Map<String, Object> itemMap : itensRequest) {
                            // Sempre criar novo item (orphanRemoval remove os antigos)
                            ItemTreino item = new ItemTreino();

                            // Extrair exercício
                            Object exercicioObj = itemMap.get("exercicio");
                            UUID exercicioId;
                            if (exercicioObj instanceof Map) {
                                exercicioId = UUID.fromString(((Map<?, ?>) exercicioObj).get("id").toString());
                            } else {
                                exercicioId = UUID.fromString(exercicioObj.toString());
                            }

                            Exercicio exercicio = exercicioRepository.findById(exercicioId)
                                    .orElseThrow(
                                            () -> new RuntimeException("Exercício não encontrado: " + exercicioId));
                            item.setExercicio(exercicio);

                            // Extrair outros campos
                            item.setOrdem((Integer) itemMap.get("ordem"));
                            item.setSeries((Integer) itemMap.get("series"));
                            item.setRepeticoes((String) itemMap.get("repeticoes"));

                            if (itemMap.get("tempoDescanso") != null) {
                                item.setTempoDescanso(itemMap.get("tempoDescanso").toString());
                            } else {
                                item.setTempoDescanso(null);
                            }

                            if (itemMap.get("observacao") != null) {
                                item.setObservacao(itemMap.get("observacao").toString());
                            } else {
                                item.setObservacao(null);
                            }

                            item.setTreino(treino);
                            novosItens.add(item);
                        }
                        treino.setItens(novosItens);
                    }

                    return treinoRepository.save(treino);
                })
                .orElse(null);
    }

    @Transactional
    public boolean deletarTreino(UUID id) {
        if (treinoRepository.existsById(id)) {
            treinoRepository.deleteById(id);
            return true;
        }
        return false;
    }
}
