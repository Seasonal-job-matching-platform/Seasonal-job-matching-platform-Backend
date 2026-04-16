package grad_project.seasonal_job_matching.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.springframework.context.annotation.Configuration;
import javax.annotation.PostConstruct;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

@Configuration
public class FirebaseConfig {

    @PostConstruct
    public void initialize() {
        try {
            InputStream serviceAccount;
            String firebaseEnv = System.getenv("FIREBASE_CREDENTIALS");

            // If we are on Heroku, read from the Config Var
            if (firebaseEnv != null && !firebaseEnv.isEmpty()) {
                serviceAccount = new ByteArrayInputStream(firebaseEnv.getBytes(StandardCharsets.UTF_8));
            }
            // If we are on Localhost, read from the file
            else {
                serviceAccount = getClass().getResourceAsStream("/firebase-service-account.json");
            }

            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();

            if (FirebaseApp.getApps().isEmpty()) {
                FirebaseApp.initializeApp(options);
                System.out.println("Firebase Admin SDK initialized successfully!");
            }
        } catch (Exception e) {
            System.err.println("Firebase initialization failed: " + e.getMessage());
        }
    }
}