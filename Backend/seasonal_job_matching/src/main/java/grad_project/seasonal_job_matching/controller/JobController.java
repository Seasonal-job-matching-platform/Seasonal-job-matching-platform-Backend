package grad_project.seasonal_job_matching.controller;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import grad_project.seasonal_job_matching.dto.requests.JobCommentCreateDTO;
import grad_project.seasonal_job_matching.dto.requests.JobCreateDTO;
import grad_project.seasonal_job_matching.dto.requests.JobEditDTO;
import grad_project.seasonal_job_matching.dto.responses.JobCommentResponseDTO;
import grad_project.seasonal_job_matching.dto.responses.JobResponseDTO;
import grad_project.seasonal_job_matching.model.enums.JobType;
import grad_project.seasonal_job_matching.model.enums.Salary;
import grad_project.seasonal_job_matching.model.enums.WorkArrangement;
import grad_project.seasonal_job_matching.security.CurrentUserService;
import grad_project.seasonal_job_matching.services.JobService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/jobs")
public class JobController {

    final private JobService job_service;
    final private CurrentUserService currentUserService;

    public JobController(JobService job_service, CurrentUserService currentUserService) {
        this.job_service = job_service;
        this.currentUserService = currentUserService;
    }

    @GetMapping
    public Page<JobResponseDTO> findAll(@RequestParam(defaultValue = "0") int page) {
        // return job_service.findAllJobs(); old method that gets all jobs
        return job_service.getJobsPaged(page);
    }

    // MAYBE USE SLICE INSTEAD OF PAGE TO MAKE IT FASTER
    @GetMapping("/search")
    public Page<JobResponseDTO> findJobsFromSearch(@RequestParam(defaultValue = "0") int page,
            @RequestParam(required = false) String title) {
        return job_service.getSearchedJobs(page, title);
    }

    @GetMapping("/filter")
    public ResponseEntity<Page<JobResponseDTO>> filterJobs(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(required = false) List<WorkArrangement> arrangements,
            @RequestParam(required = false) List<JobType> jobTypes,
            @RequestParam(required = false) List<Salary> salaryTypes,
            @RequestParam(required = false) String location,
            @RequestParam(required = false) String title) {

        Page<JobResponseDTO> jobs = job_service.getJobsWithAdvancedFilters(
                page, arrangements, jobTypes, salaryTypes, location, title);
        return ResponseEntity.ok(jobs);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> findByID(@PathVariable long id) {
        Optional<JobResponseDTO> job = job_service.findByID(id);
        if (job.isEmpty()) {
            return ResponseEntity.ok("Job not found!");
        } else {
            return ResponseEntity.ok(job.get());
        }

    }

    @GetMapping("/employer/{id}")
    public ResponseEntity<?> employerFindByID(@PathVariable long id, HttpServletRequest request) {
        Long currentUserId = currentUserService.getCurrentUserId(request);
        if (currentUserId == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();

        Optional<JobResponseDTO> job = job_service.findByID(id);
        if (currentUserId != job.get().getJobposterId())
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();

        if (job.isEmpty()) {
            return ResponseEntity.ok("Job not found!");
        } else {
            return ResponseEntity.ok(job.get());
        }

    }

    @PostMapping("")
    public ResponseEntity<?> createJob(@Valid @RequestBody JobCreateDTO jobdto, HttpServletRequest request) {
        Long currentUserId = currentUserService.getCurrentUserId(request);
        if (currentUserId == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        if (currentUserId != jobdto.getJobposterId()) // gives 403 error with no logs
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();

        try {
            JobResponseDTO job = job_service.createJob(jobdto);
            return ResponseEntity.ok()
                    .body(Map.of(
                            "message", "Job created successfully",
                            "job", job));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", e.getMessage()));
        }
    }

    @PatchMapping("/{id}")
    public ResponseEntity<?> editJob(@PathVariable long id, @Valid @RequestBody JobEditDTO dto,
            HttpServletRequest request) {
        Long currentUserId = currentUserService.getCurrentUserId(request);
        if (currentUserId == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        Optional<JobResponseDTO> jobDetails = job_service.findByID(id);
        if (jobDetails.isEmpty())
            return ResponseEntity.notFound().build();
        if (currentUserId != jobDetails.get().getJobposterId())
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        try {
            JobResponseDTO job = job_service.editJob(dto, id);
            return ResponseEntity.ok()
                    .body(Map.of(
                            "message", "Job edited successfully",
                            "job", job));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteJob(@PathVariable Long id, HttpServletRequest request) {
        Long currentUserId = currentUserService.getCurrentUserId(request);
        if (currentUserId == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        Optional<JobResponseDTO> jobDetails = job_service.findByID(id);
        if (jobDetails.isEmpty())
            return ResponseEntity.notFound().build();
        if (currentUserId != jobDetails.get().getJobposterId())
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        job_service.deleteJob(id);
        return ResponseEntity.ok("Job deleted successfully!");
    }

    @PostMapping("/{jobId}/comments")
    public ResponseEntity<?> addComment(@PathVariable Long jobId,
            @Valid @RequestBody JobCommentCreateDTO commentDto, HttpServletRequest request) {
        Long currentUserId = currentUserService.getCurrentUserId(request);
        if (currentUserId == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login first");
        Optional<JobResponseDTO> jobDetails = job_service.findByID(jobId);
        if (jobDetails.isEmpty())
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("No such job");

        try {
            JobCommentResponseDTO response = job_service.addComment(commentDto, jobId, currentUserId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/{jobId}/comments/{commentId}/replies")
    public ResponseEntity<?> addReply(@PathVariable Long jobId, @PathVariable Long commentId,
            @Valid @RequestBody JobCommentCreateDTO commentDto, HttpServletRequest request) {

        // Optional<JobCommentResponseDTO> comment = job_service.getComment(commentId);
        Long currentUserId = currentUserService.getCurrentUserId(request);
        if (currentUserId == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login first");
        Optional<JobResponseDTO> jobDetails = job_service.findByID(jobId);
        if (jobDetails.isEmpty())
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("No such job");
        if (!currentUserId.equals(jobDetails.get().getJobposterId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Only the job poster can reply.");
        }

        try {// commentId is the parent comment, the one we want to reply to
            JobCommentResponseDTO response = job_service.addReply(commentDto, jobId, currentUserId, commentId);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping("/{jobId}/comments")
    public ResponseEntity<?> getJobComments(@PathVariable Long jobId) {
        try {
            List<JobCommentResponseDTO> comments = job_service.getJobComments(jobId);

            // If the list is empty, it just returns an empty array
            return ResponseEntity.ok(comments);

        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @DeleteMapping("/{jobId}/comments/{commentId}")
    public ResponseEntity<?> deleteComment(@PathVariable Long jobId, @PathVariable Long commentId,
            HttpServletRequest request) {
        Long currentUserId = currentUserService.getCurrentUserId(request);
        Optional<JobCommentResponseDTO> comment = job_service.getComment(commentId);
        if (comment.isEmpty())
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Comment not found");
        if (currentUserId == null || comment.get().getUserId() != currentUserId)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("You can only delete your own comments");
        Optional<JobResponseDTO> jobDetails = job_service.findByID(jobId);
        if (jobDetails.isEmpty())
            return ResponseEntity.notFound().build();

        try {
            job_service.deleteComment(commentId, jobId);
            return ResponseEntity.ok("Comment deleted successfully!");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", "Comment failed to delete!"));

        }
    }
}
