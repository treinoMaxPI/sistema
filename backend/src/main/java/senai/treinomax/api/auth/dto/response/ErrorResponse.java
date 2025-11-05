package senai.treinomax.api.auth.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import senai.treinomax.api.util.DateUtils;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ErrorResponse {

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime timestamp;
    
    private int status;
    
    private String error;
    
    private String message;
    
    private String path;

    public ErrorResponse(int status, String error, String message, String path) {
        this.timestamp = DateUtils.getCurrentBrazilianLocalDateTime();
        this.status = status;
        this.error = error;
        this.message = message;
        this.path = path;
    }
}