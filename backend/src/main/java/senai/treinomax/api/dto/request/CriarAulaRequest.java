package senai.treinomax.api.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.Future;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.time.LocalTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CriarAulaRequest {

    @NotBlank(message = "Título é obrigatório")
    @Size(min = 3, max = 100, message = "Título deve ter entre 3 e 100 caracteres")
    private String titulo;

    @NotBlank(message = "Descrição é obrigatória")
    @Size(min = 10, max = 1000, message = "Descrição deve ter entre 10 e 1000 caracteres")
    private String descricao;

    @NotNull(message = "Data é obrigatória")
    @Future(message = "Data deve ser futura")
    private LocalDateTime data;

    @NotNull(message = "Duração é obrigatória")
    private LocalTime duracao;

    @NotNull(message = "ID do personal é obrigatório")
    private Integer usuarioPersonalId;

    @NotNull(message = "ID da categoria é obrigatório")
    private Integer categoriaId;
}