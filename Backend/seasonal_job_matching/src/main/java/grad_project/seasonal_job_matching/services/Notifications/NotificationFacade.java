package grad_project.seasonal_job_matching.services.Notifications;

import grad_project.seasonal_job_matching.dto.requests.ApplicationStatusUpdateDTO;
import grad_project.seasonal_job_matching.model.User;
import grad_project.seasonal_job_matching.model.UserDeviceToken;
import grad_project.seasonal_job_matching.repository.DeviceTokenRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class NotificationFacade {

    private final NotificationService notificationService; // Saves to the 'notifications' table
    private final FCMService fcmService; // Talks to Google Firebase
    private final EmailService emailService; // Sends Async emails
    private final DeviceTokenRepository tokenRepo; // Queries your new Entity

    public NotificationFacade(NotificationService notificationService,
            FCMService fcmService,
            EmailService emailService,
            DeviceTokenRepository tokenRepo) {
        this.notificationService = notificationService;
        this.fcmService = fcmService;
        this.emailService = emailService;
        this.tokenRepo = tokenRepo;
    }

    @Transactional
    public void dispatchApplicationUpdate(User applicant, String employerName, Long applicationId,
            ApplicationStatusUpdateDTO dto) {
        String title = "Application Update";
        String message = buildNotificationMessage(employerName, applicant.getName(), applicationId, dto);

        // 1. Save the historical record to the DB (for the in-app notification bell)
        notificationService.saveNotification(applicant, title, message);

        if (Boolean.TRUE.equals(applicant.getWantsEmails())) {
            // 2. Fire off the Email (Runs on a background thread)
            emailService.sendEmailAlert(applicant.getEmail(), title, message);
        }

        // 3. Fetch all active device tokens for this user
        List<UserDeviceToken> userDevices = tokenRepo.findAllByUser(applicant);

        // 4. Loop through every device (laptop, phone, tablet) and push the
        // notification
        for (UserDeviceToken device : userDevices) {
            fcmService.sendPushNotification(device.getToken(), title, message);
        }
    }

    // Helper method to create fixed messages with placeholders
    private String buildNotificationMessage(String employerName, String applicantName, Long applicationId,
            ApplicationStatusUpdateDTO dto) {
        switch (dto.getStatus().toString()) {
            case "ACCEPTED":
                return String.format("Hello %s, congratulations! Your application (#%d) has been ACCEPTED by %s.",
                        applicantName, applicationId, employerName);

            case "REJECTED":
                return String.format("Hello %s, unfortunately your application (#%d) has been DECLINED by %s.",
                        applicantName, applicationId, employerName);

            case "INTERVIEW_SCHEDULED":
                StringBuilder sb = new StringBuilder();
                sb.append(String.format("Hello %s, %s has scheduled an INTERVIEW for your application (#%d).",
                        applicantName, employerName, applicationId));

                if (dto.getInterviewDate() != null) {
                    sb.append(" Date: ").append(dto.getInterviewDate());
                }
                if (dto.getInterviewTime() != null) {
                    sb.append(" Time: ").append(dto.getInterviewTime());
                }
                if (dto.getInterviewLocation() != null && !dto.getInterviewLocation().isEmpty()) {
                    sb.append(" Location: ").append(dto.getInterviewLocation());
                }
                return sb.toString();

            case "PENDING":
            default:
                return String.format("Hello %s, the status of your application (#%d) with %s is now %s.",
                        applicantName, applicationId, employerName, dto.getStatus().name());
        }
    }
}