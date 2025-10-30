package senai.treinomax.api.auth.exception;

public class EmailJaCadastradoException extends RuntimeException {

    public EmailJaCadastradoException(String message) {
        super(message);
    }

    public EmailJaCadastradoException(String message, Throwable cause) {
        super(message, cause);
    }
}