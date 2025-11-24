package senai.treinomax.api.auth.service;

import senai.treinomax.api.auth.model.Usuario;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;
import org.springframework.boot.autoconfigure.mail.MailSenderAutoConfiguration;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;
    private final TemplateEngine templateEngine;

    @Value("${spring.mail.username}")
    private String fromEmail;

    @Value("${app.frontend.url:http://localhost:4200}")
    private String frontendUrl;

    @Value("${server.port:8080}")
    private String serverPort;

    @Value("${app.email.verification-url:/verify-email}")
    private String verificationUrl;

    @Value("${app.email.reset-password-url:/reset-password}")
    private String resetPasswordUrl;

    @Async
    public void enviarEmailVerificacao(Usuario usuario, String token) {
        try {
            // Use backend URL for email verification (web page that redirects to frontend)
            String verificationLink = "http://localhost:" + serverPort + "/verify-email?token=" + token;
            
            Context context = new Context();
            context.setVariable("nome", usuario.getNome());
            context.setVariable("verificationLink", verificationLink);
            context.setVariable("token", token);

            String htmlContent = templateEngine.process("email-verificacao", context);

            enviarEmail(
                usuario.getEmail(),
                "Verifique seu email - TreinoMax",
                htmlContent
            );

            log.info("Email de verificação enviado para: {}", usuario.getEmail());
        } catch (Exception e) {
            log.error("Erro ao enviar email de verificação para: {}", usuario.getEmail(), e);
            throw new RuntimeException("Falha ao enviar email de verificação", e);
        }
    }

    @Async
    public void enviarEmailRecuperacaoSenha(Usuario usuario, String token) {
        try {
            String resetLink = frontendUrl + resetPasswordUrl + "?token=" + token;
            
            Context context = new Context();
            context.setVariable("nome", usuario.getNome());
            context.setVariable("resetLink", resetLink);
            context.setVariable("token", token);

            String htmlContent = templateEngine.process("email-recuperacao-senha", context);

            enviarEmail(
                usuario.getEmail(),
                "Recuperação de Senha - TreinoMax",
                htmlContent
            );

            log.info("Email de recuperação de senha enviado para: {}", usuario.getEmail());
        } catch (Exception e) {
            log.error("Erro ao enviar email de recuperação de senha para: {}", usuario.getEmail(), e);
            throw new RuntimeException("Falha ao enviar email de recuperação de senha", e);
        }
    }

    @Async
    public void enviarEmailConfirmacaoResetSenha(Usuario usuario) {
        try {
            Context context = new Context();
            context.setVariable("nome", usuario.getNome());

            String htmlContent = templateEngine.process("email-confirmacao-reset-senha", context);

            enviarEmail(
                usuario.getEmail(),
                "Senha Alterada com Sucesso - TreinoMax",
                htmlContent
            );

            log.info("Email de confirmação de reset de senha enviado para: {}", usuario.getEmail());
        } catch (Exception e) {
            log.error("Erro ao enviar email de confirmação de reset de senha para: {}", usuario.getEmail(), e);
            throw new RuntimeException("Falha ao enviar email de confirmação de reset de senha", e);
        }
    }

    private void enviarEmail(String to, String subject, String htmlContent) throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

        helper.setFrom(fromEmail);
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(htmlContent, true);

        mailSender.send(message);
    }
}