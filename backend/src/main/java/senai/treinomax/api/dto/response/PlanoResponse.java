package senai.treinomax.api.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PlanoResponse {
    private UUID id;
    private String nome;
    private String descricao;
    private Boolean ativo;
    private Integer precoCentavos;
}