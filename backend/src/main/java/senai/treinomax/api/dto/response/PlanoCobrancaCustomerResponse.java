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
public class PlanoCobrancaCustomerResponse {
    private UUID id;
    private String planoNome;
    private YearMonth mesReferencia;
    private Integer valorCentavos;
    private Boolean pago;
    private LocalDate dataVencimento;
    private LocalDate dataPagamento;
    private String observacoes;
    private LocalDateTime dataCriacao;
    private LocalDateTime dataAtualizacao;

    public static PlanoCobrancaCustomerResponse fromEntity(PlanoCobranca cobranca) {
        return PlanoCobrancaCustomerResponse.builder()
                .id(cobranca.getId())
                .planoNome(cobranca.getPlano().getNome())
                .mesReferencia(cobranca.getMesReferencia())
                .valorCentavos(cobranca.getValorCentavos())
                .pago(cobranca.getPago())
                .dataVencimento(cobranca.getDataVencimento())
                .dataPagamento(cobranca.getDataPagamento())
                .observacoes(cobranca.getObservacoes())
                .dataCriacao(cobranca.getDataCriacao())
                .dataAtualizacao(cobranca.getDataAtualizacao())
                .build();
    }
}