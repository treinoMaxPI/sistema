package senai.treinomax.api.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;
import senai.treinomax.api.auth.repository.UsuarioRepository;
import senai.treinomax.api.repository.PlanoRepository;

@Service
@RequiredArgsConstructor
public class PlanoUsuarioEventosService {
    private static int batchSize = 50; 
    
    private final UsuarioRepository usuarioRepository;
    private final PlanoRepository planoRepository;

    @Transactional
    public void executarCicloMensal() {
        processarInadimplencias();
        gerarNovasCobrancas();
    }

    public void gerarNovasCobrancas() {

    }

    public void processarInadimplencias() {

    }

}
