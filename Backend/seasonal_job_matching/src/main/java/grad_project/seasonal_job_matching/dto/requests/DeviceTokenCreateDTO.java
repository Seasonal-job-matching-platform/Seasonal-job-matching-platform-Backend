package grad_project.seasonal_job_matching.dto.requests;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class DeviceTokenCreateDTO {

    @NotNull
    private Long userId;

    @NotBlank
    private String token;

    @NotBlank(message = "Device type cannot be blank (e.g., WEB, MOBILE)")
    private String deviceType;
}
