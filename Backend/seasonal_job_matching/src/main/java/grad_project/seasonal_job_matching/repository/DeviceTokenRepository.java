package grad_project.seasonal_job_matching.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import grad_project.seasonal_job_matching.model.User;
import grad_project.seasonal_job_matching.model.UserDeviceToken;

public interface DeviceTokenRepository extends JpaRepository<UserDeviceToken, Long> {

    List<UserDeviceToken> findAllByUser(User user);

    void deleteByToken(String token);

    // Used to check if a token already exists to prevent database crash
    Optional<UserDeviceToken> findByToken(String token);
}
