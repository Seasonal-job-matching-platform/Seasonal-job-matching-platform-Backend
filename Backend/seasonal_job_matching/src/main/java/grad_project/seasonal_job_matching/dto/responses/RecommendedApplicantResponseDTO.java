package grad_project.seasonal_job_matching.dto.responses;

import lombok.Data;
import java.util.List;

@Data
public class RecommendedApplicantResponseDTO {
    private Long userId;
    private String name;
    private List<String> skills;
    private List<String> experience;
    private String describeYourself;
    private List<String> languages;
    private List<String> fieldsOfInterest;
    private List<String> education;
}
