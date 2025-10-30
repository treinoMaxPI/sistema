package senai.treinomax.api.auth.exception;

public class TokenExpiradoException extends RuntimeException {
    
    public TokenExpiradoException(String message) {
        super(message);
    }
    
    public TokenExpiradoException(String message, Throwable cause) {
        super(message, cause);
    }
}