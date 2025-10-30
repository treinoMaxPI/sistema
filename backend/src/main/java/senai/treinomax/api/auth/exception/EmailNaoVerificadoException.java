package senai.treinomax.api.auth.exception;

import org.springframework.security.authentication.BadCredentialsException;

public class EmailNaoVerificadoException extends BadCredentialsException {
    
    public EmailNaoVerificadoException(String message) {
        super(message);
    }
    
    public EmailNaoVerificadoException(String message, Throwable cause) {
        super(message, cause);
    }
}