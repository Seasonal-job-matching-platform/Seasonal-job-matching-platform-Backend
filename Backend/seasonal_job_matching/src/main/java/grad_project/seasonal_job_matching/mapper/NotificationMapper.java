package grad_project.seasonal_job_matching.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import grad_project.seasonal_job_matching.dto.responses.NotificationResponseDTO;
import grad_project.seasonal_job_matching.model.Notification;

@Mapper(componentModel = "spring")
public interface NotificationMapper {

    @Mapping(target = "recipientId", source = "recipient.id")
    @Mapping(target = "recipientName", source = "recipient.name")
    NotificationResponseDTO maptoreturnNotification(Notification notification);

}
