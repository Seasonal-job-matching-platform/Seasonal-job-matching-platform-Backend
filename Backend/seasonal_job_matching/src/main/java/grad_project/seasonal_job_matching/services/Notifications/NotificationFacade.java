package grad_project.seasonal_job_matching.services.Notifications;

import grad_project.seasonal_job_matching.model.User;
import grad_project.seasonal_job_matching.model.UserDeviceToken;
import grad_project.seasonal_job_matching.repository.UserDeviceTokenRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class NotificationFacade {

    private final NotificationService notificationService; // Saves to the 'notifications' table
    private final FCMService fcmService; // Talks to Google Firebase
    // private final EmailService emailService; // Sends Async emails
    private final UserDeviceTokenRepository tokenRepo; // Queries your new Entity

    public NotificationFacade(NotificationService notificationService,
            FCMService fcmService,
            // EmailService emailService,
            UserDeviceTokenRepository tokenRepo) {
        this.notificationService = notificationService;
        this.fcmService = fcmService;
        // this.emailService = emailService;
        this.tokenRepo = tokenRepo;
    }

    @Transactional
    public void dispatchApplicationUpdate(User applicant, String jobTitle, String newStatus) {
        String title = "Application Update";
        String message = "Your application for " + jobTitle + " has been updated to: " + newStatus;

        // 1. Save the historical record to the DB (for the in-app notification bell)
        notificationService.saveNotification(applicant, title, message);

        // 2. Fire off the Email (Runs on a background thread)
        // emailService.sendEmailAlert(applicant.getEmail(), title, message);

        // 3. Fetch all active device tokens for this user
        List<UserDeviceToken> userDevices = tokenRepo.findAllByUser(applicant);

        // 4. Loop through every device (laptop, phone, tablet) and push the
        // notification
        for (UserDeviceToken device : userDevices) {
            fcmService.sendPushNotification(device.getToken(), title, message);
        }
    }
}