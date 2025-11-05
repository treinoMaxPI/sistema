package senai.treinomax.api.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import senai.treinomax.api.model.PlanoCobranca;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlanoCobrancaAdminResponse {
    private UUID id;
    private String usuarioEmail;
    private String usuarioNome;
    private String planoNome;
    private YearMonth mesReferencia;
    private Integer valorCentavos;
    private Boolean inadimplenciaProcessada;
    private Boolean proximaCobrancaGerada;
    private Boolean pago;
    private LocalDate dataVencimento;
    private LocalDate dataPagamento;
    private String observacoes;
    private LocalDateTime dataCriacao;
    private LocalDateTime dataAtualizacao;

    public static PlanoCobrancaAdminResponse fromEntity(PlanoCobranca cobranca) {
        return PlanoCobrancaAdminResponse.builder()
                .id(cobranca.getId())
                .usuarioEmail(cobranca.getUsuario().getEmail())
                .usuarioNome(cobranca.getUsuario().getNome())
                .planoNome(cobranca.getPlano().getNome())
                .mesReferencia(cobranca.getMesReferencia())
                .valorCentavos(cobranca.getValorCentavos())
                .inadimplenciaProcessada(cobranca.getInadimplenciaProcessada())
                .proximaCobrancaGerada(cobranca.getProximaCobrancaGerada())
                .pago(cobranca.getPago())
                .dataVencimento(cobranca.getDataVencimento())
                .dataPagamento(cobranca.getDataPagamento())
                .observacoes(cobranca.getObservacoes())
                .dataCriacao(cobranca.getDataCriacao())
                .dataAtualizacao(cobranca.getDataAtualizacao())
                .build();
    }
}