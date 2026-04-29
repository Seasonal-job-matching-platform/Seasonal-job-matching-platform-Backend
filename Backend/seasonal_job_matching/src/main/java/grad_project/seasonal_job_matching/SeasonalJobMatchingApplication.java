package grad_project.seasonal_job_matching;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication()
@EnableAsync
@EnableCaching
public class SeasonalJobMatchingApplication {

  public static void main(String[] args) {
    SpringApplication.run(SeasonalJobMatchingApplication.class, args);
  }

}
/*
 * 7. add volume in docker compose
 * 8. Add hashing for passwords (passwordencrypt)
 * 9. security when data entered in url that can be edited to access
 * unauthorized data.
 * //check modelmapper, ensure naming convention of properties (if not the same
 * explicitly mention like @mapping)
 * 
 * Test user data
 * "name":"fahad",
 * "address" : "lebanon",
 * "number" : "11111111111",
 * "password" : "12345678",
 * "email" : "hell1o@gmail.com"
 * 
 * Test job data
 * "jobposterID": 1,
 * "title": "Backend Developer",
 * "description": "Backend development",
 * "type": "CONTRACT",
 * "status": "REVIEWING",
 * "salary": 100,
 * "location": "Egypt",
 * "startDate": "2024-10-12",
 * "endDate": "2024-11-15",
 * "numofpositions": 5,
 * "workarrangement" : "REMOTE"
 */