package senai.treinomax.api.model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import senai.treinomax.api.auth.model.Usuario;
import senai.treinomax.api.util.DateUtils;

@Entity
@Table(
    name = "planos_cobrancas",
    uniqueConstraints = @UniqueConstraint(
        columnNames = {"usuario_id", "mes_referencia"}
    )
)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlanoCobranca {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @NotNull
    @ManyToOne
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;

    @NotNull
    @ManyToOne
    @JoinColumn(name = "plano_id", nullable = false)
    private Plano plano;

    @Column(nullable = false)
    private YearMonth mesReferencia;

    @Column(nullable = false)
    private Integer valorCentavos;

    @Column(name = "inadimplencia_processada", nullable = false)
    @Builder.Default
    private Boolean inadimplenciaProcessada = false;

    @Column(nullable = false)
    @Builder.Default
    private Boolean pago = false;

    @Column(name = "data_vencimento", nullable = false)
    private LocalDate dataVencimento;

    @Column(name = "data_pagamento")
    private LocalDate dataPagamento;

    @Column(length = 500, nullable = true)
    private String observacoes;

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
