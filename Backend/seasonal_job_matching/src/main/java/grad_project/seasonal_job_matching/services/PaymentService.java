package grad_project.seasonal_job_matching.services;

import java.time.LocalDateTime;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.stripe.Stripe;
import com.stripe.model.checkout.Session;
import com.stripe.param.checkout.SessionCreateParams;

import grad_project.seasonal_job_matching.model.PaymentTransaction;
import grad_project.seasonal_job_matching.model.User;
import grad_project.seasonal_job_matching.repository.PaymentTransactionRepository;
import grad_project.seasonal_job_matching.repository.UserRepository;
import jakarta.transaction.Transactional;

@Service
public class PaymentService {

        private final UserRepository userRepository;
        private final PaymentTransactionRepository transactionRepository;

        public PaymentService(@Value("${stripe.api.key}") String stripeApiKey, UserRepository userRepository,
                        PaymentTransactionRepository transactionRepository) {
                Stripe.apiKey = stripeApiKey;
                this.transactionRepository = transactionRepository;
                this.userRepository = userRepository;
        }

        @Transactional
        public String createJobPackageSession(Long userId) throws Exception {
                User user = userRepository.findById(userId)
                                .orElseThrow(() -> new RuntimeException("User not found"));

                long amountInPiasters = 5000L; // 50 EGP

                // 1. Ask Stripe to create the checkout page
                SessionCreateParams params = SessionCreateParams.builder()
                                .setSuccessUrl("http://localhost:3000/payment-success?session_id={CHECKOUT_SESSION_ID}")
                                .setCancelUrl("http://localhost:3000/payment-cancelled")
                                .setMode(SessionCreateParams.Mode.PAYMENT)
                                .putMetadata("userId", userId.toString())
                                .addLineItem(SessionCreateParams.LineItem.builder()
                                                .setQuantity(1L)
                                                .setPriceData(SessionCreateParams.LineItem.PriceData.builder()
                                                                .setCurrency("egp")
                                                                .setUnitAmount(amountInPiasters)
                                                                .setProductData(SessionCreateParams.LineItem.PriceData.ProductData
                                                                                .builder()
                                                                                .setName("5 Job Posting Credits")
                                                                                .build())
                                                                .build())
                                                .build())
                                .build();

                Session session = Session.create(params);

                // 2. Log the attempt in our database as "PENDING"
                PaymentTransaction transaction = new PaymentTransaction();
                transaction.setUser(user);
                transaction.setPaymentSessionId(session.getId());
                transaction.setAmount(amountInPiasters);
                transaction.setStatus("PENDING");
                transaction.setCreatedAt(LocalDateTime.now());

                transactionRepository.save(transaction);

                // 3. Return the URL so the controller can send it to React
                return session.getUrl();
        }

        // This is called EXCLUSIVELY by the Webhook
        @Transactional
        public void fulfillOrder(String stripeSessionId) {
                PaymentTransaction transaction = transactionRepository.findByPaymentSessionId(stripeSessionId)
                                .orElseThrow(() -> new RuntimeException(
                                                "Transaction not found for session: " + stripeSessionId));

                if ("SUCCESS".equals(transaction.getStatus())) {
                        return; // Already processed, ignore duplicate webhooks
                }

                // 1. Mark transaction as successful
                transaction.setStatus("SUCCESS");
                transactionRepository.save(transaction);

                // 2. Give the user their credits!
                User user = transaction.getUser();

                // Initialize if null to avoid NullPointerException
                if (user.getJobPostingCredits() == null) {
                        user.setJobPostingCredits(0);
                }

                user.setJobPostingCredits(user.getJobPostingCredits() + 5);
                userRepository.save(user);

                System.out.println("Successfully added 5 credits to User ID: " + user.getId());
        }
}
