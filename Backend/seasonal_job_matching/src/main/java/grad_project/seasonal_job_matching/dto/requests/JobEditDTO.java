package grad_project.seasonal_job_matching.dto.requests;

import java.sql.Date;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonFormat;

import grad_project.seasonal_job_matching.model.enums.Salary;
import grad_project.seasonal_job_matching.model.enums.JobStatus;
import grad_project.seasonal_job_matching.model.enums.JobType;
import grad_project.seasonal_job_matching.model.enums.WorkArrangement;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.Data;

@Data
public class JobEditDTO {
    private String title;
    private String description;
    private JobType type;
    private String location;
    @JsonFormat(pattern = "dd-MM-yyyy")
    private Date startDate; 
    private Salary salary; 
    @PositiveOrZero
    private float amount;
    private String currency;
    private Integer duration;
    private JobStatus status;
    private int numOfPositions;
    private WorkArrangement workArrangement;

    // Requirements - add/remove pattern
    private List<String> requirementsToAdd;
    private List<String> requirementsToRemove;

    // Categories - add/remove pattern
    private List<String> categoriesToAdd;
    private List<String> categoriesToRemove;

    // Benefits - add/remove pattern
    private List<String> benefitsToAdd;
    private List<String> benefitsToRemove;
}
