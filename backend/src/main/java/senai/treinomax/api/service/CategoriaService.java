package senai.treinomax.api.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import senai.treinomax.api.auth.model.Usuario;
import senai.treinomax.api.auth.service.UsuarioService;
import senai.treinomax.api.model.Categoria;
import senai.treinomax.api.repository.CategoriaRepository;

@Service
@RequiredArgsConstructor
@Slf4j
public class CategoriaService {

	private final CategoriaRepository categoriaRepository;
	private final UsuarioService usuarioService;

	@Transactional
	public Categoria salvar(Categoria categoria) {
		log.warn("Salvando categoria: {}", categoria);
		

		if (categoria == null) {
			throw new IllegalArgumentException("Categoria não pode ser nula");
		}

		String nome = categoria.getNome();
		if (nome == null || nome.isBlank()) {
			throw new IllegalArgumentException("Nome da categoria é obrigatório");
		}
		if (nome.length() < 3 || nome.length() > 100) {
			throw new IllegalArgumentException("Nome da categoria deve ter entre 3 e 100 caracteres");
		}

		if (categoria.getId() != null) {
			UUID id = categoria.getId();
			if (!categoriaRepository.existsById(id)) {
				throw new IllegalArgumentException("Não é possível atualizar: categoria não encontrada com ID: " + id);
			}
		}
		return categoriaRepository.save(categoria);
	}

	@Transactional
	public void deletarPorId(String id) {
		log.warn("Deletando categoria por ID: {}", id);

		if (id == null || id.isBlank()) {
			throw new IllegalArgumentException("ID da categoria é obrigatório");
		}

		UUID uuid;
		try {
			uuid = UUID.fromString(id);
		} catch (IllegalArgumentException ex) {
			throw new IllegalArgumentException("ID da categoria inválido: " + id);
		}

		if (!categoriaRepository.existsById(uuid)) {
			throw new IllegalArgumentException("Categoria não encontrada com ID: " + id);
		}

		categoriaRepository.deleteById(uuid);
	}

	@Transactional
	public Categoria buscarPorId(String id) {
		log.warn("Buscando categoria por ID: {}", id);

		if (id == null || id.isBlank()) {
			throw new IllegalArgumentException("ID da categoria é obrigatório");
		}

		UUID uuid;
		try {
			uuid = UUID.fromString(id);
		} catch (IllegalArgumentException ex) {
			throw new IllegalArgumentException("ID da categoria inválido: " + id);
		}

		return categoriaRepository.findById(uuid)
				.orElseThrow(() -> new IllegalArgumentException("Categoria não encontrada com ID: " + id));
	}

	@Transactional
	public List<Categoria> listarTodas() {
		log.warn("Listando todas as categorias");
		return categoriaRepository.findAll();
	}

}
