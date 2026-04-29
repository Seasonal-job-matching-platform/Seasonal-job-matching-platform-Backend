package grad_project.seasonal_job_matching.services;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.cache.annotation.Caching;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpMethod;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import grad_project.seasonal_job_matching.dto.requests.UserCreateDTO;
import grad_project.seasonal_job_matching.dto.requests.UserEditDTO;
import grad_project.seasonal_job_matching.dto.requests.UserLoginDTO;
import grad_project.seasonal_job_matching.dto.responses.JobResponseDTO;
import grad_project.seasonal_job_matching.dto.responses.RecommendedJobDTO;
import grad_project.seasonal_job_matching.dto.responses.RecommendedJobsResponse;
import grad_project.seasonal_job_matching.dto.responses.UserFieldsOfInterestResponseDTO;
import grad_project.seasonal_job_matching.dto.responses.UserResponseDTO;
import grad_project.seasonal_job_matching.mapper.JobMapper;
import grad_project.seasonal_job_matching.mapper.UserMapper;
import grad_project.seasonal_job_matching.model.Job;
import grad_project.seasonal_job_matching.model.User;
import grad_project.seasonal_job_matching.repository.JobRepository;
import grad_project.seasonal_job_matching.repository.UserRepository;
import grad_project.seasonal_job_matching.security.JWTService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class UserService {

    public final List<User> users = new ArrayList<>();
    private final UserRepository userRepository;
    private final JobRepository jobRepository;

    private final PasswordEncoder passwordEncoder;
    // like singleton, only one instantiation of code which is in mapper so it gets
    // that one instead of creating a new one in this class
    @Autowired
    private UserMapper userMapper;
    @Autowired
    private JobMapper jobMapper;

    private final JWTService jwtService;

    private final RestTemplate restTemplate;

    private static final Logger logger = LoggerFactory.getLogger(UserService.class); // good practice for debugging,
                                                                                     // writes any calls that go through
                                                                                     // here in logs to find where
                                                                                     // things break exactly

    @Value("${external.api.recommendation.url}") // gets it from application.properties.
    private String recommendationBaseUrl;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder, JobRepository jobRepository,
            RestTemplate restTemplate, JWTService jwtService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jobRepository = jobRepository;
        this.restTemplate = restTemplate;
        this.jwtService = jwtService;

    }

    public List<UserResponseDTO> findAllUsers() {
        return userRepository.findAll()
                .stream() // turns from List into type stream<user> which can use map and collect

                // can(user -> userMapper.maptoreturnUser(user))
                .map(userMapper::maptoreturnUser) // applies maptoreturn user from usermapper to each user in stream,
                                                  // turns user into a DTO
                .collect(Collectors.toList()); // gathers all transformer users back into list
    }

    @Cacheable(value = "recommendedJobs", key = "#userId")
    // parses data from matching engines response to dto format
    public List<JobResponseDTO> getRecommendedJobs(Long userId) {
        try {
            String url = recommendationBaseUrl + "/recommend/" + userId;

            logger.info("Calling external API: {}", url);

            // ResponseEntity<RecommendedJobsResponse> response = restTemplate.getForEntity(
            // url,
            // RecommendedJobsResponse.class);

            HttpHeaders headers = new HttpHeaders();
            headers.set("ngrok-skip-browser-warning", "true");
            HttpEntity<String> entity = new HttpEntity<>(headers);

            ResponseEntity<RecommendedJobsResponse> response = restTemplate.exchange(
                    url,
                    HttpMethod.GET,
                    entity,
                    RecommendedJobsResponse.class);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                logger.info("Successfully received recommendations for user {}", userId);
                // Map the response to your JobResponseDTO format
                return mapToJobResponseDTOs(response.getBody());
            } else {
                logger.warn("Received empty or unsuccessful response from external API");
                return new ArrayList<>();
            }

            // error handling for 400s,500s,
        } catch (HttpClientErrorException e) {
            // 4xx errors (client errors)
            logger.error("Client error calling external API: Status={}, Body={}",
                    e.getStatusCode(), e.getResponseBodyAsString());
            throw new RuntimeException("Failed to fetch recommendations: " + e.getMessage());

        } catch (HttpServerErrorException e) {
            // 5xx errors (server errors)
            logger.error("Server error calling external API: Status={}, Body={}",
                    e.getStatusCode(), e.getResponseBodyAsString());
            throw new RuntimeException("External service unavailable. Please try again later.");

        } catch (ResourceAccessException e) {
            // Connection timeout or network issues
            logger.error("Connection error calling external API: {}", e.getMessage());
            throw new RuntimeException("Unable to connect to recommendation service. Please try again later.");

        } catch (RestClientException e) {
            // Other REST client errors
            logger.error("Unexpected error calling external API: {}", e.getMessage(), e);
            throw new RuntimeException("An error occurred while fetching recommendations.");
        }
    }

    // takes given data from recommendations and returns the full jobs, can tell
    // Ahmed to just give me the full job so I can return it without having to parse
    // ID from recommendation and fetch same jobs again.
    private List<JobResponseDTO> mapToJobResponseDTOs(RecommendedJobsResponse response) {
        if (response == null || response.getRecommendations() == null || response.getRecommendations().isEmpty()) {
            logger.warn("No recommendations found in response");
            return new ArrayList<>();
        }

        // Extract job IDs from recommendations
        List<Long> jobIds = response.getRecommendations().stream()
                .map(RecommendedJobDTO::getId)
                .filter(id -> id != null)
                .collect(Collectors.toList());

        if (jobIds.isEmpty()) {
            logger.warn("No valid job IDs found in recommendations");
            return new ArrayList<>();
        }

        logger.info("Fetching {} recommended jobs from database", jobIds.size());

        // Fetch full job details from database using the IDs
        List<Job> jobs = jobRepository.findAllById(jobIds);

        if (jobs.isEmpty()) {
            logger.warn("No jobs found in database for recommended IDs: {}", jobIds);
            return new ArrayList<>();
        }

        // Map Jobs to JobResponseDTOs using existing mapper
        List<JobResponseDTO> jobDTOs = jobs.stream()
                .map(jobMapper::maptoreturnJob)
                .collect(Collectors.toList());

        logger.info("Successfully mapped {} jobs to DTOs", jobDTOs.size());

        return jobDTOs;
    }

    public List<JobResponseDTO> findUserJobs(long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + id));
        return user.getOwnedJobs().stream().map(jobMapper::maptoreturnJob).collect(Collectors.toList());
    }

    public Map<String, Object> loginUser(UserLoginDTO dto) {

        // 1. Find the user by their email
        User user = userRepository.findByEmail(dto.getEmail())
                .orElseThrow(() -> new RuntimeException("Authentication failed: Invalid credentials."));

        // 2. Check if the provided password matches the stored hashed password
        if (passwordEncoder.matches(dto.getPassword(), user.getPassword())) {
            // 3. Generate JWT token with user data (email, userId, phoneNumber)
            String token = jwtService.generateToken(
                    user.getId(),
                    user.getEmail(),
                    user.getNumber(),
                    user.getName());
            // 3. Passwords match, return the user's data (without the password)
            UserResponseDTO userResponseDTO = userMapper.maptoreturnUser(user);

            Map<String, Object> response = new HashMap<>();
            response.put("token", token);
            response.put("user", userResponseDTO);
            response.put("message", "Login successful");

            return response;
        } else {
            throw new RuntimeException("Authentication failed");
        }

    }

    @Cacheable(value = "profile", key = "#id")
    public Optional<UserResponseDTO> findByID(long id) {
        return userRepository.findById(id)
                .map(userMapper::maptoreturnUser);
    }

    @Transactional(readOnly = true)
    public UserFieldsOfInterestResponseDTO getFieldsOfInterest(long userId) {
        // User user = userRepository.findById(userId)
        // .orElseThrow(() -> new RuntimeException("User not found with ID: " +
        // userId));

        // List<Application> apps = user.getOwnedApplications();
        Optional<User> user = userRepository.findById(userId);

        List<String> foi = user.map(User::getFieldsOfInterest)
                .orElse(new ArrayList<>());

        UserFieldsOfInterestResponseDTO dto = new UserFieldsOfInterestResponseDTO();
        dto.setFieldsOfInterest(foi);
        return dto;

    }

    public UserResponseDTO createUser(UserCreateDTO dto) {
        // if email is NOT present, save new user
        if (!userRepository.existsByEmail(dto.getEmail())) {
            User user1 = userMapper.maptoAddUser(dto);

            // encrypt password
            user1.setPassword(passwordEncoder.encode(dto.getPassword()));

            // better practice especially since user1 is being edited
            User saveduser = userRepository.save(user1);
            return userMapper.maptoreturnUser(saveduser);

        } else {
            throw new RuntimeException("Cannot create user");
        }
    }

    @Cacheable(value = "favoriteJobs", key = "#userId")
    public List<Long> getFavoriteJobIds(long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return user.getFavoriteJobs().stream()
                .map(Job::getId)
                .toList();
    }

    @Caching(evict = {
            @CacheEvict(value = "recommendedJobs", key = "#id"),
            @CacheEvict(value = "profile", key = "#id"),
            @CacheEvict(value = "favoriteJobs", key = "#id")
    })
    public UserResponseDTO editUser(UserEditDTO dto, long id) {
        User existingUser = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + id));

        if (existingUser.getFieldsOfInterest() == null) {
            existingUser.setFieldsOfInterest(new ArrayList<>());
        }

        // checks to see if we are editing email
        // in case we're editing a different field than email, check new email isn't
        // empty, checks new email isnt same as OLD email
        if (dto.getEmail() != null && !dto.getEmail().trim().isEmpty()
                && !dto.getEmail().equals(existingUser.getEmail())) {
            // after confirming that we are editing email, checks new email isnt as another
            // email in db
            if (userRepository.existsByEmail(dto.getEmail())) {
                throw new RuntimeException("Cannot update user, email already exists: " + dto.getEmail());
            }
        }

        // has new fields that are changed
        User updatedUser = userMapper.maptoEditUser(dto);

        if (dto.getWantsEmails() != null) {
            existingUser.setWantsEmails(dto.getWantsEmails());
        }

        // if field thats updated is name and new name isn't empty
        if (dto.getName() != null && !dto.getName().trim().isEmpty()) {
            existingUser.setName(updatedUser.getName());
        }

        if (dto.getCountry() != null && !dto.getCountry().trim().isEmpty()) {
            existingUser.setCountry(updatedUser.getCountry());
        }

        if (dto.getEmail() != null && !dto.getEmail().trim().isEmpty()) {
            existingUser.setEmail(updatedUser.getEmail());
        }

        if (dto.getNumber() != null && !dto.getNumber().trim().isEmpty()) {
            existingUser.setNumber(updatedUser.getNumber());
        }

        if (dto.getPassword() != null && !dto.getPassword().trim().isEmpty()) {
            existingUser.setPassword(passwordEncoder.encode(updatedUser.getNumber()));
        }

        if (dto.getFieldsOfInterestToAdd() != null) {
            for (String field : dto.getFieldsOfInterestToAdd()) {
                if (!existingUser.getFieldsOfInterest().contains(field)) {
                    existingUser.getFieldsOfInterest().add(field);
                }
            }
        }

        if (dto.getFieldsOfInterestToRemove() != null) {
            existingUser.getFieldsOfInterest().removeAll(dto.getFieldsOfInterestToRemove());
        }

        if (dto.getFavoriteJobIds() != null) {
            List<Job> jobs = jobRepository.findAllById(dto.getFavoriteJobIds());

            existingUser.getFavoriteJobs().clear();
            existingUser.getFavoriteJobs().addAll(jobs);
        }

        User saveduser = userRepository.save(existingUser);
        return userMapper.maptoreturnUser(saveduser);
    }

    @CacheEvict(value = "profile", key = "#id")
    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }

}
