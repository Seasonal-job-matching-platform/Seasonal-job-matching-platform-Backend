package grad_project.seasonal_job_matching.controller;

import grad_project.seasonal_job_matching.dto.requests.ApplicationCreateDTO;
import grad_project.seasonal_job_matching.dto.requests.ApplicationStatusUpdateDTO;
import grad_project.seasonal_job_matching.dto.responses.ApplicationResponseDTO;
import grad_project.seasonal_job_matching.dto.responses.ApplicationWebResponseDTO;
import grad_project.seasonal_job_matching.dto.responses.JobIdsFromApplicationsResponseDTO;
import grad_project.seasonal_job_matching.security.CurrentUserService;
import grad_project.seasonal_job_matching.services.ApplicationService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/applications")
public class ApplicationController {

    private final CurrentUserService currentUserService;
    private final ApplicationService applicationService;

    public ApplicationController(ApplicationService applicationService, CurrentUserService currentUserService) {
        this.applicationService = applicationService;
        this.currentUserService = currentUserService;
    }

    /**
     * Creates a new application, linking a user to a job.
     * Since security is not yet implemented, we pass both IDs in the path.
     */
    @PostMapping("/user/{userId}/job/{jobId}")
    public ResponseEntity<?> createApplication(
            @PathVariable long userId,
            @PathVariable long jobId,
            @Valid @RequestBody ApplicationCreateDTO dto,
            HttpServletRequest request) {
        Long currentUserId = currentUserService.getCurrentUserId(request);
        if (currentUserId == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        if (currentUserId != userId)
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        try {
            ApplicationResponseDTO application = applicationService.createApplication(dto, userId, jobId);
            return ResponseEntity.ok().body(Map.of(
                    "message", "Application submitted successfully",
                    "application", application));
        } catch (RuntimeException e) {
            // Handle errors (e.g., User or Job not found)
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Gets all applications submitted by a specific user (Job Seeker view).
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getApplicationsForUser(@PathVariable long userId, HttpServletRequest request) {
        Long currentUserId = currentUserService.getCurrentUserId(request);
        if (currentUserId == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        if (currentUserId != userId)
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        try {
            List<ApplicationResponseDTO> applications = applicationService.getApplicationsForUser(userId);
            if (applications.isEmpty()) {
                // Return 200 OK with an empty list rather than an error
                return ResponseEntity.ok(applications);
            }
            return ResponseEntity.ok(applications);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/userjobs/{userId}")
    public ResponseEntity<?> getJobIdsFromApplications(@PathVariable long userId, HttpServletRequest request) {
        Long currentUserId = currentUserService.getCurrentUserId(request);
        if (currentUserId == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        if (currentUserId != userId)
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();

        try {
            JobIdsFromApplicationsResponseDTO applications = applicationService.getJobIdsFromApplications(userId);
            if (applications.getJobIds() == null || applications.getJobIds().isEmpty()) {
                // Return 200 OK with an empty list rather than an error
                return ResponseEntity.ok(applications);
            }
            return ResponseEntity.ok(applications);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PatchMapping("/{applicationId}/status/employer/{employerId}")
    public ResponseEntity<?> updateStatus(
            @PathVariable long applicationId,
            @PathVariable long employerId,
            @Valid @RequestBody ApplicationStatusUpdateDTO dto, HttpServletRequest request) {

        Long currentUserId = currentUserService.getCurrentUserId(request);
        if (currentUserId == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        if (currentUserId != employerId)
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        try {
            ApplicationResponseDTO updatedApplication = applicationService.updateApplicationStatus(applicationId,
                    employerId, dto);
            return ResponseEntity.ok().body(Map.of(
                    "message", "Application status updated successfully",
                    "application", updatedApplication));
        } catch (RuntimeException e) {
            // Catches both "Not Found" and "Authorization Failed" errors
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Gets all applications submitted for a specific job (Employer view).
     * Only the job owner (poster) can see applications for their job.
     */
    @GetMapping("/job/{jobId}")
    public ResponseEntity<?> getApplicationsForJob(@PathVariable long jobId, HttpServletRequest request) {
        Long currentUserId = currentUserService.getCurrentUserId(request);
        if (currentUserId == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        long jobOwnerId = applicationService.getJobOwnerId(jobId);
        if (currentUserId != jobOwnerId)
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        try {
            List<ApplicationWebResponseDTO> applications = applicationService.getApplicationsForJob(jobId);
            if (applications.isEmpty()) {
                return ResponseEntity.ok(applications);
            }
            return ResponseEntity.ok(applications);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Deletes (withdraws) an application by its unique ID.
     * Only the applicant who submitted the application can withdraw it.
     */
    @DeleteMapping("/{applicationId}")
    public ResponseEntity<?> deleteApplication(@PathVariable long applicationId,
            @RequestParam(required = true) int jobId, HttpServletRequest request) {
        Long currentUserId = currentUserService.getCurrentUserId(request);
        if (currentUserId == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        long applicantId = applicationService.getApplicantId(applicationId);
        if (currentUserId != applicantId)
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        try {
            applicationService.deleteApplication(applicationId, currentUserId, jobId);
            return ResponseEntity.ok(Map.of("message", "Application deleted successfully."));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}