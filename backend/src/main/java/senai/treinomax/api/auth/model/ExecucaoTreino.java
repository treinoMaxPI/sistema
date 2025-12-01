package senai.treinomax.api.auth.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import senai.treinomax.api.util.DateUtils;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "execucoes_treino")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ExecucaoTreino {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "treino_id", nullable = false)
    @JsonIgnoreProperties({ "itens", "usuario" })
    private Treino treino;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id", nullable = false)
    @JsonIgnoreProperties({ "senha", "roles", "plano", "proximoPlano", "dataCriacao", "dataAtualizacao" })
    private Usuario usuario;

    @Column(name = "data_inicio", nullable = false, updatable = false)
    private LocalDateTime dataInicio;

    @Column(name = "data_fim")
    private LocalDateTime dataFim;

    @Column(nullable = false)
    private Boolean finalizada = false;

    @Column(name = "duracao_segundos")
    private Integer duracaoSegundos;

    @Column(name = "data_criacao", nullable = false, updatable = false)
    private LocalDateTime dataCriacao;

    @PrePersist
    protected void onCreate() {
        if (dataCriacao == null) {
            dataCriacao = DateUtils.getCurrentBrazilianLocalDateTime();
        }
        if (dataInicio == null) {
            dataInicio = DateUtils.getCurrentBrazilianLocalDateTime();
        }
    }

    public void finalizar() {
        this.finalizada = true;
        this.dataFim = DateUtils.getCurrentBrazilianLocalDateTime();
        if (this.dataInicio != null && this.dataFim != null) {
            this.duracaoSegundos = (int) java.time.Duration.between(this.dataInicio, this.dataFim).getSeconds();
        }
    }
}

