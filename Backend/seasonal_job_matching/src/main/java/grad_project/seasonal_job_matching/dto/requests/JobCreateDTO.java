package grad_project.seasonal_job_matching.dto.requests;

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

//request dto has different parameters and fields than response (they take objects)
@Data
public class JobCreateDTO {

    
    @NotBlank
    private String title;
    private String description;
    @NotNull
    private JobType type;
    private String location;
    @JsonFormat(pattern = "dd-MM-yyyy")
    private Date startDate; 
    @NotNull
    private long jobposterId;
    private Salary salary;
    @PositiveOrZero
    private float amount;
    private String currency = "EGP";
    private Integer duration;
    private JobStatus status;
    private int numOfPositions;
    private WorkArrangement workArrangement;
    private List<String> requirements;
    private List<String> categories;
    private List<String> benefits;

}