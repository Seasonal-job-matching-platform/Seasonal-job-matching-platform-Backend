package grad_project.seasonal_job_matching.services;

import java.time.LocalDateTime;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.CacheManager;
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

        private static final Logger logger = LoggerFactory.getLogger(PaymentService.class);

        // Base price: 50 EGP in piasters (smallest unit)
        private static final long BASE_AMOUNT_PIASTERS = 5000L;
        private static final String BASE_CURRENCY = "EGP";

        private final UserRepository userRepository;
        private final PaymentTransactionRepository transactionRepository;
        private final ExchangeRateService exchangeRateService;
        private final CacheManager cacheManager;

        public PaymentService(@Value("${stripe.api.key}") String stripeApiKey,
                        UserRepository userRepository,
                        PaymentTransactionRepository transactionRepository,
                        ExchangeRateService exchangeRateService,
                        CacheManager cacheManager) {
                Stripe.apiKey = stripeApiKey;
                this.transactionRepository = transactionRepository;
                this.userRepository = userRepository;
                this.exchangeRateService = exchangeRateService;
                this.cacheManager = cacheManager;
        }

        @Transactional
        public String createJobPackageSession(Long userId, String currency) throws Exception {
                User user = userRepository.findById(userId)
                                .orElseThrow(() -> new RuntimeException("User not found"));

                // Convert the base price (50 EGP) to the employer's chosen currency
                String targetCurrency = currency.toUpperCase();
                long convertedAmount = exchangeRateService.convertAmount(
                                BASE_AMOUNT_PIASTERS, BASE_CURRENCY, targetCurrency);

                logger.info("Payment: Converting {} {} ({} piasters) -> {} {} (smallest unit) for user {}",
                                BASE_AMOUNT_PIASTERS / 100.0, BASE_CURRENCY,
                                BASE_AMOUNT_PIASTERS,
                                convertedAmount / 100.0, targetCurrency,
                                userId);

                // 1. Ask Stripe to create the checkout page
                SessionCreateParams params = SessionCreateParams.builder()
                                .setSuccessUrl("https://seasonal-job-matching-platform-frontend.pages.dev/payment-success")
                                .setCancelUrl("https://seasonal-job-matching-platform-frontend.pages.dev/dashboard?payment=cancelled")
                                .setMode(SessionCreateParams.Mode.PAYMENT)
                                .putMetadata("userId", userId.toString())
                                .addLineItem(SessionCreateParams.LineItem.builder()
                                                .setQuantity(1L)
                                                .setPriceData(SessionCreateParams.LineItem.PriceData.builder()
                                                                .setCurrency(targetCurrency.toLowerCase())
                                                                .setUnitAmount(convertedAmount)
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
                transaction.setAmount(convertedAmount);
                transaction.setCurrency(targetCurrency);
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

                // Evict user profile from Redis cache so frontend sees updated credits immediately
                if (cacheManager != null && cacheManager.getCache("profile") != null) {
                        cacheManager.getCache("profile").evict(user.getId());
                }

                System.out.println("Successfully added 5 credits to User ID: " + user.getId());
        }
}
