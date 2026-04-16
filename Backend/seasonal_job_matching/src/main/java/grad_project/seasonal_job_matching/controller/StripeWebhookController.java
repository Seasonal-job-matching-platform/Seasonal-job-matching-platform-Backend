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

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/webhooks")
public class StripeWebhookController {

    private final PaymentService paymentService;
    private final String webhookSecret;

    public StripeWebhookController(
            PaymentService paymentService,
            // You will add this new key to your application.properties!
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
            // VERIFICATION: This proves the request actually came from Stripe and wasn't
            // faked
            event = Webhook.constructEvent(payload, sigHeader, webhookSecret);
        } catch (SignatureVerificationException e) {
            System.err.println("Webhook signature verification failed.");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Invalid signature");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Invalid payload");
        }

        // ROUTING: Check if the event is a successful checkout
        // if ("checkout.session.completed".equals(event.getType())) {

        //     // Extract the session object from the webhook event
        //     Session session = (Session) event.getDataObjectDeserializer().getObject().orElse(null);

        //     if (session != null && "paid".equals(session.getPaymentStatus())) {
        //         // FULFILLMENT: Safely update the database!
        //         String sessionId = session.getId();
        //         paymentService.fulfillOrder(sessionId);
        //     }
        // }
        if ("checkout.session.completed".equals(event.getType())) {
            
            // 1. BULLETPROOF EXTRACTION: Fixes the silent 'null' SDK version bug
            Session session;
            if (event.getDataObjectDeserializer().getObject().isPresent()) {
                session = (Session) event.getDataObjectDeserializer().getObject().get();
            } else {
                session = (Session) event.getDataObjectDeserializer().deserializeUnsafe();
            }
            
            if (session != null && "paid".equals(session.getPaymentStatus())) {
                String sessionId = session.getId();
                
                try {
                    paymentService.fulfillOrder(sessionId);
                } catch (Exception e) {
                    // 2. THE TRAP DETECTOR: If the DB crashes, tell Stripe so we can see the error!
                    e.printStackTrace();
                    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                                         .body("Fulfillment Crash: " + e.getMessage());
                }

                // Always return a 200 OK to Stripe quickly, so they know you received it
                return ResponseEntity.ok("Webhook processed");
            }
        }
    }
}