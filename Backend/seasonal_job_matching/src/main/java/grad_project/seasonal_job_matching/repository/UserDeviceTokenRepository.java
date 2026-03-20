package grad_project.seasonal_job_matching.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import grad_project.seasonal_job_matching.model.User;
import grad_project.seasonal_job_matching.model.UserDeviceToken;

public interface UserDeviceTokenRepository extends JpaRepository<UserDeviceToken, Long> {

    List<UserDeviceToken> findAllByUser(User user);

    void deleteByToken(String token);
}
