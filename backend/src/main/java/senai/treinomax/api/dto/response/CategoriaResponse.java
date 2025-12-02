package senai.treinomax.api.dto.response;

import java.util.List;
import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import senai.treinomax.api.model.Plano;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CategoriaResponse {
    private UUID id;
    private String nome;
    private List<Plano> planos;
}
