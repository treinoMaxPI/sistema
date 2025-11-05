package senai.treinomax.api.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import senai.treinomax.api.auth.model.Usuario;
import senai.treinomax.api.auth.repository.UsuarioRepository;
import senai.treinomax.api.auth.service.UsuarioService;
import senai.treinomax.api.model.Plano;
import senai.treinomax.api.model.PlanoCobranca;
import senai.treinomax.api.repository.PlanoCobrancaRepository;
import senai.treinomax.api.util.DateUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class PlanoUsuarioService {

    private final UsuarioRepository usuarioRepository;

    private final UsuarioService usuarioService;
    private final PlanoService planoService;
    private final PlanoCobrancaRepository planoCobrancaRepository;

    @Transactional
    public void atribuirPlanoAoUsuario(UUID usuarioId, UUID planoId) {
        log.info("Atribuindo plano {} ao usuário {}", planoId, usuarioId);
        LocalDateTime horarioNow = DateUtils.getCurrentBrazilianLocalDateTime();
        Usuario usuario = usuarioService.buscarPorId(usuarioId);
        Plano plano = planoService.buscarPorId(planoId);
        
        if (usuario.getPlano() != null && usuario.getPlano().getId().equals(planoId)) {
            throw new IllegalArgumentException("Usuário já possui este plano");
        }

        if (!plano.getAtivo()) {
            log.warn("Tentativa de atribuir plano inativo {} ao usuário {}", planoId, usuarioId);
            throw new IllegalArgumentException("Não é possível atribuir um plano inativo");
        }
        
        YearMonth mesAtual = YearMonth.from(horarioNow);
        LocalDate dataVencimento = horarioNow.toLocalDate();

        Optional<PlanoCobranca> cobrancaExistente = planoCobrancaRepository
            .findByUsuarioIdAndMesReferencia(usuarioId, mesAtual);
        
        if (cobrancaExistente.isEmpty()) {
            PlanoCobranca planoCobranca = PlanoCobranca.builder()
                .dataVencimento(horarioNow.toLocalDate())
                .mesReferencia(mesAtual)
                .plano(plano)
                .usuario(usuario)
                .pago(false)
                .valorCentavos(plano.getPrecoCentavos())
                .inadimplenciaProcessada(false)
            .build();

            usuario.setProximoPlano(null);
            usuario.setPlano(plano);
            planoCobrancaRepository.save(planoCobranca);

            log.info("Plano {} atribuído imediatamente ao usuário {} com vencimento em {}",
                    plano.getNome(), usuario.getEmail(), dataVencimento);
        } else {
            usuario.setProximoPlano(plano);

            log.info("Usuário {} já possui cobrança no mês {}. Plano {} será aplicado no próximo mês.",
             usuario.getEmail(), mesAtual, plano.getNome());
        }

        usuarioService.salvar(usuario);
        log.info("Plano {} atribuído com sucesso ao usuário {}", plano.getNome(), usuario.getEmail());
    }

    @Transactional
    public void removerPlanoDoUsuario(UUID usuarioId) {
        log.info("Removendo plano do usuário {}", usuarioId);

        Usuario usuario = usuarioService.buscarPorId(usuarioId);

        if (usuario.getPlano() == null) {
            log.warn("Tentativa de remover plano de usuário sem plano: {}", usuarioId);
            throw new IllegalArgumentException("Usuário não possui plano atribuído");
        }

        String planoNome = usuario.getPlano().getNome();
        usuario.setPlano(null);
        usuarioService.salvar(usuario);

        log.info("Plano {} removido com sucesso do usuário {}", planoNome, usuario.getEmail());
    }

    public Plano obterPlanoDoUsuario(UUID usuarioId) {
        log.debug("Obtendo plano do usuário {}", usuarioId);

        Usuario usuario = usuarioService.buscarPorId(usuarioId);

        if (usuario.getPlano() == null) {
            log.warn("Usuário {} não possui plano atribuído", usuarioId);
            throw new IllegalArgumentException("Usuário não possui plano atribuído");
        }

        return usuario.getPlano();
    }

    public boolean usuarioPossuiPlano(UUID usuarioId) {
        log.debug("Verificando se usuário {} possui plano", usuarioId);

        Usuario usuario = usuarioService.buscarPorId(usuarioId);
        return usuario.getPlano() != null;
    }

    public List<Usuario> listarUsuariosPorPlano(UUID planoId) {
        log.debug("Listando usuários com plano {}", planoId);

        Plano plano = planoService.buscarPorId(planoId);

        List<Usuario> usuarios = usuarioService.listarUsuariosPorPlano(planoId);

        log.debug("Encontrados {} usuários com plano {}", usuarios.size(), plano.getNome());
        return usuarios;
    }

    public List<Usuario> listarUsuariosSemPlano() {
        log.debug("Listando usuários sem plano");

        List<Usuario> usuarios = usuarioService.listarUsuariosSemPlano();
        log.debug("Encontrados {} usuários sem plano", usuarios.size());

        return usuarios;
    }

    @Transactional
    public void atualizarPlanoDoUsuario(UUID usuarioId, UUID novoPlanoId) {
        log.info("Atualizando plano do usuário {} para {}", usuarioId, novoPlanoId);

        Usuario usuario = usuarioService.buscarPorId(usuarioId);
        Plano novoPlano = planoService.buscarPorId(novoPlanoId);

        if (!novoPlano.getAtivo()) {
            log.warn("Tentativa de atualizar para plano inativo {} para usuário {}", novoPlanoId, usuarioId);
            throw new IllegalArgumentException("Não é possível atribuir um plano inativo");
        }

        String planoAnterior = usuario.getPlano() != null ? usuario.getPlano().getNome() : "Nenhum";
        usuario.setPlano(novoPlano);
        usuarioService.salvar(usuario);

        log.info("Plano atualizado de '{}' para '{}' no usuário {}", 
                planoAnterior, novoPlano.getNome(), usuario.getEmail());
    }

    public long contarUsuariosPorPlano(UUID planoId) {
        log.debug("Contando usuários com plano {}", planoId);

        planoService.buscarPorId(planoId);

        long count = usuarioService.contarUsuariosPorPlano(planoId);
        log.debug("Plano {} possui {} usuários", planoId, count);

        return count;
    }

    public boolean planoPodeSerDesativado(UUID planoId) {
        log.debug("Verificando se plano {} pode ser desativado", planoId);

        long usuariosAtivos = contarUsuariosPorPlano(planoId);
        boolean podeDesativar = usuariosAtivos == 0;

        if (!podeDesativar) {
            log.warn("Plano {} possui {} usuários ativos e não pode ser desativado", 
                    planoId, usuariosAtivos);
        }

        return podeDesativar;
    }

    @Transactional
    public int removerPlanoDeTodosUsuarios(UUID planoId) {
        log.info("Removendo plano {} de todos os usuários", planoId);

        List<Usuario> usuarios = listarUsuariosPorPlano(planoId);

        for (Usuario usuario : usuarios) {
            usuario.setPlano(null);
            usuarioService.salvar(usuario);
        }

        log.info("Plano {} removido de {} usuários", planoId, usuarios.size());
        return usuarios.size();
    }

    @Transactional
    public int migrarUsuariosEntrePlanos(UUID planoOrigemId, UUID planoDestinoId) {
        log.info("Migrando usuários do plano {} para plano {}", planoOrigemId, planoDestinoId);

        Plano planoDestino = planoService.buscarPorId(planoDestinoId);

        if (!planoDestino.getAtivo()) {
            log.warn("Tentativa de migrar usuários para plano inativo {}", planoDestinoId);
            throw new IllegalArgumentException("Não é possível migrar usuários para um plano inativo");
        }

        List<Usuario> usuarios = listarUsuariosPorPlano(planoOrigemId);

        for (Usuario usuario : usuarios) {
            usuario.setPlano(planoDestino);
            usuarioService.salvar(usuario);
        }

        log.info("{} usuários migrados do plano {} para plano {}", 
                usuarios.size(), planoOrigemId, planoDestinoId);

        return usuarios.size();
    }

    @Transactional
    public void processarInadimplencia(PlanoCobranca cobranca) {
        if (cobranca.getPago()) {
            return;
        }
        
        cobranca.setInadimplenciaProcessada(true);
        Usuario usuario = cobranca.getUsuario();
        usuario.setPlano(null);
        usuario.setProximoPlano(null);
        
        usuarioRepository.save(usuario);
        planoCobrancaRepository.save(cobranca);
    }


}