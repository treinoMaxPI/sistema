package senai.treinomax.api.auth.service;

import senai.treinomax.api.auth.dto.request.LoginRequest;
import senai.treinomax.api.auth.dto.request.RefreshTokenRequest;
import senai.treinomax.api.auth.dto.request.RegistroRequest;
import senai.treinomax.api.auth.dto.request.ResetSenhaRequest;
import senai.treinomax.api.auth.dto.response.LoginResponse;
import senai.treinomax.api.auth.dto.response.RefreshTokenResponse;
import senai.treinomax.api.auth.exception.EmailNaoVerificadoException;
import senai.treinomax.api.auth.exception.TokenExpiradoException;
import senai.treinomax.api.auth.exception.TokenInvalidoException;
import senai.treinomax.api.auth.exception.UsuarioNaoEncontradoException;
import senai.treinomax.api.auth.model.RefreshToken;
import senai.treinomax.api.auth.model.Usuario;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final UsuarioService usuarioService;
    private final TokenService tokenService;
    private final EmailService emailService;

    @Transactional
    public void registrarUsuario(RegistroRequest registroRequest) {
        log.info("Iniciando registro de usuário: {}", registroRequest.getEmail());
        
        Usuario usuario = usuarioService.registrarUsuario(registroRequest);
        log.info("Usuário registrado com sucesso: {}", usuario.getEmail());
    }

    @Transactional
    public LoginResponse autenticar(LoginRequest loginRequest) {
        log.info("Tentativa de autenticação para: {}", loginRequest.getEmail());

        // Validar credenciais
        if (!usuarioService.validarCredenciais(loginRequest.getEmail(), loginRequest.getSenha())) {
            log.warn("Credenciais inválidas para: {}", loginRequest.getEmail());
            throw new BadCredentialsException("Credenciais inválidas");
        }

        // Buscar usuário
        Usuario usuario = usuarioService.buscarPorEmail(loginRequest.getEmail());

        // Verificar se usuário está ativo e email verificado
        if (!usuario.getAtivo()) {
            log.warn("Tentativa de login com usuário inativo: {}", loginRequest.getEmail());
            throw new BadCredentialsException("Usuário inativo");
        }
        
        if (!usuario.getEmailVerificado()) {
            log.warn("Tentativa de login com email não verificado: {}", loginRequest.getEmail());
            throw new EmailNaoVerificadoException("Email não verificado. Verifique seu email para ativar sua conta.");
        }

        // Gerar JWT
        String jwtToken = tokenService.gerarTokenJWT(usuario);

        // Gerar refresh token
        RefreshToken refreshToken = tokenService.gerarRefreshToken(usuario);

        // Construir resposta
        LoginResponse response = new LoginResponse();
        response.setToken(jwtToken);
        response.setRefreshToken(refreshToken.getToken());
        response.setNome(usuario.getNome());
        response.setEmail(usuario.getEmail());
        response.setEmailVerificado(usuario.getEmailVerificado());
        response.setRoles(usuario.getRoles());

        log.info("Autenticação bem-sucedida para: {}", loginRequest.getEmail());
        return response;
    }

    @Transactional
    public void solicitarRecuperacaoSenha(String email) {
        log.info("Solicitando recuperação de senha para: {}", email);

        try {
            Usuario usuario = usuarioService.buscarPorEmail(email);

            // Verificar se usuário está ativo
            if (!usuario.getAtivo()) {
                log.warn("Tentativa de recuperação de senha para usuário inativo: {}", email);
                throw new UsuarioNaoEncontradoException("Usuário não encontrado");
            }

            // Gerar token de recuperação
            String tokenRecuperacao = tokenService.gerarTokenRecuperacaoSenha(usuario);

            // Enviar email
            emailService.enviarEmailRecuperacaoSenha(usuario, tokenRecuperacao);

            log.info("Solicitação de recuperação de senha processada para: {}", email);
        } catch (UsuarioNaoEncontradoException e) {
            // Log mas não revelar que o usuário não existe por segurança
            log.info("Solicitação de recuperação de senha processada (usuário não encontrado): {}", email);
        }
    }

    @Transactional
    public void resetarSenha(ResetSenhaRequest resetSenhaRequest) {
        log.info("Processando reset de senha com token: {}", resetSenhaRequest.getToken());

        try {
            // Validar token e obter usuário
            Usuario usuario = tokenService.validarTokenRecuperacaoSenha(resetSenhaRequest.getToken());

            // Atualizar senha
            usuarioService.atualizarSenha(usuario, resetSenhaRequest.getNovaSenha());

            log.info("Senha resetada com sucesso para: {}", usuario.getEmail());
        } catch (TokenInvalidoException | TokenExpiradoException e) {
            log.warn("Token inválido ou expirado para reset de senha: {}", resetSenhaRequest.getToken());
            throw e;
        }
    }

    @Transactional
    public void verificarEmail(String token) {
        log.info("Verificando email com token: {}", token);
        
        try {
            usuarioService.verificarEmail(token);
            log.info("Email verificado com sucesso para token: {}", token);
        } catch (TokenInvalidoException | TokenExpiradoException e) {
            log.warn("Token inválido ou expirado para verificação de email: {}", token);
            throw e;
        }
    }

    @Transactional
    public void reenviarEmailVerificacao(String email) {
        log.info("Reenviando email de verificação para: {}", email);
        
        try {
            usuarioService.reenviarEmailVerificacao(email);
            log.info("Email de verificação reenviado para: {}", email);
        } catch (UsuarioNaoEncontradoException e) {
            log.warn("Usuário não encontrado para reenvio de email de verificação: {}", email);
            throw e;
        }
    }

    @Transactional
    public RefreshTokenResponse refreshToken(RefreshTokenRequest refreshTokenRequest) {
        log.info("Processando refresh token");

        try {
            // Validar refresh token
            RefreshToken refreshToken = tokenService.validarRefreshToken(refreshTokenRequest.getRefreshToken());

            // Obter usuário
            Usuario usuario = refreshToken.getUsuario();

            // Verificar se usuário está ativo
            if (!usuario.getAtivo()) {
                log.warn("Tentativa de refresh token com usuário inativo: {}", usuario.getEmail());
                throw new BadCredentialsException("Usuário inativo");
            }

            // Gerar novo JWT
            String novoJwtToken = tokenService.gerarTokenJWT(usuario);

            // Gerar novo refresh token (rotation)
            RefreshToken novoRefreshToken = tokenService.gerarRefreshToken(usuario);

            // Construir resposta
            RefreshTokenResponse response = new RefreshTokenResponse();
            response.setToken(novoJwtToken);
            response.setRefreshToken(novoRefreshToken.getToken());

            log.info("Refresh token processado com sucesso para: {}", usuario.getEmail());
            return response;
        } catch (TokenInvalidoException | TokenExpiradoException e) {
            log.warn("Refresh token inválido ou expirado");
            throw e;
        }
    }

    @Transactional
    public void logout(String refreshToken) {
        log.info("Processando logout");

        try {
            // Validar e revogar refresh token
            RefreshToken token = tokenService.validarRefreshToken(refreshToken);
            
            // Já revogado pelo validarRefreshToken, apenas log
            log.info("Logout realizado com sucesso para usuário: {}", token.getUsuario().getEmail());
        } catch (TokenInvalidoException | TokenExpiradoException e) {
            log.warn("Token inválido ou expirado durante logout");
            // Não lançar exceção, apenas log para evitar vazamento de informação
        }
    }

    @Transactional
    public void logoutAll(String email) {
        log.info("Processando logout de todos os dispositivos para: {}", email);

        try {
            Usuario usuario = usuarioService.buscarPorEmail(email);
            
            // Revogar todos os tokens do usuário
            tokenService.revogarTodosTokensDoUsuario(usuario.getId());
            
            log.info("Logout de todos os dispositivos realizado para: {}", email);
        } catch (UsuarioNaoEncontradoException e) {
            log.warn("Usuário não encontrado para logout de todos os dispositivos: {}", email);
            throw e;
        }
    }
}