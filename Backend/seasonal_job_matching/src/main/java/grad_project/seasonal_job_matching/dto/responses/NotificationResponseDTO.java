package grad_project.seasonal_job_matching.dto.responses;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class NotificationResponseDTO {

    private long id;

    private String message;

    private String title;

    private long recipientId;

    private String recipientName;

    private Boolean isRead;

    private LocalDateTime createdAt;
}
