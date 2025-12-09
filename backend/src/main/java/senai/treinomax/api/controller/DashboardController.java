package senai.treinomax.api.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import senai.treinomax.api.auth.repository.UsuarioRepository;
import senai.treinomax.api.dto.response.DashboardResponse;
import senai.treinomax.api.repository.PlanoCobrancaRepository;
import senai.treinomax.api.repository.PlanoRepository;

import java.time.YearMonth;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
@Slf4j
public class DashboardController {

    private final UsuarioRepository usuarioRepository;
    private final PlanoCobrancaRepository planoCobrancaRepository;
    private final PlanoRepository planoRepository;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<DashboardResponse> getDashboardInfo() {
        try {
            // Get current month and previous month
            YearMonth currentMonth = YearMonth.now();
            YearMonth previousMonth = currentMonth.minusMonths(1);
            
            // Calculate total revenue for current month
            Integer totalRevenueMonthInCents = planoCobrancaRepository
                .sumValorRecebidoPorMes(currentMonth)
                .orElse(0L)
                .intValue();
            
            // Calculate total revenue for previous month
            Integer previousMonthRevenue = planoCobrancaRepository
                .sumValorRecebidoPorMes(previousMonth)
                .orElse(0L)
                .intValue();
            
            // Calculate percentage growth
            Double percentualRevenueGrowthMonth = 0.0;
            if (previousMonthRevenue > 0) {
                percentualRevenueGrowthMonth = ((double) (totalRevenueMonthInCents - previousMonthRevenue) / previousMonthRevenue) * 100;
            } else if (totalRevenueMonthInCents > 0) {
                percentualRevenueGrowthMonth = 100.0;
            }
            
            // Calculate total number of members (users with a plan)
            Integer totalNumberMembers = (int) usuarioRepository.count();
            Integer totalNumberPaidMembers = 0;
            Integer totalNumberUnpaidMembers = 0;
            
            // Calculate user distribution by plan
            Map<String, Double> userDistributionByPlan = new HashMap<>();
            planoRepository.findByAtivoTrue().forEach(plano -> {
                long count = usuarioRepository.countByPlanoId(plano.getId());
                if (count > 0) {
                    double percentage = ((double) count / totalNumberMembers) * 100;
                    userDistributionByPlan.put(plano.getNome(), percentage);
                }
            });
            
            // Create and return dashboard response
            DashboardResponse response = DashboardResponse.builder()
                .totalRenevenueMonthInCents(totalRevenueMonthInCents)
                .percentualRevenueGrowthMonth(percentualRevenueGrowthMonth)
                .totalNumberMembers(totalNumberMembers)
                .totalNumberPaidMembers(totalNumberPaidMembers)
                .totalNumberUnpaidMembers(totalNumberUnpaidMembers)
                .userDistributionByPlan(userDistributionByPlan)
                .build();
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Error fetching dashboard info", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/planos")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<java.util.List<senai.treinomax.api.dto.response.PlanoResponse>> listarPlanosParaRelatorio() {
        try {
            var planos = planoRepository.findAll();
            var resposta = planos.stream()
                .map(plano -> new senai.treinomax.api.dto.response.PlanoResponse(
                    plano.getId(),
                    plano.getNome(),
                    plano.getDescricao(),
                    plano.getAtivo(),
                    plano.getPrecoCentavos()
                ))
                .collect(java.util.stream.Collectors.toList());
            return ResponseEntity.ok(resposta);
        } catch (Exception e) {
            log.error("Erro ao listar planos para relatório", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
}
