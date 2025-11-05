package senai.treinomax.api.auth.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import senai.treinomax.api.util.DateUtils;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "tokens_verificacao_email")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TokenVerificacaoEmail {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true, length = 255)
    private String token;

    @Column(name = "data_expiracao", nullable = false)
    private LocalDateTime dataExpiracao;

    @Column(nullable = false)
    private Boolean utilizado = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;

    @Column(name = "data_criacao", nullable = false, updatable = false)
    private LocalDateTime dataCriacao;

    @PrePersist
    protected void onCreate() {
        dataCriacao = DateUtils.getCurrentBrazilianLocalDateTime();
    }

    public boolean isExpirado() {
        return DateUtils.getCurrentBrazilianLocalDateTime().isAfter(dataExpiracao);
    }

    public boolean isValido() {
        return !utilizado && !isExpirado();
    }
}