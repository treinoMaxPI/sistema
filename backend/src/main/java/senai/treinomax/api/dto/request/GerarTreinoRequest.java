package senai.treinomax.api.dto.request;

import jakarta.validation.constraints.NotEmpty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import senai.treinomax.api.auth.model.GrupoMuscular;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class GerarTreinoRequest {

    @NotEmpty(message = "Lista de tipos de treino não pode estar vazia")
    private List<GrupoMuscular> tiposTreino;
}
