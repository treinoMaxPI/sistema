package senai.treinomax.api.dto.response;

import java.util.Map;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DashboardResponse {
    private Integer totalRenevenueMonthInCents;
    private Double percentualRevenueGrowthMonth; // 2.12 means 2.12%
    private Integer totalNumberMembers;
    private Integer totalNumberPaidMembers;
    private Integer totalNumberUnpaidMembers;
    private Map<String, Double> userDistributionByPlan;
}
