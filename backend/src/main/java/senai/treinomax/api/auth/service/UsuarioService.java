package senai.treinomax.api.auth.service;

import senai.treinomax.api.auth.dto.request.RegistroRequest;
import senai.treinomax.api.auth.exception.EmailJaCadastradoException;
import senai.treinomax.api.auth.exception.UsuarioNaoEncontradoException;
import senai.treinomax.api.auth.model.Usuario;
import senai.treinomax.api.auth.repository.UsuarioRepository;
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

    @Transactional
    public Usuario registrarUsuario(RegistroRequest registroRequest) {
        log.info("Tentando registrar usuário com email: {}", registroRequest.getEmail());

        if (usuarioRepository.existsByEmail(registroRequest.getEmail())) {
            log.warn("Tentativa de registro com email já cadastrado: {}", registroRequest.getEmail());
            throw new EmailJaCadastradoException("Email já cadastrado: " + registroRequest.getEmail());
        }

        Usuario usuario = new Usuario();
        usuario.setNome(registroRequest.getNome());
        usuario.setEmail(registroRequest.getEmail());
        usuario.setSenha(passwordEncoder.encode(registroRequest.getSenha()));
        usuario.setAtivo(true);
        usuario.setEmailVerificado(false);

        if (registroRequest.getRoles() != null && !registroRequest.getRoles().isEmpty()) {
            usuario.setRoles(registroRequest.getRoles());
        }

        Usuario usuarioSalvo = usuarioRepository.save(usuario);
        log.info("Usuário registrado com sucesso: {}", usuarioSalvo.getEmail());

        String tokenVerificacao = tokenService.gerarTokenVerificacaoEmail(usuarioSalvo);

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
    public Usuario salvar(Usuario usuario) {
        log.debug("Salvando usuário: {}", usuario.getEmail());
        return usuarioRepository.save(usuario);
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

        emailService.enviarEmailConfirmacaoResetSenha(usuario);

        log.info("Senha atualizada com sucesso para usuário: {}", usuario.getEmail());
    }

    @Transactional
    public void verificarEmail(String token) {
        log.info("Verificando email com token: {}", token);

        Usuario usuario = tokenService.validarTokenVerificacaoEmail(token);

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

        String tokenVerificacao = tokenService.gerarTokenVerificacaoEmail(usuario);

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

    public List<Usuario> listarUsuariosPorPlano(UUID planoId) {
        log.debug("Listando usuários com plano {}", planoId);
        return usuarioRepository.findByPlanoId(planoId);
    }

    public List<Usuario> listarUsuariosSemPlano() {
        log.debug("Listando usuários sem plano");
        return usuarioRepository.findByPlanoIsNull();
    }

    public long contarUsuariosPorPlano(UUID planoId) {
        log.debug("Contando usuários com plano {}", planoId);
        return usuarioRepository.countByPlanoId(planoId);
    }

    public List<Usuario> listarTodos() {
        log.debug("Listando todos os usuários");
        return usuarioRepository.findAll();
    }

    @Transactional
    public void promoverParaPersonal(UUID id) {
        log.info("Promovendo usuário com ID {} para PERSONAL", id);
        Usuario usuario = buscarPorId(id);
        usuario.addRole(senai.treinomax.api.auth.model.Role.PERSONAL);
        usuarioRepository.save(usuario);
        log.info("Usuário {} promovido para PERSONAL com sucesso", usuario.getEmail());
    }
}