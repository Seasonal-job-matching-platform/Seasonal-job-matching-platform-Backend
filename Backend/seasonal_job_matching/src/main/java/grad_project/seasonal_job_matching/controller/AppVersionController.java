package grad_project.seasonal_job_matching.controller;

import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/app-version")
@CrossOrigin(origins = "*")
public class AppVersionController {

    private final String appVersion;

    public AppVersionController(@Value("${app.version.release:1.0.0}") String appVersion) {
        this.appVersion = appVersion;
    }

    @GetMapping
    public ResponseEntity<Map<String, String>> getAppVersion() {
        return ResponseEntity.ok(Map.of("version", appVersion));
    }
}
