package senai.treinomax.api.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CriarComunicadoRequest {
    @NotBlank
    @Size(min = 3, max = 200)
    private String titulo;

    @NotBlank
    private String mensagem;

    private Boolean publicado = true;

    private String imagemUrl;
}