package grad_project.seasonal_job_matching.services;

import grad_project.seasonal_job_matching.dto.requests.FeedbackCreateDTO;
import grad_project.seasonal_job_matching.services.Notifications.EmailService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class FeedbackService {

    private final EmailService emailService;
    private final String recipientEmail;

    public FeedbackService(EmailService emailService,
            @Value("${support.feedback.email:support@seasonaljobmatching.com}") String recipientEmail) {
        this.emailService = emailService;
        this.recipientEmail = recipientEmail;
    }

    public void sendFeedback(FeedbackCreateDTO dto) {
        String subject = "New Feedback/Error Report: " + dto.getTitle();
        
        // Escape special HTML characters to prevent XSS injection in support email client
        String sanitizedBody = escapeHtml(dto.getBody());
        String senderEmail = dto.getUserEmail() != null && !dto.getUserEmail().trim().isEmpty()
                ? escapeHtml(dto.getUserEmail())
                : "Anonymous User";

        String htmlBody = String.format(
                "<h3>New Support & Feedback Report</h3>" +
                "<p><strong>Subject/Title:</strong> %s</p>" +
                "<p><strong>From Sender:</strong> %s</p>" +
                "<hr/>" +
                "<p><strong>Message Body:</strong></p>" +
                "<div style=\"background-color: #f9f9f9; padding: 15px; border-radius: 5px; border: 1px solid #eee; white-space: pre-wrap; font-family: sans-serif;\">%s</div>",
                escapeHtml(dto.getTitle()),
                senderEmail,
                sanitizedBody
        );

        emailService.sendEmailAlert(recipientEmail, subject, htmlBody);
    }

    private String escapeHtml(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#x27;");
    }
}
