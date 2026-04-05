package grad_project.seasonal_job_matching.services.Notifications;

import java.util.Optional;

import org.springframework.stereotype.Service;

import grad_project.seasonal_job_matching.model.User;
import grad_project.seasonal_job_matching.model.UserDeviceToken;
import grad_project.seasonal_job_matching.repository.DeviceTokenRepository;
import grad_project.seasonal_job_matching.repository.UserRepository;
import jakarta.transaction.Transactional;

@Service
public class DeviceTokenService {

    private final DeviceTokenRepository userDeviceTokenRepository;
    private final UserRepository userRepository;

    public DeviceTokenService(DeviceTokenRepository userDeviceTokenRepository, UserRepository userRepository) {
        this.userDeviceTokenRepository = userDeviceTokenRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public void registerOrUpdateToken(Long userId, String tokenString, String deviceType) {
        User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));

        Optional<UserDeviceToken> existingToken = userDeviceTokenRepository.findByToken(tokenString);

        if (existingToken.isPresent()) {
            // new user logged onto device with an old token, so reassign token to new user
            UserDeviceToken oldExistingToken = existingToken.get();
            if (!oldExistingToken.getUser().getId().equals(userId)) {
                oldExistingToken.setUser(user);
                userDeviceTokenRepository.save(oldExistingToken);
            }
        } else {
            // new device
            UserDeviceToken newToken = new UserDeviceToken();
            newToken.setDeviceType(deviceType);
            newToken.setToken(tokenString);
            newToken.setUser(user);
            userDeviceTokenRepository.save(newToken);
        }
    }

    @Transactional
    public void removeToken(String tokenString) {
        userDeviceTokenRepository.deleteByToken(tokenString);
    }
}
