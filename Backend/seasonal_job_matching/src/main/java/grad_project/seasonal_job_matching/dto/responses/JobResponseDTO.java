package grad_project.seasonal_job_matching.dto.responses;

import java.sql.Date;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonFormat;

import grad_project.seasonal_job_matching.model.enums.JobStatus;
import grad_project.seasonal_job_matching.model.enums.JobType;
import grad_project.seasonal_job_matching.model.enums.Salary;
import grad_project.seasonal_job_matching.model.enums.WorkArrangement;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.Data;

@Data
public class JobResponseDTO {

    @NotBlank
    private String title;
    private String description;
    @NotNull
    private long id;
    private JobType type;
    private String location;
    @JsonFormat(pattern = "dd-MM-yyyy")
    private Date startDate;   
    @PositiveOrZero
    private float amount;
    private String currency;
    private Salary salary;
    private Integer duration;
    private JobStatus status;
    private int numOfPositions;
    private WorkArrangement workArrangement;
    private Date createdAt;

    private long jobposterId;
    private String jobposterName;

    private List<String> requirements;
    private List<String> categories;
    private List<String> benefits;

}