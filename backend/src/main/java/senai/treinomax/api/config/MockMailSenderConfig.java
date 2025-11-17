package senai.treinomax.api.config;

import java.util.Arrays;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import jakarta.mail.BodyPart;
import jakarta.mail.internet.MimeMessage;
import jakarta.mail.internet.MimeMultipart;

@Configuration
public class MockMailSenderConfig {
    private static final Logger logger = LoggerFactory.getLogger(MockMailSenderConfig.class);

    @ConditionalOnProperty(prefix = "spring.mail", name = "mock.enabled", havingValue = "true", matchIfMissing = false)
    @Bean
    public JavaMailSender mockMailSender() {
        return new JavaMailSenderImpl() {
            @Override
            public void send(SimpleMailMessage simpleMessage) {
                logger.info("=== Mock Email Sent ===");
                logger.info("From: {}", simpleMessage.getFrom());
                logger.info("To: {}", Arrays.toString(simpleMessage.getTo()));
                logger.info("Subject: {}", simpleMessage.getSubject());
                logger.info("Text: {}", simpleMessage.getText());
                logger.info("=======================");
            }

            @Override
            public void send(MimeMessage mimeMessage) throws MailException {
                try {
                    logger.info("=== Mock MIME Email Sent ===");
                    logger.info("From: {}", Arrays.toString(mimeMessage.getFrom()));
                    logger.info("To: {}", Arrays.toString(mimeMessage.getAllRecipients()));
                    logger.info("Subject: {}", mimeMessage.getSubject());
                    logger.info("--- Email Body ---");
                    printContent(mimeMessage.getContent(), 0);
                    logger.info("============================");
                } catch (Exception e) {
                    logger.error("Error sending MIME email", e);
                }
            }

            @Override
            public void send(MimeMessage... mimeMessages) throws MailException {
                for (MimeMessage msg : mimeMessages) {
                    send(msg);
                }
            }

            private void printContent(Object content, int level) throws Exception {
                String indent = "  ".repeat(level);
                if (content instanceof MimeMultipart) {
                    MimeMultipart multipart = (MimeMultipart) content;
                    for (int i = 0; i < multipart.getCount(); i++) {
                        BodyPart bodyPart = multipart.getBodyPart(i);
                        logger.info("{}Part {} [{}]:", indent, (i + 1), bodyPart.getContentType());
                        printContent(bodyPart.getContent(), level + 1);
                    }
                } else if (content instanceof String) {
                    logger.info("{}{}", indent, content);
                } else {
                    logger.info("{}Non-text content: {}", indent, content.getClass().getName());
                }
            }
        };
    }
}
