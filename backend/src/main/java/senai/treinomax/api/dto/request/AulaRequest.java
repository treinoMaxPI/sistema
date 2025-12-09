package senai.treinomax.api.dto.request;

import java.util.UUID;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AulaRequest {

    @NotBlank(message = "Título é obrigatório")
    @Size(min = 3, max = 100, message = "Título deve ter entre 3 e 100 caracteres")
    private String titulo;

    @NotBlank(message = "Descrição é obrigatória")
    @Size(min = 3, max = 1000, message = "Descrição deve ter entre 3 e 1000 caracteres")
    private String descricao;

    private String bannerUrl;

    @NotNull(message = "Duração é obrigatória")
    private Integer duracao;

    @NotNull(message = "Categoria é obrigatória")
    private UUID categoriaId;

    @NotNull(message = "Agendamento é obrigatório")
    private AgendamentoRequest agendamento;
}
