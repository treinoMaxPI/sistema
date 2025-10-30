package senai.treinomax.api.auth.repository;

import senai.treinomax.api.auth.model.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {

    Optional<RefreshToken> findByToken(String token);

    Optional<RefreshToken> findByUsuarioId(UUID usuarioId);

    @Modifying
    @Query("DELETE FROM RefreshToken t WHERE t.usuario.id = :usuarioId")
    void deleteByUsuarioId(@Param("usuarioId") UUID usuarioId);

    @Modifying
    @Query("DELETE FROM RefreshToken t WHERE t.dataExpiracao < :dataLimite")
    void deleteExpirados(@Param("dataLimite") LocalDateTime dataLimite);

    @Modifying
    @Query("UPDATE RefreshToken t SET t.revogado = true WHERE t.id = :tokenId")
    void revogarToken(@Param("tokenId") UUID tokenId);

    @Modifying
    @Query("UPDATE RefreshToken t SET t.revogado = true WHERE t.usuario.id = :usuarioId")
    void revogarTodosTokensDoUsuario(@Param("usuarioId") UUID usuarioId);
}