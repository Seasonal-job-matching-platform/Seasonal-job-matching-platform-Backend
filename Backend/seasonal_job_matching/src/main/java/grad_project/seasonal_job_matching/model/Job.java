package grad_project.seasonal_job_matching.model;

import java.sql.Date;
import java.util.List;

import org.hibernate.annotations.Type;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import grad_project.seasonal_job_matching.model.enums.Salary;
import grad_project.seasonal_job_matching.model.enums.JobStatus;
import grad_project.seasonal_job_matching.model.enums.JobType;
import grad_project.seasonal_job_matching.model.enums.WorkArrangement;
import io.hypersistence.utils.hibernate.type.array.ListArrayType;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "jobs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Job {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column
    private long id;

    @Column(nullable = false)
    private String title;

    @Column
    private String description;

    @Column
    @Enumerated(EnumType.STRING)
    private JobType type;

    @Column(nullable = false)
    private String location;

    @Column
    private Date startDate;

    // @Column
    // private Date endDate; //check if you can remove this without breaking
    // everything

    @ManyToOne
    @JoinColumn(name = "jobposterID", nullable = false, referencedColumnName = "id") // foreign key from user table
    // @Column
    @JsonIgnoreProperties({ "ownedJobs", "password", "ownedApplications" }) // to prevent infinite loop of getting user
                                                                            // and all his info and then getting all of
                                                                            // users jobs which is this one and so on
    private User jobPoster;

    // Both Need to add alter to table first before running this
    // @Column
    // private Salary salary;

    @Column
    private float amount;

    @Column // Let JPA handle the column definition based on the enum
    @Enumerated(EnumType.STRING)
    private Salary salary;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private JobStatus status;

    @Column
    private Integer numOfPositions;

    @Column // Need to add alter to table first before running this
    private Integer duration;

    @Column
    private Date createdAt;

    @Column
    @Enumerated(EnumType.STRING)
    private WorkArrangement workArrangement;

    // Add to job table
    @OneToMany(mappedBy = "job", cascade = CascadeType.ALL) // job has many applications
    @JsonIgnoreProperties("job")
    private List<Application> listOfJobApplications;

    @Type(ListArrayType.class)
    @Column(columnDefinition = "text[]")
    private List<String> requirements;

    @Type(ListArrayType.class)
    @Column(columnDefinition = "text[]")
    private List<String> categories;

    @Type(ListArrayType.class)
    @Column(columnDefinition = "text[]")
    private List<String> benefits;

    @OneToMany(mappedBy = "job", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnoreProperties("job")
    private List<JobComment> comments;

    public Job(int id, String title, String description, JobType type, String location, Date startDate, User jobposter,
            float amount, Salary salary, Integer duration, int numofpositions, JobStatus status,
            WorkArrangement workarrangement) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.type = type;
        this.location = location;
        this.startDate = startDate;
        // this.endDate = endDate;
        this.jobPoster = jobposter;
        this.salary = salary; // when changing this, change argument to Salary instead of float
        this.amount = amount;
        this.duration = duration;
        this.numOfPositions = numofpositions;
        this.status = status;
        this.workArrangement = workarrangement;
    }

}
