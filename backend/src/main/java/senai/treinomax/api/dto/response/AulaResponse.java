package senai.treinomax.api.dto.response;

import java.time.LocalDateTime;
import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AulaResponse {
    private UUID id;
    private String titulo;
    private String descricao;
    private String bannerUrl;
    private LocalDateTime data;
    private Integer duracao;
    private CategoriaResponse categoria;
    private String nomePersonal;
}
