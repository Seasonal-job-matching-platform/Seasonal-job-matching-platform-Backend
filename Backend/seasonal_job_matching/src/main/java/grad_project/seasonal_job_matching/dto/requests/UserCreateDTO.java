package grad_project.seasonal_job_matching.dto.requests;

import java.util.List; //idk but a previous error said I needed to add this and error was resolved so idk

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

//can make responsedto if we want to return data to frontend
@Data
public class UserCreateDTO {


    private String name;

    private String country;

    
    private String number;

    @Email
    private String email;

    @Size(min = 8, max = 100)
    @Pattern(regexp = ".*[A-Z].*", message = "Password must contain at least one capital letter")
    @Pattern(regexp = ".*[0-9].*", message = "Password must contain at least one number")
    private String password;

    private String currency = "EGP";

    //private List<String> fieldsOfInterest;

}
