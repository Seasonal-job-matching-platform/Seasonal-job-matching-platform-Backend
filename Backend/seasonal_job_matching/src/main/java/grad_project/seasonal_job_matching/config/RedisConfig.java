package grad_project.seasonal_job_matching.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;
import org.springframework.boot.autoconfigure.data.redis.LettuceClientConfigurationBuilderCustomizer;
import org.springframework.boot.autoconfigure.data.redis.LettuceClientConfigurationBuilderCustomizer;

import java.time.Duration;

@Configuration
public class RedisConfig {

        @Bean
        public RedisCacheManager cacheManager(RedisConnectionFactory connectionFactory) {

                // so data saved on redis in readable data instead of Java bytes
                GenericJackson2JsonRedisSerializer jsonSerializer = new GenericJackson2JsonRedisSerializer();

                // Default: Keep data 7 days (Requires manual @CacheEvict)
                RedisCacheConfiguration defaultConfig = RedisCacheConfiguration.defaultCacheConfig()
                                .entryTtl(Duration.ofDays(7))
                                .disableCachingNullValues()
                                .serializeValuesWith(RedisSerializationContext.SerializationPair
                                                .fromSerializer(jsonSerializer));

                // Delete after 4 hours
                RedisCacheConfiguration shortTtlConfig = RedisCacheConfiguration.defaultCacheConfig()
                                .entryTtl(Duration.ofHours(6));

                return RedisCacheManager.builder(connectionFactory)
                                .cacheDefaults(defaultConfig)
                                // Any cache named "recommendedJobs" will use the 4 hour rule
                                .withCacheConfiguration("recommendedJobs", shortTtlConfig)
                                .build();
        }

        @Bean
        public LettuceClientConfigurationBuilderCustomizer lettuceClientConfigurationBuilderCustomizer() {
                return builder -> {
                // Check if we are running in Heroku with a secure REDIS URL
                String redisUrl = System.getenv("SPRING_DATA_REDIS_URL");
                
                if (redisUrl != null && redisUrl.startsWith("rediss://")) {
                        // Force SSL but completely disable the strict certificate check!
                        builder.useSsl().disablePeerVerification();
                }
                };
        }
}
