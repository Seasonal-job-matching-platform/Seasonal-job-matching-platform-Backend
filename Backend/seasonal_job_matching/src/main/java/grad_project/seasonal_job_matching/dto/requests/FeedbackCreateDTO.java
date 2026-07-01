package grad_project.seasonal_job_matching.dto.requests;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class FeedbackCreateDTO {

    @NotBlank(message = "Title cannot be blank")
    private String title;

    @NotBlank(message = "Body cannot be blank")
    private String body;

    private String userEmail; // optional contact email
}
