package grad_project.seasonal_job_matching.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import grad_project.seasonal_job_matching.model.Resume;

public interface ResumeRepository extends JpaRepository<Resume, Long> {

}
