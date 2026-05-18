package grad_project.seasonal_job_matching.repository;

import java.util.Collection;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import grad_project.seasonal_job_matching.model.Job;
import grad_project.seasonal_job_matching.model.enums.JobStatus;
import grad_project.seasonal_job_matching.model.enums.JobType;
import grad_project.seasonal_job_matching.model.enums.Salary;
import grad_project.seasonal_job_matching.model.enums.WorkArrangement;

//can change all pages to slices to make it even less time since one less query done(query that returns count and extra details in page)
public interface JobRepository extends JpaRepository<Job, Long> {

    @EntityGraph(attributePaths = { "jobPoster" }) // avoids n+1 loading, for each query getting job, avoids another
                                                   // query getting the jobPoster by making one Join and making it one
                                                   // call
    // can be nested and there are 2 types, fetch and load
    // basically does this query @Query("SELECT j FROM Job j JOIN FETCH j.employer
    // WHERE j.status NOT IN :statuses")
    Page<Job> findAllByStatusNotIn(Collection<JobStatus> statuses, Pageable pageable);

    // Searches for title containing the string (case-insensitive)
    // Ensures the status is NOT in the provided list (Draft/Closed)
    @EntityGraph(attributePaths = { "jobPoster" })
    Page<Job> findByTitleContainingIgnoreCaseAndStatusNotIn(String title, Collection<JobStatus> statuses,
            Pageable pageable);

    @EntityGraph(attributePaths = { "jobPoster" })
    @Query("SELECT j FROM Job j WHERE j.status NOT IN :statuses " +
            "AND (:arrangements IS NULL OR j.workArrangement IN :arrangements) " +
            "AND (:jobTypes IS NULL OR j.type IN :jobTypes) " +
            "AND (:salaryTypes IS NULL OR j.salary IN :salaryTypes) " +
            "AND (:location IS NULL OR LOWER(j.location) LIKE LOWER(CAST(CONCAT('%', :location, '%') AS text))) " +
            "AND (:title IS NULL OR LOWER(j.title) LIKE LOWER(CAST(CONCAT('%', :title, '%') AS text)))")
    Page<Job> findJobsWithAdvancedFilters(
            @Param("statuses") Collection<JobStatus> statuses,
            @Param("arrangements") Collection<WorkArrangement> arrangements,
            @Param("jobTypes") Collection<JobType> jobTypes,
            @Param("salaryTypes") Collection<Salary> salaryTypes,
            @Param("location") String location,
            @Param("title") String title,
            Pageable pageable);

    @Modifying
    @Query(value = "DELETE FROM user_favorite_jobs WHERE job_id = :jobId", nativeQuery = true)
    void deleteFromUserFavoriteJobsByJobId(@Param("jobId") Long jobId);
}
