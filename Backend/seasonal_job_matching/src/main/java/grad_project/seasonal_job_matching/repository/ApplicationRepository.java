package grad_project.seasonal_job_matching.repository;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import grad_project.seasonal_job_matching.model.Application;

public interface ApplicationRepository extends JpaRepository <Application, Long> {

    @Query("SELECT a FROM Application a JOIN FETCH a.job WHERE a.user.id = :userId")
    List<Application> findByUserId(@Param("userId") long userId);

    @Query(value = "SELECT a FROM Application a JOIN FETCH a.user WHERE a.job.id = :jobId",
           countQuery = "SELECT COUNT(a) FROM Application a WHERE a.job.id = :jobId")
    Page<Application> findByJobId(@Param("jobId") long jobId, Pageable pageable);

    boolean existsByUserIdAndJobId(long userId, long jobId);
}
