package grad_project.seasonal_job_matching.services;

import grad_project.seasonal_job_matching.dto.requests.ApplicationCreateDTO;
import grad_project.seasonal_job_matching.dto.requests.ApplicationStatusUpdateDTO;
import grad_project.seasonal_job_matching.dto.responses.ApplicationResponseDTO;
import grad_project.seasonal_job_matching.dto.responses.ApplicationWebResponseDTO;
import grad_project.seasonal_job_matching.dto.responses.JobIdsFromApplicationsResponseDTO;
import grad_project.seasonal_job_matching.mapper.ApplicationMapper;
import grad_project.seasonal_job_matching.model.Application;
import grad_project.seasonal_job_matching.model.Job;
import grad_project.seasonal_job_matching.model.User;
import grad_project.seasonal_job_matching.model.enums.ApplicationStatus;
import grad_project.seasonal_job_matching.repository.ApplicationRepository;
import grad_project.seasonal_job_matching.repository.JobRepository;
import grad_project.seasonal_job_matching.repository.UserRepository;
import grad_project.seasonal_job_matching.services.Notifications.NotificationFacade;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Date;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ApplicationService {

    private final ApplicationRepository applicationRepository;
    private final UserRepository userRepository;
    private final JobRepository jobRepository;
    private final ApplicationMapper applicationMapper;
    private final NotificationFacade notificationFacade;

    // Constructor to inject all dependencies
    public ApplicationService(ApplicationRepository applicationRepository,
            UserRepository userRepository,
            JobRepository jobRepository,
            ApplicationMapper applicationMapper,
            NotificationFacade notificationFacade) {
        this.applicationRepository = applicationRepository;
        this.userRepository = userRepository;
        this.jobRepository = jobRepository;
        this.applicationMapper = applicationMapper;
        this.notificationFacade = notificationFacade;
    }

    /**
     * Creates a new application.
     * This method links the application to both the User and the Job.
     */
    @Transactional
    public ApplicationResponseDTO createApplication(ApplicationCreateDTO dto, long userId, long jobId) {

        // 1. Find the parent User and Job entities
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + userId));

        Job job = jobRepository.findById(jobId)
                .orElseThrow(() -> new RuntimeException("Job not found with ID: " + jobId));

        // 2. Map the DTO to the Application entity
        Application application = applicationMapper.maptoAddApplication(dto);

        // 3. Set the relationships and business logic fields
        application.setUser(user);
        application.setJob(job);
        application.setApplicationStatus(ApplicationStatus.PENDING); // Set default status
        application.setCreatedAt(new Date(System.currentTimeMillis())); // Set current date

        // 4. Save the new application
        // Because Application is the "owning" side of the relationship (with
        // @JoinColumn),
        // saving it is what creates the foreign key links in the database.
        Application savedApplication = applicationRepository.save(application);

        // 5. Return the DTO
        return applicationMapper.maptoreturnApplication(savedApplication);
    }

    /**
     * Gets all applications that a specific user has submitted.
     */
    @Transactional(readOnly = true)
    public List<ApplicationResponseDTO> getApplicationsForUser(long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + userId));

        // Use the 'ownedApplications' list from the User entity
        List<Application> applications = applicationRepository.findByUserId(userId);

        // Map the list of entities to a list of DTOs
        return applications.stream()
                .map(applicationMapper::maptoreturnApplication)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public JobIdsFromApplicationsResponseDTO getJobIdsFromApplications(long userId) {
        // User user = userRepository.findById(userId)
        // .orElseThrow(() -> new RuntimeException("User not found with ID: " +
        // userId));

        // List<Application> apps = user.getOwnedApplications();
        List<Application> applications = applicationRepository.findByUserId(userId);

        List<Long> jobIds = applications.stream()
                .map(application -> application.getJob().getId())
                .collect(Collectors.toList());

        JobIdsFromApplicationsResponseDTO dto = new JobIdsFromApplicationsResponseDTO();
        dto.setJobIds(jobIds);
        return dto;

    }

    @Transactional(readOnly = true)
    public boolean hasUserAppliedToJob(long userId, long jobId) {
        return applicationRepository.existsByUserIdAndJobId(userId, jobId);
    }

    /**
     * Returns the user id of the applicant who submitted the application.
     * Used for authorization (only applicant can withdraw/delete their
     * application).
     */
    @Transactional(readOnly = true)
    public long getApplicantId(long applicationId) {
        Application application = applicationRepository.findById(applicationId)
                .orElseThrow(() -> new RuntimeException("Application not found with ID: " + applicationId));
        return application.getUser().getId();
    }

    /**
     * Returns the user id of the job poster (owner) for the given job.
     * Used for authorization (only job owner can see applications for their job).
     */
    @Transactional(readOnly = true)
    public long getJobOwnerId(long jobId) {
        Job job = jobRepository.findById(jobId)
                .orElseThrow(() -> new RuntimeException("Job not found with ID: " + jobId));
        return job.getJobPoster().getId();
    }

    /**
     * Gets all applications that have been submitted for a specific job.
     */
    @Transactional(readOnly = true)
    public List<ApplicationWebResponseDTO> getApplicationsForJob(long jobId) {
        Job job = jobRepository.findById(jobId)
                .orElseThrow(() -> new RuntimeException("Job not found with ID: " + jobId));

        // Use the 'listofJobApplications' list from the Job entity
        List<Application> applications = job.getListOfJobApplications();

        // Map the list of entities to a list of DTOs
        return applications.stream()
                .map(application -> applicationMapper.mapToReturnWebApplication(application))
                .collect(Collectors.toList());
    }

    /**
     * Deletes an application by its ID.
     * This will automatically remove it from the User's and Job's lists
     * on the next database read because the record is gone.
     */
    @Transactional
    public void deleteApplication(long applicationId) {
        if (!applicationRepository.existsById(applicationId)) {
            throw new RuntimeException("Application not found with ID: " + applicationId);
        }

        // Deleting the application record is enough.
        // The @OneToMany lists in User and Job are managed by Hibernate
        // and will no longer include this application after it's deleted.
        applicationRepository.deleteById(applicationId);
    }

    @Transactional
    public ApplicationResponseDTO updateApplicationStatus(long applicationId, long requestingUserId,
            ApplicationStatusUpdateDTO dto) {

        Application application = applicationRepository.findById(applicationId)
                .orElseThrow(() -> new RuntimeException("Application not found with ID: " + applicationId));

        Job job = application.getJob();

        long jobPosterId = job.getJobPoster().getId();

        // Compare the ID of the person making the request (requestingUserId)
        // with the ID of the person who owns the job (jobPosterId).
        if (requestingUserId != jobPosterId) {
            throw new RuntimeException(
                    "Authorization Failed: You are not the owner of this job and cannot update its applications.");
        }

        // 5. Authorization Passed: Update the status
        application.setApplicationStatus(dto.getStatus());

        if (dto.getStatus() == ApplicationStatus.INTERVIEW_SCHEDULED) {
            application.setInterviewDate(dto.getInterviewDate());
            application.setInterviewTime(dto.getInterviewTime());
            application.setInterviewLocation(dto.getInterviewLocation());
        }

        // 6. Save the updated application
        Application savedApplication = applicationRepository.save(application);

        User applicant = application.getUser();
        String employerName = job.getJobPoster().getName();

        notificationFacade.dispatchApplicationUpdate(applicant, employerName, applicationId, dto);
        // 7. Map and return the updated DTO
        return applicationMapper.maptoreturnApplication(savedApplication);
    }
}