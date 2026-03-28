package grad_project.seasonal_job_matching.dto.responses;

import java.sql.Date;

import grad_project.seasonal_job_matching.model.enums.ApplicationStatus;
import lombok.Data;

@Data
public class ApplicationWebResponseDTO {

    private long id;

    private UserResponseDTO user;

    private ApplicationStatus applicationStatus;

    private long jobId;// so the frontend and user dont struggle with parsing

    private Date createdAt;

    private String describeYourself;

    private String interviewDate;

    private String interviewTime;

    private String interviewLocation;
}
