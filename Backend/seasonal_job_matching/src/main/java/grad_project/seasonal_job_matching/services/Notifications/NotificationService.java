package grad_project.seasonal_job_matching.services.Notifications;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import grad_project.seasonal_job_matching.dto.responses.NotificationResponseDTO;
import grad_project.seasonal_job_matching.mapper.NotificationMapper;
import grad_project.seasonal_job_matching.model.Notification;
import grad_project.seasonal_job_matching.model.User;
import grad_project.seasonal_job_matching.repository.NotificationRepository;

@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final NotificationMapper notificationMapper;

    public NotificationService(NotificationRepository notificationRepository, NotificationMapper notificationMapper) {
        this.notificationRepository = notificationRepository;
        this.notificationMapper = notificationMapper;
    }

    public void saveNotification(User recipient, String title, String message) {
        Notification notification = new Notification();
        notification.setMessage(message);
        notification.setTitle(title);
        notification.setRecipient(recipient);

        notificationRepository.save(notification);
    }

    public Page<NotificationResponseDTO> getNotificationsPaged(int page, Long userId) {
        Pageable pageable = PageRequest.of(page, 50, Sort.by(Sort.Direction.DESC, "createdAt"));

        Page<Notification> notifications = notificationRepository.findByRecipientIdOrderByCreatedAtDesc(userId, pageable);

        return notifications.map(notification -> notificationMapper.maptoreturnNotification(notification));

    }
}
