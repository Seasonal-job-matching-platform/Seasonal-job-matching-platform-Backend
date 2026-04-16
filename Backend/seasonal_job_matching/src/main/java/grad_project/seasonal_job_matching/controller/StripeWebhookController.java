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
            
            Session session = null;
            
            // Force Stripe to deserialize the object despite the version mismatch, 
            // and we use a generic Exception catch to stop Maven from crashing your build.
            try {
                if (event.getDataObjectDeserializer().getObject().isPresent()) {
                    session = (Session) event.getDataObjectDeserializer().getObject().get();
                } else {
                    session = (Session) event.getDataObjectDeserializer().deserializeUnsafe();
                }
            } catch (Exception e) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body("Fulfillment Crash: Deserialization failed - " + e.getMessage());
            }
            
            // 2. The Trap Detector (just in case)
            if (session == null) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body("Fulfillment Crash: Session object is STILL null!");
            }
            
            if ("paid".equals(session.getPaymentStatus())) {
                try {
                    paymentService.fulfillOrder(session.getId());
                } catch (Exception e) {
                    e.printStackTrace();
                    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                                         .body("Fulfillment Crash: Database Error - " + e.getMessage());
                }
            }
        }

        return ResponseEntity.ok("Webhook processed");
    }
}