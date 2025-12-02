package senai.treinomax.api.service;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import senai.treinomax.api.auth.model.Usuario;
import senai.treinomax.api.auth.service.UsuarioService;
import senai.treinomax.api.dto.request.AulaRequest;
import senai.treinomax.api.model.Agendamento;
import senai.treinomax.api.model.Aula;
import senai.treinomax.api.model.Categoria;
import senai.treinomax.api.repository.AulaRepository;
import senai.treinomax.api.repository.CategoriaRepository;

@Service
@RequiredArgsConstructor
@Slf4j
public class AulaService {

    private final AulaRepository aulaRepository;
    private final UsuarioService usuarioService;
    private final CategoriaRepository categoriaRepository;

    /**
     * Salva (cria) uma aula.
     */
    @Transactional
    public Aula salvar(AulaRequest request, UUID usuarioId) {
        log.info("Salvando aula: {}", request.getTitulo());

        Usuario usuario = usuarioService.buscarPorId(usuarioId);
        Categoria categoria = categoriaRepository.findById(request.getCategoriaId())
                .orElseThrow(() -> new RuntimeException("Categoria não encontrada: " + request.getCategoriaId()));

        Aula aula = new Aula();
        aula.setTitulo(request.getTitulo());
        aula.setDescricao(request.getDescricao());
        aula.setBannerUrl(request.getBannerUrl());
        aula.setDuracao(request.getDuracao());
        aula.setCategoria(categoria);
        aula.setUsuarioPersonal(usuario);
        aula.setCriadoPor(usuario);

        Agendamento agendamento = new Agendamento();
        agendamento.setRecorrente(request.getAgendamento().getRecorrente());
        agendamento.setHorarioRecorrente(request.getAgendamento().getHorarioRecorrente());
        agendamento.setSegunda(request.getAgendamento().getSegunda());
        agendamento.setTerca(request.getAgendamento().getTerca());
        agendamento.setQuarta(request.getAgendamento().getQuarta());
        agendamento.setQuinta(request.getAgendamento().getQuinta());
        agendamento.setSexta(request.getAgendamento().getSexta());
        agendamento.setSabado(request.getAgendamento().getSabado());
        agendamento.setDomingo(request.getAgendamento().getDomingo());
        agendamento.setDataExata(request.getAgendamento().getDataExata());
        agendamento.setAula(aula);

        aula.setAgendamento(agendamento);

        return aulaRepository.save(aula);
    }

    /**
     * Atualiza uma aula existente.
     */
    @Transactional
    public Aula atualizar(String id, AulaRequest request) {
        log.info("Atualizando aula: {}", id);

        Aula aula = buscarPorId(id);

        Categoria categoria = categoriaRepository.findById(request.getCategoriaId())
                .orElseThrow(() -> new RuntimeException("Categoria não encontrada: " + request.getCategoriaId()));

        aula.setTitulo(request.getTitulo());
        aula.setDescricao(request.getDescricao());
        aula.setBannerUrl(request.getBannerUrl());
        aula.setDuracao(request.getDuracao());
        aula.setCategoria(categoria);

        // Update Agendamento
        Agendamento agendamento = aula.getAgendamento();
        if (agendamento == null) {
            agendamento = new Agendamento();
            agendamento.setAula(aula);
            aula.setAgendamento(agendamento);
        }
        agendamento.setRecorrente(request.getAgendamento().getRecorrente());
        agendamento.setHorarioRecorrente(request.getAgendamento().getHorarioRecorrente());
        agendamento.setSegunda(request.getAgendamento().getSegunda());
        agendamento.setTerca(request.getAgendamento().getTerca());
        agendamento.setQuarta(request.getAgendamento().getQuarta());
        agendamento.setQuinta(request.getAgendamento().getQuinta());
        agendamento.setSexta(request.getAgendamento().getSexta());
        agendamento.setSabado(request.getAgendamento().getSabado());
        agendamento.setDomingo(request.getAgendamento().getDomingo());
        agendamento.setDataExata(request.getAgendamento().getDataExata());

        return aulaRepository.save(aula);
    }

    /**
     * Busca uma aula pelo id (String UUID).
     */
    @Transactional(readOnly = true)
    public Aula buscarPorId(String id) {
        UUID uuid;
        try {
            uuid = UUID.fromString(id);
        } catch (IllegalArgumentException ex) {
            log.warn("ID inválido ao buscar aula: {}", id);
            throw new RuntimeException("ID inválido: " + id, ex);
        }
        Optional<Aula> opt = aulaRepository.findById(uuid);
        return opt.orElseThrow(() -> {
            log.warn("Aula não encontrada: {}", id);
            return new RuntimeException("Aula não encontrada: " + id);
        });
    }

    /**
     * Lista todas as aulas.
     */
    @Transactional(readOnly = true)
    public List<Aula> listarTodas() {
        return aulaRepository.findAll();
    }

    /**
     * Deleta uma aula por id.
     */
    @Transactional
    public void deletarPorId(String id) {
        UUID uuid;
        try {
            uuid = UUID.fromString(id);
        } catch (IllegalArgumentException ex) {
            log.warn("ID inválido ao deletar aula: {}", id);
            throw new RuntimeException("ID inválido: " + id, ex);
        }
        if (!aulaRepository.existsById(uuid)) {
            log.warn("Tentativa de deletar aula inexistente: {}", id);
            throw new RuntimeException("Aula não encontrada: " + id);
        }
        aulaRepository.deleteById(uuid);
        log.info("Aula deletada: {}", id);
    }

    /**
     * Armazena imagem de aula em disco em "uploads/aulas" e retorna o path relativo
     * que pode ser exposto pela API.
     * Ex.: /uploads/aulas/{filename}
     */
    public String salvarImagem(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new RuntimeException("Arquivo vazio");
        }

        try {
            Path uploadDir = Paths.get("uploads", "aulas");
            Files.createDirectories(uploadDir);

            String original = file.getOriginalFilename();
            String ext = extension(original);
            String filename = UUID.randomUUID().toString() + (ext.isEmpty() ? "" : "." + ext);
            Path target = uploadDir.resolve(filename);

            try (InputStream in = file.getInputStream()) {
                Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
            }

            String relative = "/uploads/aulas/" + filename;
            log.info("Imagem salva em {}", relative);
            return relative;
        } catch (IOException e) {
            log.error("Erro ao salvar imagem de aula", e);
            throw new RuntimeException("Erro ao salvar imagem", e);
        }
    }

    private String extension(String name) {
        if (name == null)
            return "";
        int idx = name.lastIndexOf('.');
        if (idx == -1)
            return "";
        return name.substring(idx + 1);
    }
}