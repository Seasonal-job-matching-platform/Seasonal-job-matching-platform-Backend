package grad_project.seasonal_job_matching.services.Notifications;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;

import grad_project.seasonal_job_matching.repository.DeviceTokenRepository;

import org.springframework.stereotype.Service;

@Service
public class FCMService {

    private final DeviceTokenRepository tokenRepository;

    public FCMService(DeviceTokenRepository tokenRepository) {
        this.tokenRepository = tokenRepository;
    }

    public void sendPushNotification(String token, String title, String body) {
        if (token == null || token.isEmpty())
            return;

        try {
            com.google.firebase.messaging.Notification fcmNotification = com.google.firebase.messaging.Notification
                    .builder()
                    .setTitle(title)
                    .setBody(body)
                    .build();

            Message message = Message.builder()
                    .setToken(token)
                    .setNotification(fcmNotification)
                    .build();

            FirebaseMessaging.getInstance().send(message);
        } catch (FirebaseMessagingException e) {
            // THE SELF-CLEANING LOGIC
            String errorCode = e.getErrorCode().name();

            // If Google tells us the token is dead/unregistered, delete it from our DB!
            if ("UNREGISTERED".equals(errorCode) || "INVALID_ARGUMENT".equals(errorCode)) {
                System.out.println("Dead token detected. Removing from database: " + token);
                tokenRepository.deleteByToken(token);
            } else {
                System.err.println("Failed to send FCM: " + e.getMessage());
            }
        } catch (Exception e) {
            System.err.println("Unexpected error sending FCM: " + e.getMessage());
        }
    }
}
