package senai.treinomax.api.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import senai.treinomax.api.model.Categoria;
import senai.treinomax.api.repository.CategoriaRepository;

@Service
@RequiredArgsConstructor
@Slf4j
public class CategoriaService {

	private final CategoriaRepository categoriaRepository;

	@Transactional
	public Categoria salvar(Categoria categoria) {
		log.warn("Salvando categoria: {}", categoria);
		return categoriaRepository.save(categoria);
	}

	@Transactional
	public void deletarPorId(String id) {
		log.warn("Deletando categoria por ID: {}", id);
		categoriaRepository.deleteById(UUID.fromString(id));
	}

	@Transactional
	public Categoria buscarPorId(String id) {
		log.warn("Buscando categoria por ID: {}", id);
		return categoriaRepository.findById(UUID.fromString(id))
				.orElseThrow(() -> new IllegalArgumentException("Categoria não encontrada com ID: " + id));
	}

	@Transactional
	public List<Categoria> listarTodas() {
		log.warn("Listando todas as categorias");
		return categoriaRepository.findAll();
	}

}
