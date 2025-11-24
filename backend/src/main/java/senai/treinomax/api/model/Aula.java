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
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
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


@Entity
@Table(name = "aulas")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Aula {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;


@NotBlank
    @Size(min = 3, max = 100)
    @Column(nullable = false, length = 100)
    private String titulo;

    @NotBlank
    @Size(min = 10, max = 1000)
    @Column(nullable = false, length = 1000)
    private String descricao;

    @NotBlank
    @Column(nullable = false)
    private LocalDateTime data;

    @NotBlank
    @Column(nullable = false, columnDefinition = "integer default 0")
    private Integer duracao;

    @NotNull
    @ManyToOne
    @JoinColumn(name = "usuario_personal_id", nullable = false)
    private Usuario usuarioPersonal;

    @ManyToOne
    @JoinColumn(name = "categoria_id", nullable = false)
    private Categoria categoria;
    
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








