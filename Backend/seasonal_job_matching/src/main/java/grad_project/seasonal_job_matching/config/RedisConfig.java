package grad_project.seasonal_job_matching.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.RedisPassword;
import org.springframework.data.redis.connection.RedisStandaloneConfiguration;
import org.springframework.data.redis.connection.lettuce.LettuceClientConfiguration;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;

import java.net.URI;
import java.time.Duration;

import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

@Configuration
public class RedisConfig {

        @Bean
        public RedisCacheManager cacheManager(RedisConnectionFactory connectionFactory) {

                // 1. Create a Custom Super-Mapper
                ObjectMapper objectMapper = new ObjectMapper();

                // Teach Jackson how to handle LocalDateTime
                objectMapper.registerModule(new JavaTimeModule());
                objectMapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS); // Saves dates as readable text

                // Teach Jackson to embed Type IDs so it doesn't forget what's inside a List
                objectMapper.activateDefaultTyping(
                                objectMapper.getPolymorphicTypeValidator(),
                                ObjectMapper.DefaultTyping.NON_FINAL,
                                JsonTypeInfo.As.PROPERTY);

                // so data saved on redis in readable data instead of Java bytes, using our custom mapper
                GenericJackson2JsonRedisSerializer jsonSerializer = new GenericJackson2JsonRedisSerializer(objectMapper);

                // Default: Keep data 7 days (Requires manual @CacheEvict)
                RedisCacheConfiguration defaultConfig = RedisCacheConfiguration.defaultCacheConfig()
                                .entryTtl(Duration.ofDays(7))
                                .disableCachingNullValues()
                                .serializeValuesWith(RedisSerializationContext.SerializationPair
                                                .fromSerializer(jsonSerializer));

                // Delete after 6 hours
                RedisCacheConfiguration shortTtlConfig = RedisCacheConfiguration.defaultCacheConfig()
                                .entryTtl(Duration.ofHours(6));

                // Exchange rates: 24 hour TTL (API updates once per day)
                RedisCacheConfiguration exchangeRateTtlConfig = RedisCacheConfiguration.defaultCacheConfig()
                                .entryTtl(Duration.ofHours(24))
                                .disableCachingNullValues()
                                .serializeValuesWith(RedisSerializationContext.SerializationPair
                                                .fromSerializer(jsonSerializer));

                return RedisCacheManager.builder(connectionFactory)
                                .cacheDefaults(defaultConfig)
                                // Any cache named "recommendedJobs" will use the 4 hour rule
                                .withCacheConfiguration("recommendedJobs", shortTtlConfig)
                                // Exchange rates cached for 24 hours
                                .withCacheConfiguration("exchangeRates", exchangeRateTtlConfig)
                                .build();

        }

        @Bean
        public RedisConnectionFactory redisConnectionFactory() {
                String redisUrl = System.getenv("REDIS_URL");

                // Localhost fallback (If you run this on your laptop, it connects locally)
                if (redisUrl == null) {
                        return new LettuceConnectionFactory("localhost", 6379);
                }

                // Parse the Heroku REDIS_URL
                URI uri = URI.create(redisUrl);
                RedisStandaloneConfiguration config = new RedisStandaloneConfiguration();
                config.setHostName(uri.getHost());
                config.setPort(uri.getPort());

                // Extract the password, ignoring Heroku's dummy "h:" username
                if (uri.getUserInfo() != null) {
                        String[] userInfo = uri.getUserInfo().split(":", 2);
                        config.setPassword(RedisPassword.of(userInfo[userInfo.length - 1]));
                }

                // Handle SSL/TLS dynamically (Bypasses the Certificate Error if "rediss://" is
                // used)
                LettuceClientConfiguration.LettuceClientConfigurationBuilder builder = LettuceClientConfiguration
                                .builder();
                if (redisUrl.startsWith("rediss://")) {
                        builder.useSsl().disablePeerVerification();
                }

                return new LettuceConnectionFactory(config, builder.build());
        }

}