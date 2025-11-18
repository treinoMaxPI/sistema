package senai.treinomax.api.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import senai.treinomax.api.auth.model.Usuario;
import senai.treinomax.api.auth.service.UsuarioService;
import senai.treinomax.api.dto.request.AtualizarComunicadoRequest;
import senai.treinomax.api.dto.request.CriarComunicadoRequest;
import senai.treinomax.api.model.Comunicado;
import senai.treinomax.api.repository.ComunicadoRepository;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class MuralService {
    private final ComunicadoRepository comunicadoRepository;
    private final UsuarioService usuarioService;

    @Transactional
    public Comunicado criar(CriarComunicadoRequest request, UUID criadoPorId) {
        Usuario criador = usuarioService.buscarPorId(criadoPorId);

        Comunicado c = new Comunicado();
        c.setTitulo(request.getTitulo());
        c.setMensagem(request.getMensagem());
        c.setImagemUrl(request.getImagemUrl());
        c.setPublicado(request.getPublicado() != null ? request.getPublicado() : true);
        c.setCriadoPor(criador);
        Comunicado salvo = comunicadoRepository.save(c);
        log.info("Comunicado criado: {} (id: {})", salvo.getTitulo(), salvo.getId());
        return salvo;
    }

    public List<Comunicado> listarPublicados() {
        return comunicadoRepository.findByPublicadoTrueOrderByDataCriacaoDesc();
    }

    public List<Comunicado> listarTodos() {
        return comunicadoRepository.findAllOrderByDataCriacaoDesc();
    }

    public Comunicado buscarPorId(UUID id) {
        return comunicadoRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Comunicado não encontrado: " + id));
    }

    @Transactional
    public Comunicado atualizar(UUID id, AtualizarComunicadoRequest request) {
        Comunicado existente = buscarPorId(id);
        existente.setTitulo(request.getTitulo());
        existente.setMensagem(request.getMensagem());
        existente.setImagemUrl(request.getImagemUrl());
        return comunicadoRepository.save(existente);
    }

    @Transactional
    public void alterarStatus(UUID id, boolean publicado) {
        comunicadoRepository.atualizarStatusPublicado(id, publicado);
    }

    @Transactional
    public void excluir(UUID id) {
        Comunicado existente = buscarPorId(id);
        comunicadoRepository.delete(existente);
    }
}