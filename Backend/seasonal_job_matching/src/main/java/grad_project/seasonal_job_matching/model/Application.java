package grad_project.seasonal_job_matching.model;

import java.sql.Date;

import grad_project.seasonal_job_matching.model.enums.ApplicationStatus;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data // getters,setters, required args constructor
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "applications")
public class Application {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column
    private long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "userID", nullable = false) // created the foreign key column
    @JsonIgnoreProperties("ownedApplications") // Add this line
    private User user; // user that applied, has ID

    @Enumerated(EnumType.STRING)
    private ApplicationStatus applicationStatus;

    @ManyToOne(fetch = FetchType.LAZY)
    @JsonIgnoreProperties("listofJobApplications")
    @JoinColumn(name = "jobID", nullable = false)
    private Job job;

    private Date createdAt;

    private String describeYourself;

    @Column
    private String interviewDate;
    @Column
    private String interviewTime;
    @Column
    private String interviewLocation;
}
