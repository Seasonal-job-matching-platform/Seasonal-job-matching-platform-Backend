package grad_project.seasonal_job_matching.controller;

import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import grad_project.seasonal_job_matching.security.CurrentUserService;
import grad_project.seasonal_job_matching.services.Notifications.NotificationService;
import jakarta.servlet.http.HttpServletRequest;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    final private NotificationService notificationService;
    final private CurrentUserService currentUserService;

    public NotificationController(NotificationService notificationService, CurrentUserService currentUserService) {
        this.notificationService = notificationService;
        this.currentUserService = currentUserService;
    }

    @GetMapping("/{userId}")
    public ResponseEntity<?> findAll(@RequestParam(defaultValue = "0") int page, @PathVariable Long userId,
            HttpServletRequest request) {
        Long currentUserId = currentUserService.getCurrentUserId(request);
        
        if (currentUserId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Login first"));
        }
        
        if (!currentUserId.equals(userId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Forbidden to check notifications of other users"));
        }
        
        return ResponseEntity.ok(notificationService.getNotificationsPaged(page, currentUserId));
    }
}
