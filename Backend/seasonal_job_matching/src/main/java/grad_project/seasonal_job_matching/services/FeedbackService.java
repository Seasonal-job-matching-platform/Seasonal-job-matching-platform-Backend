package grad_project.seasonal_job_matching.services;

import grad_project.seasonal_job_matching.dto.requests.FeedbackCreateDTO;
import grad_project.seasonal_job_matching.services.Notifications.EmailService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class FeedbackService {

    private final EmailService emailService;
    private final String recipientEmail;
    private final StringRedisTemplate redisTemplate;
    
    // Thread-safe in-memory rate limiting fallback if Redis is down/unavailable
    private final ConcurrentHashMap<String, List<Long>> localLimits = new ConcurrentHashMap<>();

    public FeedbackService(EmailService emailService,
            StringRedisTemplate redisTemplate,
            @Value("${support.feedback.email:support@seasonaljobmatching.com}") String recipientEmail) {
        this.emailService = emailService;
        this.redisTemplate = redisTemplate;
        this.recipientEmail = recipientEmail;
    }

    public void sendFeedback(FeedbackCreateDTO dto, String ipAddress) {
        // Apply rate limits before processing the feedback email
        checkRateLimit(ipAddress);

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

    private void checkRateLimit(String ipAddress) {
        try {
            String minKey = "rate_limit:feedback:min:" + ipAddress;
            String dayKey = "rate_limit:feedback:day:" + ipAddress;

            Long minCount = redisTemplate.opsForValue().increment(minKey);
            if (minCount != null && minCount == 1) {
                redisTemplate.expire(minKey, Duration.ofMinutes(1));
            }

            Long dayCount = redisTemplate.opsForValue().increment(dayKey);
            if (dayCount != null && dayCount == 1) {
                redisTemplate.expire(dayKey, Duration.ofDays(1));
            }

            if (minCount != null && minCount > 3) {
                throw new RuntimeException("Too many feedback requests. Please wait a minute.");
            }
            if (dayCount != null && dayCount > 10) {
                throw new RuntimeException("Daily limit exceeded. Please try again tomorrow.");
            }
        } catch (Exception e) {
            // If it's our rate limit message, rethrow it
            if (e.getMessage() != null && e.getMessage().contains("limit")) {
                throw e;
            }
            // Otherwise, it is a Redis connection/query error; fall back to local limit
            System.err.println("Redis rate limiting failed. Falling back to local in-memory: " + e.getMessage());
            checkRateLimitLocal(ipAddress);
        }
    }

    private void checkRateLimitLocal(String ipAddress) {
        long now = System.currentTimeMillis();
        long oneMinuteAgo = now - 60000;
        long twentyFourHoursAgo = now - 24 * 60 * 60 * 1000L;

        List<Long> timestamps = localLimits.computeIfAbsent(ipAddress, k -> new ArrayList<>());
        synchronized (timestamps) {
            // Remove timestamps older than 24 hours
            timestamps.removeIf(t -> t < twentyFourHoursAgo);

            long minCount = timestamps.stream().filter(t -> t >= oneMinuteAgo).count();
            long dayCount = timestamps.size();

            if (minCount >= 3) {
                throw new RuntimeException("Too many feedback requests. Please wait a minute.");
            }
            if (dayCount >= 10) {
                throw new RuntimeException("Daily limit exceeded. Please try again tomorrow.");
            }
            timestamps.add(now);
        }
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
