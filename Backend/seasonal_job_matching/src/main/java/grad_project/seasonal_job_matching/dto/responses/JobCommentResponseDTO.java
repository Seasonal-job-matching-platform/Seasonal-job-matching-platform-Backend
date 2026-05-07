package grad_project.seasonal_job_matching.dto.responses;

import java.time.LocalDateTime;
import java.util.List;

import lombok.Data;

@Data
public class JobCommentResponseDTO {

    private long id;
    private String comment;
    private long userId;
    private String userName;
    private LocalDateTime createdAt;

    private List<JobCommentResponseDTO> replies;
}
