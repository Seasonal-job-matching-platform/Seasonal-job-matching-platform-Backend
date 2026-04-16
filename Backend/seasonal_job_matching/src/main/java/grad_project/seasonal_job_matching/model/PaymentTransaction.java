package grad_project.seasonal_job_matching.model;

import java.time.LocalDateTime;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaymentTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, unique = true)
    private String paymentSessionId;

    @Column(nullable = false)
    private Long amount;

    @Column(nullable = false)
    private String status; // accepted/rejected

    @Column(nullable = false)
    private LocalDateTime createdAt;
}
