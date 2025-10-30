package senai.treinomax.api.auth.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class VerificarEmailRequest {

    @NotBlank(message = "Token é obrigatório")
    private String token;
}