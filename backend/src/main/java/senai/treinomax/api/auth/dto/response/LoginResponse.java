package senai.treinomax.api.auth.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import senai.treinomax.api.auth.model.Role;

import java.util.Set;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LoginResponse {

    private String token;
    private String refreshToken;
    private String nome;
    private String email;
    private Boolean emailVerificado;
    private Set<Role> roles;
}