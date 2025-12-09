package senai.treinomax.api.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import senai.treinomax.api.model.Categoria;

@Repository
public interface CategoriaRepository extends JpaRepository<Categoria, UUID> {

    List<Categoria> findAllByOrderByDataAtualizacaoDesc();
}
