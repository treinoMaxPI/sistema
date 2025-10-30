package senai.treinomax.api.auth.repository;

import senai.treinomax.api.auth.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, UUID> {

    Optional<Usuario> findByEmail(String email);

    Boolean existsByEmail(String email);

    @Modifying
    @Query("UPDATE Usuario u SET u.emailVerificado = true WHERE u.id = :usuarioId")
    void marcarEmailComoVerificado(@Param("usuarioId") UUID usuarioId);

    @Modifying
    @Query("UPDATE Usuario u SET u.senha = :novaSenha WHERE u.id = :usuarioId")
    void atualizarSenha(@Param("usuarioId") UUID usuarioId, @Param("novaSenha") String novaSenha);

    @Modifying
    @Query("UPDATE Usuario u SET u.ativo = :ativo WHERE u.id = :usuarioId")
    void atualizarStatusAtivo(@Param("usuarioId") UUID usuarioId, @Param("ativo") Boolean ativo);
}