package senai.treinomax.api.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import senai.treinomax.api.auth.model.Usuario;
import senai.treinomax.api.auth.service.UsuarioService;
import senai.treinomax.api.dto.request.AtualizarPlanoRequest;
import senai.treinomax.api.dto.request.CriarPlanoRequest;
import senai.treinomax.api.model.Plano;
import senai.treinomax.api.repository.PlanoRepository;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class PlanoService {

    private final PlanoRepository planoRepository;
    private final UsuarioService usuarioService;

    @Transactional
    public Plano criarPlano(CriarPlanoRequest request, UUID criadoPorId) {
        log.info("Criando novo plano: {}", request.getNome());

        // Verificar se já existe plano com mesmo nome
        if (planoRepository.existsByNome(request.getNome())) {
            log.warn("Tentativa de criar plano com nome já existente: {}", request.getNome());
            throw new IllegalArgumentException("Já existe um plano com o nome: " + request.getNome());
        }

        // Buscar usuário criador
        Usuario criador = usuarioService.buscarPorId(criadoPorId);

        // Criar entidade Plano a partir do DTO
        Plano plano = new Plano();
        plano.setNome(request.getNome());
        plano.setDescricao(request.getDescricao());
        plano.setPrecoCentavos(request.getPrecoCentavos());
        plano.setAtivo(request.getAtivo());
        plano.setCriadoPor(criador);

        Plano planoSalvo = planoRepository.save(plano);
        log.info("Plano criado com sucesso: {} (ID: {})", planoSalvo.getNome(), planoSalvo.getId());

        return planoSalvo;
    }

    public List<Plano> listarPlanosAtivos() {
        log.debug("Listando planos ativos");
        return planoRepository.findByAtivoTrue();
    }

    public List<Plano> listarTodosPlanos() {
        log.debug("Listando todos os planos");
        return planoRepository.findAll();
    }

    public Plano buscarPorId(UUID id) {
        log.debug("Buscando plano por ID: {}", id);
        return planoRepository.findById(id)
                .orElseThrow(() -> {
                    log.warn("Plano não encontrado com ID: {}", id);
                    return new IllegalArgumentException("Plano não encontrado com ID: " + id);
                });
    }

    public Plano buscarPorNome(String nome) {
        log.debug("Buscando plano por nome: {}", nome);
        return planoRepository.findByNome(nome)
                .orElseThrow(() -> {
                    log.warn("Plano não encontrado com nome: {}", nome);
                    return new IllegalArgumentException("Plano não encontrado com nome: " + nome);
                });
    }

    public List<Plano> buscarPorCriador(UUID criadoPorId) {
        log.debug("Buscando planos criados por usuário: {}", criadoPorId);
        return planoRepository.findByCriadoPorId(criadoPorId);
    }

    public List<Plano> buscarPorFaixaPreco(Integer precoMin, Integer precoMax) {
        log.debug("Buscando planos por faixa de preço: {} a {}", precoMin, precoMax);
        return planoRepository.findByPrecoRange(precoMin, precoMax);
    }

    @Transactional
    public Plano atualizarPlano(UUID id, AtualizarPlanoRequest request) {
        log.info("Atualizando plano com ID: {}", id);

        Plano planoExistente = buscarPorId(id);

        // Verificar se o nome foi alterado e se já existe outro plano com o novo nome
        if (!planoExistente.getNome().equals(request.getNome()) &&
            planoRepository.existsByNome(request.getNome())) {
            log.warn("Tentativa de atualizar plano para nome já existente: {}", request.getNome());
            throw new IllegalArgumentException("Já existe um plano com o nome: " + request.getNome());
        }

        // Atualizar campos permitidos
        planoExistente.setNome(request.getNome());
        planoExistente.setDescricao(request.getDescricao());
        planoExistente.setPrecoCentavos(request.getPrecoCentavos());
        planoExistente.setAtivo(request.getAtivo());

        Plano planoAtualizadoSalvo = planoRepository.save(planoExistente);
        log.info("Plano atualizado com sucesso: {} (ID: {})", planoAtualizadoSalvo.getNome(), planoAtualizadoSalvo.getId());

        return planoAtualizadoSalvo;
    }

    @Transactional
    public void ativarPlano(UUID id) {
        log.info("Ativando plano com ID: {}", id);
        planoRepository.atualizarStatusAtivo(id, true);
        log.info("Plano ativado com sucesso: {}", id);
    }

    @Transactional
    public void desativarPlano(UUID id) {
        log.info("Desativando plano com ID: {}", id);
        planoRepository.atualizarStatusAtivo(id, false);
        log.info("Plano desativado com sucesso: {}", id);
    }

    @Transactional
    public void atualizarPreco(UUID id, Integer novoPrecoCentavos) {
        log.info("Atualizando preço do plano {} para {} centavos", id, novoPrecoCentavos);
        
        if (novoPrecoCentavos < 0) {
            throw new IllegalArgumentException("O preço não pode ser negativo");
        }

        planoRepository.atualizarPreco(id, novoPrecoCentavos);
        log.info("Preço do plano atualizado com sucesso: {} -> {} centavos", id, novoPrecoCentavos);
    }

    @Transactional
    public void excluirPlano(UUID id) {
        log.info("Excluindo plano com ID: {}", id);
        
        Plano plano = buscarPorId(id);
        planoRepository.delete(plano);
        
        log.info("Plano excluído com sucesso: {} (ID: {})", plano.getNome(), id);
    }

    public boolean existePlanoComNome(String nome) {
        return planoRepository.existsByNome(nome);
    }
}