package senai.treinomax.api.auth.service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import senai.treinomax.api.auth.exception.TokenExpiradoException;
import senai.treinomax.api.auth.exception.TokenInvalidoException;
import senai.treinomax.api.auth.model.RefreshToken;
import senai.treinomax.api.auth.model.TokenRecuperacaoSenha;
import senai.treinomax.api.auth.model.TokenVerificacaoEmail;
import senai.treinomax.api.auth.model.Usuario;
import senai.treinomax.api.auth.repository.RefreshTokenRepository;
import senai.treinomax.api.auth.repository.TokenRecuperacaoSenhaRepository;
import senai.treinomax.api.auth.repository.TokenVerificacaoEmailRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.Key;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class TokenService {

    private final RefreshTokenRepository refreshTokenRepository;
    private final TokenRecuperacaoSenhaRepository tokenRecuperacaoSenhaRepository;
    private final TokenVerificacaoEmailRepository tokenVerificacaoEmailRepository;

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.expiration:86400000}")
    private Long jwtExpiration;

    @Value("${jwt.refresh-expiration:2592000000}")
    private Long refreshTokenExpiration;

    private Key getSigningKey() {
        return Keys.hmacShaKeyFor(jwtSecret.getBytes());
    }

    public String gerarTokenJWT(Usuario usuario) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + jwtExpiration);

        return Jwts.builder()
                .setSubject(usuario.getEmail())
                .claim("id", usuario.getId().toString())
                .claim("nome", usuario.getNome())
                .claim("emailVerificado", usuario.getEmailVerificado())
                .claim("roles", usuario.getRoles())
                .setIssuedAt(now)
                .setExpiration(expiryDate)
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    public Claims validarToken(String token) {
        try {
            return Jwts.parserBuilder()
                    .setSigningKey(getSigningKey())
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
        } catch (Exception e) {
            log.error("Token JWT inválido: {}", e.getMessage());
            throw new TokenInvalidoException("Token JWT inválido: " + e.getMessage());
        }
    }

    public String extrairEmailDoToken(String token) {
        Claims claims = validarToken(token);
        return claims.getSubject();
    }

    public UUID extrairIdDoToken(String token) {
        Claims claims = validarToken(token);
        String id = claims.get("id", String.class);
        return UUID.fromString(id);
    }

    @Transactional
    public RefreshToken gerarRefreshToken(Usuario usuario) {
        // Revogar tokens antigos do usuário
        refreshTokenRepository.revogarTodosTokensDoUsuario(usuario.getId());

        // Gerar novo token
        String token = UUID.randomUUID().toString();
        LocalDateTime dataExpiracao = LocalDateTime.now().plusSeconds(refreshTokenExpiration / 1000);

        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setToken(token);
        refreshToken.setUsuario(usuario);
        refreshToken.setDataExpiracao(dataExpiracao);
        refreshToken.setRevogado(false);

        RefreshToken tokenSalvo = refreshTokenRepository.save(refreshToken);
        log.info("Refresh token gerado para usuário: {}", usuario.getEmail());

        return tokenSalvo;
    }

    @Transactional
    public RefreshToken validarRefreshToken(String token) {
        RefreshToken refreshToken = refreshTokenRepository.findByToken(token)
                .orElseThrow(() -> {
                    log.warn("Refresh token não encontrado: {}", token);
                    return new TokenInvalidoException("Refresh token inválido");
                });

        if (!refreshToken.isValido()) {
            log.warn("Refresh token inválido ou expirado: {}", token);
            throw new TokenExpiradoException("Refresh token expirado ou revogado");
        }

        // Revogar token atual (rotation)
        refreshToken.setRevogado(true);
        refreshTokenRepository.save(refreshToken);

        log.info("Refresh token validado e revogado: {}", token);
        return refreshToken;
    }

    @Transactional
    public String gerarTokenRecuperacaoSenha(Usuario usuario) {
        // Remover tokens antigos
        tokenRecuperacaoSenhaRepository.deleteByUsuarioId(usuario.getId());

        // Gerar novo token
        String token = UUID.randomUUID().toString();
        LocalDateTime dataExpiracao = LocalDateTime.now().plusHours(1);

        TokenRecuperacaoSenha tokenRecuperacao = new TokenRecuperacaoSenha();
        tokenRecuperacao.setToken(token);
        tokenRecuperacao.setUsuario(usuario);
        tokenRecuperacao.setDataExpiracao(dataExpiracao);
        tokenRecuperacao.setUtilizado(false);

        tokenRecuperacaoSenhaRepository.save(tokenRecuperacao);
        log.info("Token de recuperação de senha gerado para usuário: {}", usuario.getEmail());

        return token;
    }

    @Transactional
    public Usuario validarTokenRecuperacaoSenha(String token) {
        TokenRecuperacaoSenha tokenRecuperacao = tokenRecuperacaoSenhaRepository.findByToken(token)
                .orElseThrow(() -> {
                    log.warn("Token de recuperação de senha não encontrado: {}", token);
                    return new TokenInvalidoException("Token de recuperação de senha inválido");
                });

        if (!tokenRecuperacao.isValido()) {
            log.warn("Token de recuperação de senha inválido ou expirado: {}", token);
            throw new TokenExpiradoException("Token de recuperação de senha expirado ou já utilizado");
        }

        // Marcar token como utilizado
        tokenRecuperacao.setUtilizado(true);
        tokenRecuperacaoSenhaRepository.save(tokenRecuperacao);

        log.info("Token de recuperação de senha validado: {}", token);
        return tokenRecuperacao.getUsuario();
    }

    @Transactional
    public String gerarTokenVerificacaoEmail(Usuario usuario) {
        // Remover tokens antigos
        tokenVerificacaoEmailRepository.deleteByUsuarioId(usuario.getId());

        // Gerar novo token
        String token = UUID.randomUUID().toString();
        LocalDateTime dataExpiracao = LocalDateTime.now().plusHours(24);

        TokenVerificacaoEmail tokenVerificacao = new TokenVerificacaoEmail();
        tokenVerificacao.setToken(token);
        tokenVerificacao.setUsuario(usuario);
        tokenVerificacao.setDataExpiracao(dataExpiracao);
        tokenVerificacao.setUtilizado(false);

        tokenVerificacaoEmailRepository.save(tokenVerificacao);
        log.info("Token de verificação de email gerado para usuário: {}", usuario.getEmail());

        return token;
    }

    @Transactional
    public Usuario validarTokenVerificacaoEmail(String token) {
        TokenVerificacaoEmail tokenVerificacao = tokenVerificacaoEmailRepository.findByToken(token)
                .orElseThrow(() -> {
                    log.warn("Token de verificação de email não encontrado: {}", token);
                    return new TokenInvalidoException("Token de verificação de email inválido");
                });

        if (!tokenVerificacao.isValido()) {
            log.warn("Token de verificação de email inválido ou expirado: {}", token);
            throw new TokenExpiradoException("Token de verificação de email expirado ou já utilizado");
        }

        // Marcar token como utilizado
        tokenVerificacao.setUtilizado(true);
        tokenVerificacaoEmailRepository.save(tokenVerificacao);

        log.info("Token de verificação de email validado: {}", token);
        return tokenVerificacao.getUsuario();
    }

    @Transactional
    public void revogarTodosTokensDoUsuario(UUID usuarioId) {
        refreshTokenRepository.revogarTodosTokensDoUsuario(usuarioId);
        tokenRecuperacaoSenhaRepository.deleteByUsuarioId(usuarioId);
        tokenVerificacaoEmailRepository.deleteByUsuarioId(usuarioId);
        
        log.info("Todos os tokens revogados para usuário ID: {}", usuarioId);
    }

    public boolean isTokenExpirado(String token) {
        try {
            Claims claims = validarToken(token);
            return claims.getExpiration().before(new Date());
        } catch (Exception e) {
            return true;
        }
    }
}