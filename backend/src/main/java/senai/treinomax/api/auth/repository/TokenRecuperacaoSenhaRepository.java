package senai.treinomax.api.auth.repository;

import senai.treinomax.api.auth.model.TokenRecuperacaoSenha;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TokenRecuperacaoSenhaRepository extends JpaRepository<TokenRecuperacaoSenha, UUID> {

    Optional<TokenRecuperacaoSenha> findByToken(String token);

    @Modifying
    @Query("DELETE FROM TokenRecuperacaoSenha t WHERE t.usuario.id = :usuarioId")
    void deleteByUsuarioId(@Param("usuarioId") UUID usuarioId);

    @Modifying
    @Query("DELETE FROM TokenRecuperacaoSenha t WHERE t.dataExpiracao < :dataLimite")
    void deleteExpirados(@Param("dataLimite") LocalDateTime dataLimite);

    @Modifying
    @Query("UPDATE TokenRecuperacaoSenha t SET t.utilizado = true WHERE t.id = :tokenId")
    void marcarComoUtilizado(@Param("tokenId") UUID tokenId);
}