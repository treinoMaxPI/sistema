package senai.treinomax.api.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ComunicadoResponse {
    private UUID id;
    private String titulo;
    private String mensagem;
    private Boolean publicado;
    private LocalDateTime dataCriacao;
    private String imagemUrl;
}