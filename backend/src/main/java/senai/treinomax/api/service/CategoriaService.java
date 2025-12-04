package senai.treinomax.api.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import senai.treinomax.api.auth.model.Usuario;
import senai.treinomax.api.auth.service.UsuarioService;
import senai.treinomax.api.dto.request.CategoriaRequest;
import senai.treinomax.api.model.Categoria;

import senai.treinomax.api.repository.AulaRepository;
import senai.treinomax.api.repository.CategoriaRepository;

@Service
@RequiredArgsConstructor
@Slf4j
public class CategoriaService {

	private final CategoriaRepository categoriaRepository;

	private final AulaRepository aulaRepository;
	private final UsuarioService usuarioService;

	@Transactional
	public Categoria salvar(CategoriaRequest categoria, UUID criadoPorId) {
		log.warn("Salvando categoria: {}", categoria);

		Usuario criador = usuarioService.buscarPorId(criadoPorId);

		Categoria categoriaSalva = new Categoria();
		categoriaSalva.setNome(categoria.getNome());
		categoriaSalva.setPlanos(categoria.getPlanos());
		categoriaSalva.setCriadoPor(criador);

		String nome = categoria.getNome();
		if (nome == null || nome.isBlank()) {
			throw new IllegalArgumentException("Nome da categoria é obrigatório");
		}
		if (nome.length() < 3 || nome.length() > 100) {
			throw new IllegalArgumentException("Nome da categoria deve ter entre 3 e 100 caracteres");
		}

		if (categoriaSalva.getId() != null) {
			UUID id = categoriaSalva.getId();
			if (!categoriaRepository.existsById(id)) {
				throw new IllegalArgumentException("Não é possível atualizar: categoria não encontrada com ID: " + id);
			}
		}
		return categoriaRepository.save(categoriaSalva);
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

		if (!aulaRepository.findByCategoriaId(uuid).isEmpty()) {
			throw new IllegalArgumentException("Não é possível apagar uma categoria já relacionada a uma aula");
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
		return categoriaRepository.findAllByOrderByDataAtualizacaoDesc();
	}

	@Transactional
	public Categoria atualizar(String id, CategoriaRequest categoriaAtualizada) {
		log.warn("Atualizando categoria com ID: {}", id);

		if (id == null || id.isBlank()) {
			throw new IllegalArgumentException("ID da categoria é obrigatório");
		}

		if (categoriaAtualizada == null) {
			throw new IllegalArgumentException("Dados da categoria são obrigatórios");
		}

		UUID uuid;
		try {
			uuid = UUID.fromString(id);
		} catch (IllegalArgumentException ex) {
			throw new IllegalArgumentException("ID da categoria inválido: " + id);
		}

		Categoria categoriaExistente = categoriaRepository.findById(uuid)
				.orElseThrow(() -> new IllegalArgumentException("Categoria não encontrada com ID: " + id));

		if (categoriaAtualizada.getNome() == null || categoriaAtualizada.getNome().isBlank()) {
			throw new IllegalArgumentException("Nome da categoria é obrigatório");
		}

		categoriaExistente.setNome(categoriaAtualizada.getNome());
		categoriaExistente.setPlanos(categoriaAtualizada.getPlanos());

		return categoriaRepository.save(categoriaExistente);
	}

}
