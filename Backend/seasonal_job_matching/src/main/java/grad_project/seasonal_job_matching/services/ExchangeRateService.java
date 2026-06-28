package grad_project.seasonal_job_matching.services;

import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

/**
 * Service for fetching and caching exchange rates from ExchangeRate-API (v6).
 * Rates are cached in Redis for 24 hours and refreshed daily via @Scheduled.
 * The base currency is USD.
 *
 * API docs: https://www.exchangerate-api.com/docs/standard-requests
 */
@Service
public class ExchangeRateService {

    private static final Logger logger = LoggerFactory.getLogger(ExchangeRateService.class);

    // ExchangeRate-API v6 endpoint: /v6/{API_KEY}/latest/{BASE_CURRENCY}
    private static final String API_URL = "https://v6.exchangerate-api.com/v6/%s/latest/EGP";

    @Value("${exchangerate.api.key}")
    private String apiKey;

    private final RestTemplate restTemplate;

    public ExchangeRateService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    /**
     * Fetches exchange rates from the API and caches them in Redis under the
     * "exchangeRates" cache with a 24-hour TTL.
     * All rates are relative to 1 USD.
     *
     * @return a Map of currency codes to their exchange rates (e.g. {"EGP": 50.5, "EUR": 0.92, ...})
     */
    @Cacheable(value = "exchangeRates", key = "'latest'")
    public Map<String, Double> getExchangeRates() {
        logger.info("Cache miss - Fetching fresh exchange rates from ExchangeRate-API");
        return fetchRatesFromApi();
    }

    /**
     * Converts an amount from one currency to another using cached exchange rates.
     * Since the base is USD, we convert: sourceCurrency -> USD -> targetCurrency.
     *
     * @param amountInSmallestUnit the amount in the source currency's smallest unit (e.g. 5000 piasters = 50 EGP)
     * @param sourceCurrency       the source currency code (e.g. "EGP")
     * @param targetCurrency       the target currency code (e.g. "USD")
     * @return the converted amount in the target currency's smallest unit (e.g. cents for USD)
     */
    public long convertAmount(long amountInSmallestUnit, String sourceCurrency, String targetCurrency) {
        if (sourceCurrency.equalsIgnoreCase(targetCurrency)) {
            return amountInSmallestUnit;
        }

        Map<String, Double> rates = getExchangeRates();

        String sourceUpper = sourceCurrency.toUpperCase();
        String targetUpper = targetCurrency.toUpperCase();

        Double sourceRate = rates.get(sourceUpper);
        Double targetRate = rates.get(targetUpper);

        if (sourceRate == null) {
            throw new RuntimeException("Unsupported source currency: " + sourceCurrency);
        }
        if (targetRate == null) {
            throw new RuntimeException("Unsupported target currency: " + targetCurrency);
        }

        // Convert: sourceAmount -> USD -> targetAmount
        // sourceRate = how many units of source per 1 USD
        // targetRate = how many units of target per 1 USD
        // So: amountInUSD = amountInSource / sourceRate
        //     amountInTarget = amountInUSD * targetRate
        double converted = (amountInSmallestUnit / sourceRate) * targetRate;

        // Round to nearest whole number (smallest unit of target currency)
        return Math.round(converted);
    }

    /**
     * Converts a float amount from sourceCurrency to targetCurrency.
     */
    public float convertFloatAmount(float amount, String sourceCurrency, String targetCurrency) {
        if (sourceCurrency.equalsIgnoreCase(targetCurrency)) {
            return amount;
        }
        long amountInSmallest = Math.round(amount * 100.0);
        long convertedInSmallest = convertAmount(amountInSmallest, sourceCurrency, targetCurrency);
        return (float) (convertedInSmallest / 100.0);
    }

    /**
     * Scheduled to run daily at midnight UTC.
     * Evicts the old cache entry and forces a fresh fetch on the next call.
     */
    @Scheduled(cron = "0 0 0 * * *") // Every day at midnight UTC
    @CacheEvict(value = "exchangeRates", key = "'latest'")
    public void refreshExchangeRatesCache() {
        logger.info("Scheduled task: Evicting exchange rates cache. Fresh rates will be fetched on next request.");
        // After eviction, the next call to getExchangeRates() will trigger a cache miss
        // and fetch fresh rates from the API
        try {
            // Immediately re-populate the cache so the first user doesn't wait
            getExchangeRates();
            logger.info("Scheduled task: Successfully re-populated exchange rates cache.");
        } catch (Exception e) {
            logger.error("Scheduled task: Failed to refresh exchange rates. " +
                    "The cache was evicted; rates will be fetched on the next request. Error: {}", e.getMessage());
        }
    }

    /**
     * Calls ExchangeRate-API v6 and extracts the "conversion_rates" map.
     *
     * Example response:
     * {
     *   "result": "success",
     *   "base_code": "USD",
     *   "conversion_rates": { "USD": 1, "EGP": 50.45, "EUR": 0.92, ... }
     * }
     */
    private Map<String, Double> fetchRatesFromApi() {
        String url = String.format(API_URL, apiKey);

        try {
            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                    url,
                    HttpMethod.GET,
                    null,
                    new ParameterizedTypeReference<Map<String, Object>>() {
                    });

            Map<String, Object> body = response.getBody();

            if (body == null || !"success".equals(body.get("result"))) {
                throw new RuntimeException("ExchangeRate-API returned an error: " + body);
            }

            if (!body.containsKey("conversion_rates")) {
                throw new RuntimeException("Invalid response from ExchangeRate-API: missing conversion_rates");
            }

            @SuppressWarnings("unchecked")
            Map<String, Object> rawRates = (Map<String, Object>) body.get("conversion_rates");
            Map<String, Double> rates = new java.util.HashMap<>();
            if (rawRates != null) {
                for (Map.Entry<String, Object> entry : rawRates.entrySet()) {
                    Object val = entry.getValue();
                    if (val instanceof Number) {
                        rates.put(entry.getKey(), ((Number) val).doubleValue());
                    }
                }
            }

            logger.info("Successfully fetched exchange rates. {} currencies available.", rates.size());
            return rates;

        } catch (Exception e) {
            logger.error("Failed to fetch exchange rates from API: {}", e.getMessage());
            throw new RuntimeException("Could not fetch exchange rates. Please try again later.", e);
        }
    }
}
