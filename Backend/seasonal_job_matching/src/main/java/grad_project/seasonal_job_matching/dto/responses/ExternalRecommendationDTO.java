package grad_project.seasonal_job_matching.dto.responses;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import java.util.List;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class ExternalRecommendationDTO {

    @JsonProperty("user_id")
    private Long userId;

    @JsonProperty("describe_yourself")
    private String describeYourself;

    private List<String> skills;
    private List<String> experience;
    private List<String> education;
    private List<String> languages;

    @JsonProperty("fields_of_interest")
    private List<String> fieldsOfInterest;
}
