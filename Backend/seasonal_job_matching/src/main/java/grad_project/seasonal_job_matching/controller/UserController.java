package grad_project.seasonal_job_matching.controller;

import java.util.List;
import java.util.Map;
import java.util.Optional;

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
import org.springframework.web.bind.annotation.RestController;

import grad_project.seasonal_job_matching.dto.requests.UserCreateDTO;
import grad_project.seasonal_job_matching.dto.requests.UserEditDTO;
import grad_project.seasonal_job_matching.dto.requests.UserLoginDTO;
import grad_project.seasonal_job_matching.dto.responses.JobResponseDTO;
import grad_project.seasonal_job_matching.dto.responses.UserFieldsOfInterestResponseDTO;
import grad_project.seasonal_job_matching.dto.responses.UserResponseDTO;
import grad_project.seasonal_job_matching.security.CurrentUserService;
import grad_project.seasonal_job_matching.services.ApplicationService;
import grad_project.seasonal_job_matching.services.UserService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/users")
public class UserController {

    final private CurrentUserService currentUserService;
    final private UserService users_service;
    final private ApplicationService application_service;

    public UserController(UserService service, ApplicationService application_service,
            CurrentUserService currentUserService) {
        this.users_service = service;
        this.application_service = application_service;
        this.currentUserService = currentUserService;
    }

    @GetMapping
    public List<UserResponseDTO> findAll() {
        return users_service.findAllUsers();
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> findByID(@PathVariable long id, HttpServletRequest request) {
        Long currentUserId = currentUserService.getCurrentUserId(request);
        if (currentUserId == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        if (currentUserId != id)
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();

        Optional<UserResponseDTO> user = users_service.findByID(id);
        if (user.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(user.get());

    }

    @PostMapping("/login")
    public ResponseEntity<?> loginUser(@Valid @RequestBody UserLoginDTO dto) {
        try {
            Map<String, Object> response = users_service.loginUser(dto);
            // Authentication successful
            return ResponseEntity.ok().body(response);
        } catch (RuntimeException e) {
            // Authentication failed (from service)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/{id}/jobs")
    public ResponseEntity<?> findUserJobs(@PathVariable long id, HttpServletRequest request) {
        Long currentUserId = currentUserService.getCurrentUserId(request);
        if (currentUserId == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        if (currentUserId != id)
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();

        // we get list<jobresponsedto> wrapped in response entity
        return ResponseEntity.ok(users_service.findUserJobs(id));
    }

    @GetMapping("/{userId}/applied/{jobId}")
    public ResponseEntity<?> hasUserAppliedToJob(
            @PathVariable long userId,
            @PathVariable long jobId,
            HttpServletRequest request) {

        Long currentUserId = currentUserService.getCurrentUserId(request);
        if (currentUserId == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        if (currentUserId != userId)
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();

        try {
            boolean hasApplied = application_service.hasUserAppliedToJob(userId, jobId);
            return ResponseEntity.ok(Map.of("hasApplied", hasApplied));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/FOI/{userId}")
    public ResponseEntity<?> getFieldsOfInterest(@PathVariable long userId, HttpServletRequest request) {
        Long currentUserId = currentUserService.getCurrentUserId(request);
        if (currentUserId == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        if (currentUserId != userId)
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();

        try {
            UserFieldsOfInterestResponseDTO foi = users_service.getFieldsOfInterest(userId);
            if (foi.getFieldsOfInterest() == null || foi.getFieldsOfInterest().isEmpty()) {
                // Return 200 OK with an empty list rather than an error
                return ResponseEntity.ok(foi);
            }
            return ResponseEntity.ok(foi);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/{userId}/favorite-jobs")
    public ResponseEntity<List<Long>> getFavoriteJobIds(@PathVariable long userId, HttpServletRequest request) {
        Long currentUserId = currentUserService.getCurrentUserId(request);
        // the .build makes the generic response into whatever the function needs so in
        // this case it builds into a list<long>
        if (currentUserId == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        if (currentUserId != userId)
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();

        List<Long> jobIds = users_service.getFavoriteJobIds(userId);
        return ResponseEntity.ok(jobIds);
    }

    @GetMapping("/{userId}/recommended-jobs")
    public ResponseEntity<?> getRecommendedJobs(@PathVariable long userId, HttpServletRequest request) {
        Long currentUserId = currentUserService.getCurrentUserId(request);
        if (currentUserId == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        if (currentUserId != userId)
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();

        try {
            List<JobResponseDTO> recommendedJobs = users_service.getRecommendedJobs(userId);
            return ResponseEntity.ok(Map.of(
                    "jobs", recommendedJobs,
                    "count", recommendedJobs.size()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping
    public ResponseEntity<?> createUser(@Valid @RequestBody UserCreateDTO userdto) {// if user is from mobile than type
                                                                                    // is jobseeker, else it is employer
        try {
            Map<String, Object> response = users_service.createUser(userdto);
            return ResponseEntity.ok().body(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", e.getMessage()));
        }
    }

    @PatchMapping("/{id}")
    public ResponseEntity<?> editUser(@PathVariable long id, @Valid @RequestBody UserEditDTO dto,
            HttpServletRequest request) {
        Long currentUserId = currentUserService.getCurrentUserId(request);
        if (currentUserId == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        if (currentUserId != id)
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        try {
            UserResponseDTO user = users_service.editUser(dto, id);
            return ResponseEntity.ok().body(Map.of(
                    "message", "User edited successfully",
                    "user", user));
        } catch (RuntimeException e) {
            return ResponseEntity.ok("Update failed");
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteUser(@PathVariable Long id, HttpServletRequest request) {
        Long currentUserId = currentUserService.getCurrentUserId(request);
        if (currentUserId == null)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        if (currentUserId != id)
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        Optional<UserResponseDTO> user = users_service.findByID(id);
        if (user.isPresent()) {
            users_service.deleteUser(id);
            return ResponseEntity.ok("User deleted successfully!");
        }
        return ResponseEntity.notFound().build();
    }

}
