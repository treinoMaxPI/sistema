package senai.treinomax.api.util;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.ZoneId;

public class DateUtils {
    private static final ZoneId BRAZILIAN_ZONE_ID = ZoneId.of("America/Sao_Paulo");

    public static LocalDateTime getCurrentBrazilianLocalDateTime() {
        return LocalDateTime.now(BRAZILIAN_ZONE_ID);
    }    

    public static LocalDate getCurrentBrazilianLocalDate() {
        return LocalDate.now(BRAZILIAN_ZONE_ID);
    }

    public static YearMonth getCurrentBrazilianYearMonth() {
        return YearMonth.now(BRAZILIAN_ZONE_ID);
    }

    public static LocalDate calcularProximoVencimento(int diaDesejado, YearMonth mesAtual) {
        YearMonth proximoMes = mesAtual.plusMonths(1);
        int dia = Math.min(diaDesejado, proximoMes.lengthOfMonth());
        return proximoMes.atDay(dia);
    }

}
