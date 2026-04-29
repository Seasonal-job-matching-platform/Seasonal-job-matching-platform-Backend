package grad_project.seasonal_job_matching.services.Notifications;

import jakarta.mail.internet.MimeMessage; // Note: Use javax.mail if on Spring Boot 2.x
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    private final JavaMailSender mailSender;
    private static final Logger logger = LoggerFactory.getLogger(EmailService.class);

    public EmailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    @Async
    public void sendEmailAlert(String recipientEmail, String subject, String htmlBody) {
        try {
            // Upgrade to MimeMessage to support HTML
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom("noreply@seasonaljobmatching.email");
            helper.setTo(recipientEmail);
            helper.setSubject(subject);

            // The 'true' boolean tells it to render as HTML!
            helper.setText(htmlBody, true);

            mailSender.send(message);
            logger.info("Async HTML email successfully sent to {}", recipientEmail);
        } catch (Exception e) {
            logger.error("Failed to send email to {}: {}", recipientEmail, e.getMessage());
        }
    }
}