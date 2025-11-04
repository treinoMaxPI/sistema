package senai.treinomax.api.auth.service;

import senai.treinomax.api.auth.dto.request.RegistroRequest;
import senai.treinomax.api.auth.exception.EmailJaCadastradoException;
import senai.treinomax.api.auth.exception.UsuarioNaoEncontradoException;
import senai.treinomax.api.auth.model.Usuario;
import senai.treinomax.api.auth.repository.UsuarioRepository;
import senai.treinomax.api.model.Plano;
import senai.treinomax.api.service.PlanoService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;
    private final TokenService tokenService;
    private final EmailService emailService;
    private final PlanoService planoService;

    @Transactional
    public Usuario registrarUsuario(RegistroRequest registroRequest) {
        log.info("Tentando registrar usuário com email: {}", registroRequest.getEmail());

        // Verificar se email já existe
        if (usuarioRepository.existsByEmail(registroRequest.getEmail())) {
            log.warn("Tentativa de registro com email já cadastrado: {}", registroRequest.getEmail());
            throw new EmailJaCadastradoException("Email já cadastrado: " + registroRequest.getEmail());
        }

        // Criar novo usuário
        Usuario usuario = new Usuario();
        usuario.setNome(registroRequest.getNome());
        usuario.setEmail(registroRequest.getEmail());
        usuario.setSenha(passwordEncoder.encode(registroRequest.getSenha()));
        usuario.setAtivo(true);
        usuario.setEmailVerificado(false);
        
        // Set roles from request, if provided
        if (registroRequest.getRoles() != null && !registroRequest.getRoles().isEmpty()) {
            usuario.setRoles(registroRequest.getRoles());
        }

        Usuario usuarioSalvo = usuarioRepository.save(usuario);
        log.info("Usuário registrado com sucesso: {}", usuarioSalvo.getEmail());

        // Gerar token de verificação de email
        String tokenVerificacao = tokenService.gerarTokenVerificacaoEmail(usuarioSalvo);
        
        // Enviar email de verificação
        emailService.enviarEmailVerificacao(usuarioSalvo, tokenVerificacao);

        return usuarioSalvo;
    }

    public Usuario buscarPorEmail(String email) {
        log.debug("Buscando usuário por email: {}", email);
        return usuarioRepository.findByEmail(email)
                .orElseThrow(() -> {
                    log.warn("Usuário não encontrado com email: {}", email);
                    return new UsuarioNaoEncontradoException("Usuário não encontrado com email: " + email);
                });
    }

    public Usuario buscarPorId(UUID id) {
        log.debug("Buscando usuário por ID: {}", id);
        return usuarioRepository.findById(id)
                .orElseThrow(() -> {
                    log.warn("Usuário não encontrado com ID: {}", id);
                    return new UsuarioNaoEncontradoException("Usuário não encontrado com ID: " + id);
                });
    }

    @Transactional
    public void ativarUsuario(UUID id) {
        log.info("Ativando usuário com ID: {}", id);
        Usuario usuario = buscarPorId(id);
        
        usuario.setAtivo(true);
        usuario.setEmailVerificado(true);
        
        usuarioRepository.save(usuario);
        log.info("Usuário ativado com sucesso: {}", usuario.getEmail());
    }

    @Transactional
    public void atualizarSenha(Usuario usuario, String novaSenha) {
        log.info("Atualizando senha para usuário: {}", usuario.getEmail());
        
        usuario.setSenha(passwordEncoder.encode(novaSenha));
        usuarioRepository.save(usuario);
        
        // Enviar email de confirmação
        emailService.enviarEmailConfirmacaoResetSenha(usuario);
        
        log.info("Senha atualizada com sucesso para usuário: {}", usuario.getEmail());
    }

    @Transactional
    public void verificarEmail(String token) {
        log.info("Verificando email com token: {}", token);
        
        // Validar token e obter usuário
        Usuario usuario = tokenService.validarTokenVerificacaoEmail(token);
        
        // Ativar usuário e marcar email como verificado
        usuario.setEmailVerificado(true);
        usuario.setAtivo(true);
        
        usuarioRepository.save(usuario);
        log.info("Email verificado com sucesso para usuário: {}", usuario.getEmail());
    }

    @Transactional
    public void reenviarEmailVerificacao(String email) {
        log.info("Reenviando email de verificação para: {}", email);
        
        Usuario usuario = buscarPorEmail(email);
        
        if (usuario.getEmailVerificado()) {
            log.warn("Tentativa de reenvio de email para usuário já verificado: {}", email);
            throw new IllegalArgumentException("Email já verificado");
        }

        // Gerar novo token de verificação
        String tokenVerificacao = tokenService.gerarTokenVerificacaoEmail(usuario);
        
        // Enviar email de verificação
        emailService.enviarEmailVerificacao(usuario, tokenVerificacao);
        
        log.info("Email de verificação reenviado com sucesso para: {}", email);
    }

    public boolean existePorEmail(String email) {
        return usuarioRepository.existsByEmail(email);
    }

    public boolean validarCredenciais(String email, String senha) {
        log.debug("Validando credenciais para: {}", email);
        
        try {
            Usuario usuario = buscarPorEmail(email);
            
            if (!usuario.getAtivo()) {
                log.warn("Tentativa de login com usuário inativo: {}", email);
                return false;
            }

            boolean senhaValida = passwordEncoder.matches(senha, usuario.getSenha());
            
            if (!senhaValida) {
                log.warn("Senha inválida para usuário: {}", email);
            }
            
            return senhaValida;
        } catch (UsuarioNaoEncontradoException e) {
            log.warn("Usuário não encontrado durante validação de credenciais: {}", email);
            return false;
        }
    }

    @Transactional
    public void desativarUsuario(UUID id) {
        log.info("Desativando usuário com ID: {}", id);
        Usuario usuario = buscarPorId(id);
        
        usuario.setAtivo(false);
        usuarioRepository.save(usuario);
        
        log.info("Usuário desativado com sucesso: {}", usuario.getEmail());
    }

    // =====================================================
    // MÉTODOS PARA GERENCIAR PLANO DO USUÁRIO
    // =====================================================

    @Transactional
    public void atribuirPlanoAoUsuario(UUID usuarioId, UUID planoId) {
        log.info("Atribuindo plano {} ao usuário {}", planoId, usuarioId);
        
        Usuario usuario = buscarPorId(usuarioId);
        Plano plano = planoService.buscarPorId(planoId);
        
        // Verificar se o plano está ativo
        if (!plano.getAtivo()) {
            log.warn("Tentativa de atribuir plano inativo {} ao usuário {}", planoId, usuarioId);
            throw new IllegalArgumentException("Não é possível atribuir um plano inativo");
        }
        
        usuario.setPlano(plano);
        usuarioRepository.save(usuario);
        
        log.info("Plano {} atribuído com sucesso ao usuário {}", plano.getNome(), usuario.getEmail());
    }

    @Transactional
    public void removerPlanoDoUsuario(UUID usuarioId) {
        log.info("Removendo plano do usuário {}", usuarioId);
        
        Usuario usuario = buscarPorId(usuarioId);
        
        if (usuario.getPlano() == null) {
            log.warn("Tentativa de remover plano de usuário sem plano: {}", usuarioId);
            throw new IllegalArgumentException("Usuário não possui plano atribuído");
        }
        
        usuario.setPlano(null);
        usuarioRepository.save(usuario);
        
        log.info("Plano removido com sucesso do usuário {}", usuario.getEmail());
    }

    public Plano obterPlanoDoUsuario(UUID usuarioId) {
        log.debug("Obtendo plano do usuário {}", usuarioId);
        
        Usuario usuario = buscarPorId(usuarioId);
        
        if (usuario.getPlano() == null) {
            log.warn("Usuário {} não possui plano atribuído", usuarioId);
            throw new IllegalArgumentException("Usuário não possui plano atribuído");
        }
        
        return usuario.getPlano();
    }

    public boolean usuarioPossuiPlano(UUID usuarioId) {
        log.debug("Verificando se usuário {} possui plano", usuarioId);
        
        Usuario usuario = buscarPorId(usuarioId);
        return usuario.getPlano() != null;
    }

    public List<Usuario> listarUsuariosPorPlano(UUID planoId) {
        log.debug("Listando usuários com plano {}", planoId);
        
        // Buscar o plano primeiro para validar sua existência
        Plano plano = planoService.buscarPorId(planoId);
        
        // Buscar usuários que possuem este plano usando o método do repositório
        return usuarioRepository.findByPlanoId(planoId);
    }

    public List<Usuario> listarUsuariosSemPlano() {
        log.debug("Listando usuários sem plano");
        
        return usuarioRepository.findByPlanoIsNull();
    }

    @Transactional
    public void atualizarPlanoDoUsuario(UUID usuarioId, UUID novoPlanoId) {
        log.info("Atualizando plano do usuário {} para {}", usuarioId, novoPlanoId);
        
        Usuario usuario = buscarPorId(usuarioId);
        Plano novoPlano = planoService.buscarPorId(novoPlanoId);
        
        // Verificar se o novo plano está ativo
        if (!novoPlano.getAtivo()) {
            log.warn("Tentativa de atualizar para plano inativo {} para usuário {}", novoPlanoId, usuarioId);
            throw new IllegalArgumentException("Não é possível atribuir um plano inativo");
        }
        
        usuario.setPlano(novoPlano);
        usuarioRepository.save(usuario);
        
        log.info("Plano atualizado com sucesso para {} no usuário {}", novoPlano.getNome(), usuario.getEmail());
    }
}