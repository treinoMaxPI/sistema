package senai.treinomax.api.controller;

import org.springframework.web.bind.annotation.RestController;

import jakarta.mail.BodyPart;
import jakarta.mail.internet.MimeMessage;
import jakarta.mail.internet.MimeMultipart;
import jakarta.persistence.Access;

import java.time.LocalDateTime;
import java.util.Arrays;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.http.ResponseEntity;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@RestController
public class Controller {

    @ConditionalOnProperty(prefix = "spring.mail", name = "mock.enabled", havingValue = "true", matchIfMissing = false)
    @Bean
    public JavaMailSender mockMailSender() {
        return new JavaMailSenderImpl() {
            @Override
            public void send(SimpleMailMessage simpleMessage) {
                System.out.println("=== Mock Email Sent ===");
                System.out.println("From: " + simpleMessage.getFrom());
                System.out.println("To: " + Arrays.toString(simpleMessage.getTo()));
                System.out.println("Subject: " + simpleMessage.getSubject());
                System.out.println("Text: " + simpleMessage.getText());
                System.out.println("=======================");
            }

            @Override
            public void send(MimeMessage mimeMessage) throws MailException {
                try {
                    System.out.println("=== Mock MIME Email Sent ===");
                    System.out.println("From: " + Arrays.toString(mimeMessage.getFrom()));
                    System.out.println("To: " + Arrays.toString(mimeMessage.getAllRecipients()));
                    System.out.println("Subject: " + mimeMessage.getSubject());
                    System.out.println("--- Email Body ---");
                    printContent(mimeMessage.getContent(), 0);
                    System.out.println("============================");
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            private void printContent(Object content, int level) throws Exception {
                String indent = "  ".repeat(level);
                if (content instanceof MimeMultipart) {
                    MimeMultipart multipart = (MimeMultipart) content;
                    for (int i = 0; i < multipart.getCount(); i++) {
                        BodyPart bodyPart = multipart.getBodyPart(i);
                        System.out.println(indent + "Part " + (i + 1) + " [" + bodyPart.getContentType() + "]:");
                        printContent(bodyPart.getContent(), level + 1);
                    }
                } else if (content instanceof String) {
                    System.out.println(indent + content);
                } else {
                    System.out.println(indent + "Non-text content: " + content.getClass().getName());
                }
            }
        };
    }

    @GetMapping(value = "", produces = "text/html")
    @ResponseBody
    public String status() {
        return """
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>API Status</title>
                <style>
                    body {
                        height: 100vh;
                        margin: 0;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                        color: white;
                        background-color: #121212;
                    }
                    .container {
                        text-align: center;
                    }
                    h1 {
                        font-size: 1.5rem;
                        font-weight: 500;
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>API is running!</h1>
                </div>
            </body>
            </html>
        """;
    }
}