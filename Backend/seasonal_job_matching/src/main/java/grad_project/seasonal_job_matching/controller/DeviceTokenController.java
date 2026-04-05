package grad_project.seasonal_job_matching.controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import grad_project.seasonal_job_matching.dto.requests.DeviceTokenCreateDTO;
import grad_project.seasonal_job_matching.services.Notifications.DeviceTokenService;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/notification-token")
@CrossOrigin(origins = "*")
public class DeviceTokenController {

    private final DeviceTokenService tokenService;

    public DeviceTokenController(DeviceTokenService tokenService) {
        this.tokenService = tokenService;
    }

    @PostMapping("/register-token")
    public ResponseEntity<?> registerDeviceToken(@Valid @RequestBody DeviceTokenCreateDTO tokenDTO) {
        try {
            tokenService.registerOrUpdateToken(tokenDTO.getUserId(), tokenDTO.getToken(), tokenDTO.getDeviceType());
            return ResponseEntity.ok(Map.of("message", "Device token registered successfully"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @DeleteMapping("/remove-token")
    public ResponseEntity<?> removeToken(@RequestParam String token) {
        tokenService.removeToken(token);
        return ResponseEntity.ok(Map.of("message", "Device token removed successfully!"));
    }
}
