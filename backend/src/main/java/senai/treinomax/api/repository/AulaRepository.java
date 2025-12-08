package senai.treinomax.api.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import senai.treinomax.api.model.Aula;

@Repository
public interface AulaRepository extends JpaRepository<Aula, UUID> {
    List<Aula> findByCategoriaId(UUID categoriaId);

    List<Aula> findByCategoriaPlanosId(UUID planoId);
}
