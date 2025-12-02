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
@RequiredArgsConstructor
@RequestMapping("/api/dashboard")
@Slf4j
public class DashboardController {

    private final UsuarioRepository usuarioRepository;
    private final PlanoCobrancaRepository planoCobrancaRepository;
    private final PlanoRepository planoRepository;

    @GetMapping("/admin")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<DashboardResponse> getDashboardInfo() {
        try {

            YearMonth currentMonth = YearMonth.now();
            YearMonth previousMonth = currentMonth.minusMonths(1);

            Integer totalRevenueMonthInCents = planoCobrancaRepository
                    .sumValorRecebidoPorMes(currentMonth)
                    .orElse(0L)
                    .intValue();

            Integer previousMonthRevenue = planoCobrancaRepository
                    .sumValorRecebidoPorMes(previousMonth)
                    .orElse(0L)
                    .intValue();

            Double percentualRevenueGrowthMonth = 0.0;
            if (previousMonthRevenue > 0) {
                percentualRevenueGrowthMonth = ((double) (totalRevenueMonthInCents - previousMonthRevenue)
                        / previousMonthRevenue) * 100;
            } else if (totalRevenueMonthInCents > 0) {
                percentualRevenueGrowthMonth = 100.0;
            }

            Integer totalNumberMembers = (int) usuarioRepository.count();
            Integer totalNumberPaidMembers = (int) usuarioRepository.countByPlanoIsNotNull();
            Integer totalNumberUnpaidMembers = totalNumberMembers - totalNumberPaidMembers;

            Map<String, Double> userDistributionByPlan = new HashMap<>();
            planoRepository.findByAtivoTrue().forEach(plano -> {
                long count = usuarioRepository.countByPlanoId(plano.getId());
                if (count > 0) {
                    double percentage = ((double) count / totalNumberPaidMembers) * 100;
                    userDistributionByPlan.put(plano.getNome(), percentage);
                }
            });

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

}
