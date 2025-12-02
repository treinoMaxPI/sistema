package senai.treinomax.api.model;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import senai.treinomax.api.auth.model.Usuario;
import senai.treinomax.api.util.DateUtils;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "planos")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Plano {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @NotBlank
    @Size(min = 3, max = 100)
    @Column(nullable = false, length = 100)
    private String nome;

    @NotBlank
    @Size(min = 10, max = 1000)
    @Column(nullable = false, length = 1000)
    private String descricao;

    @Column(nullable = false)
    private Boolean ativo = true;

    @Column(nullable = false)
    private Integer precoCentavos = 0;

    @JsonIgnore
    @NotNull
    @ManyToOne
    @JoinColumn(name = "criado_por", nullable = false)
    private Usuario criadoPor;

    @Column(name = "data_criacao", nullable = false, updatable = false)
    private LocalDateTime dataCriacao;

    @Column(name = "data_atualizacao", nullable = false)
    private LocalDateTime dataAtualizacao;

    @PrePersist
    protected void onCreate() {
        dataCriacao = DateUtils.getCurrentBrazilianLocalDateTime();
        dataAtualizacao = DateUtils.getCurrentBrazilianLocalDateTime();
    }

    @PreUpdate
    protected void onUpdate() {
        dataAtualizacao = DateUtils.getCurrentBrazilianLocalDateTime();
    }

}
