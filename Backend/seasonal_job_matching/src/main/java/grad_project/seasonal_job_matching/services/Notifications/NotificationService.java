package grad_project.seasonal_job_matching.services.Notifications;

import org.springframework.stereotype.Service;

import grad_project.seasonal_job_matching.model.Notification;
import grad_project.seasonal_job_matching.model.User;
import grad_project.seasonal_job_matching.repository.NotificationRepository;

@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;

    public NotificationService(NotificationRepository notificationRepository) {
        this.notificationRepository = notificationRepository;
    }

    public void saveNotification(User recipient, String title, String message) {
        Notification notification = new Notification();
        notification.setMessage(message);
        notification.setTitle(title);
        notification.setRecipient(recipient);

        notificationRepository.save(notification);
    }
}
