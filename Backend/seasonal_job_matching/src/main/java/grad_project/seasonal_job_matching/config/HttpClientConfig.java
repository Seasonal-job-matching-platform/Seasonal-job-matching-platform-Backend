package grad_project.seasonal_job_matching.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.client.ClientHttpRequestFactory;


@Configuration
public class HttpClientConfig {


    @Bean
    public RestTemplate restTemplate(){
        RestTemplate restTemplate = new RestTemplate(); //manages process of sending and parsing data
        restTemplate.setRequestFactory(clientHttpRequestFactory());
        return restTemplate;
    }

    @Bean
    public ClientHttpRequestFactory clientHttpRequestFactory(){
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory(); //acts as a configuration holder and creates a wrapper for HttpURLConnection
        factory.setConnectTimeout(10000); //10 seconds to timeout while connecting to server
        factory.setReadTimeout(25000); //25 seconds or will timeout while reading data
        return factory;
    }
}

/*
Your Code talks to RestTemplate.

RestTemplate talks to ClientHttpRequestFactory.

ClientHttpRequestFactory creates the HttpURLConnection.

HttpURLConnection talks to the Internet.
*/