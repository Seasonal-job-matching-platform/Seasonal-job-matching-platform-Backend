package grad_project.seasonal_job_matching.dto.requests;

import grad_project.seasonal_job_matching.model.enums.ApplicationStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ApplicationStatusUpdateDTO {

    @NotNull(message = "A new status must be provided")
    private ApplicationStatus status;

    private String interviewDate;

    private String interviewTime;

    private String interviewLocation;
}