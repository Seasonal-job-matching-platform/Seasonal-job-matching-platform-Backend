package grad_project.seasonal_job_matching.dto.responses;

import java.util.List;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
public class UserResponseDTO {

    private long id;

    private String name;

    private String country;

    @Pattern(regexp = "^[0-9]{11}$")
    private String number;

    @Email
    private String email;

    private Boolean wantsEmails;

    // private ResumeResponseDTO resume; //maybe just the id instead of everything

    // private List<JobResponseDTO> ownjobList;//probably add JSONignoreproperties
    // here because you dont need all jobs and applications when loading user
    // will need to add ownedapplications here

}
