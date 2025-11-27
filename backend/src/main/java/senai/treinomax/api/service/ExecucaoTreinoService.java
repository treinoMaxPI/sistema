package senai.treinomax.api.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import senai.treinomax.api.auth.model.ExecucaoTreino;
import senai.treinomax.api.auth.model.Treino;
import senai.treinomax.api.auth.model.Usuario;
import senai.treinomax.api.auth.repository.UsuarioRepository;
import senai.treinomax.api.repository.ExecucaoTreinoRepository;
import senai.treinomax.api.repository.TreinoRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class ExecucaoTreinoService {

    private final ExecucaoTreinoRepository execucaoTreinoRepository;
    private final TreinoRepository treinoRepository;
    private final UsuarioRepository usuarioRepository;

    @Transactional
    public ExecucaoTreino iniciarTreino(UUID treinoId, UUID usuarioId) {
        // Verificar se o treino existe
        Treino treino = treinoRepository.findById(treinoId)
                .orElseThrow(() -> new RuntimeException("Treino não encontrado"));

        // Verificar se o usuário existe
        Usuario usuario = usuarioRepository.findById(usuarioId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        // Verificar se já existe uma execução ativa para este treino
        Optional<ExecucaoTreino> execucaoAtiva = execucaoTreinoRepository
                .findExecucaoAtivaByUsuarioAndTreino(usuarioId, treinoId);

        ExecucaoTreino execucao;
        if (execucaoAtiva.isPresent()) {
            // Retornar a execução existente
            execucao = execucaoAtiva.get();
        } else {
            // Criar nova execução
            execucao = new ExecucaoTreino();
            execucao.setTreino(treino);
            execucao.setUsuario(usuario);
            execucao.setFinalizada(false);
            execucao = execucaoTreinoRepository.save(execucao);
        }

        // Atualizar último treino do usuário
        usuario.setUltimoTreino(treino);
        usuarioRepository.save(usuario);

        return execucao;
    }

    @Transactional
    public ExecucaoTreino finalizarTreino(UUID execucaoId, UUID usuarioId) {
        // Buscar execução com relacionamentos carregados (EntityGraph)
        ExecucaoTreino execucao = execucaoTreinoRepository.findByIdWithRelations(execucaoId)
                .orElseThrow(() -> new RuntimeException("Execução não encontrada"));

        // Verificar se a execução pertence ao usuário
        if (execucao.getUsuario() == null || !execucao.getUsuario().getId().equals(usuarioId)) {
            throw new RuntimeException("Execução não pertence ao usuário");
        }

        // Verificar se já está finalizada
        if (execucao.getFinalizada()) {
            return execucao;
        }

        // Finalizar a execução
        execucao.finalizar();
        execucao = execucaoTreinoRepository.save(execucao);

        // Limpar último treino do usuário (já que foi finalizado)
        // Recarregar usuário para garantir que temos a versão mais recente
        Usuario usuario = usuarioRepository.findById(usuarioId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
        
        if (usuario.getUltimoTreino() != null && 
            execucao.getTreino() != null &&
            usuario.getUltimoTreino().getId().equals(execucao.getTreino().getId())) {
            usuario.setUltimoTreino(null);
            usuarioRepository.save(usuario);
        }

        return execucao;
    }

    @Transactional(readOnly = true)
    public Optional<ExecucaoTreino> buscarExecucaoAtiva(UUID usuarioId) {
        List<ExecucaoTreino> execucoes = execucaoTreinoRepository.findByUsuarioIdAndFinalizadaFalseOrderByDataInicioDesc(usuarioId);
        // Retorna a primeira execução (mais recente) ou Optional.empty() se não houver
        return execucoes.isEmpty() ? Optional.empty() : Optional.of(execucoes.get(0));
    }

    @Transactional(readOnly = true)
    public List<ExecucaoTreino> listarHistorico(UUID usuarioId) {
        return execucaoTreinoRepository.findByUsuarioIdAndFinalizadaTrueOrderByDataFimDesc(usuarioId);
    }

    @Transactional(readOnly = true)
    public ExecucaoTreino buscarPorId(UUID id) {
        return execucaoTreinoRepository.findById(id).orElse(null);
    }
}

