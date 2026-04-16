package grad_project.seasonal_job_matching.controller;

import com.stripe.exception.SignatureVerificationException;
import com.stripe.model.Event;
import com.stripe.model.checkout.Session;
import com.stripe.net.Webhook;
import grad_project.seasonal_job_matching.services.PaymentService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/webhooks")
public class StripeWebhookController {

    private final PaymentService paymentService;
    private final String webhookSecret;

    public StripeWebhookController(
            PaymentService paymentService,
            @Value("${stripe.webhook.secret}") String webhookSecret) {
        this.paymentService = paymentService;
        this.webhookSecret = webhookSecret;
    }

    @PostMapping("/stripe")
    public ResponseEntity<String> handleStripeWebhook(
            @RequestBody String payload,
            @RequestHeader("Stripe-Signature") String sigHeader) {

        Event event;

        try {
            event = Webhook.constructEvent(payload, sigHeader, webhookSecret);
        } catch (SignatureVerificationException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Invalid signature");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Invalid payload");
        }

        // ROUTING: Check if the event is a successful checkout
        if ("checkout.session.completed".equals(event.getType())) {
            
            // STANDARD EXTRACTION: Completely removes the checked exception that was crashing Maven!
            Session session = (Session) event.getDataObjectDeserializer().getObject().orElse(null);
            
            // If the session is mysteriously null, tell Stripe so we can see it in the dashboard
            if (session == null) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body("Fulfillment Crash: Session object is null!");
            }
            
            if ("paid".equals(session.getPaymentStatus())) {
                try {
                    paymentService.fulfillOrder(session.getId());
                } catch (Exception e) {
                    // THE TRAP DETECTOR: Catch the database crash and send it to Stripe Dashboard
                    e.printStackTrace();
                    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                                         .body("Fulfillment Crash: " + e.getMessage());
                }
            }
        }

        return ResponseEntity.ok("Webhook processed");
    }
}