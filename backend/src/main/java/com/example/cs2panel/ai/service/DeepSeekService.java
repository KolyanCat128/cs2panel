package com.example.cs2panel.ai.service;

import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class DeepSeekService {

    private final WebClient.Builder webClientBuilder;

    @Value("${app.deepseek.api-key:}")
    private String apiKey;

    @Value("${app.deepseek.api-url:https://api.deepseek.com/v1}")
    private String apiUrl;

    @Value("${app.deepseek.model:deepseek-coder-v3}")
    private String model;

    @Value("${app.deepseek.max-tokens:8000}")
    private int maxTokens;

    @CircuitBreaker(name = "deepseek")
    public String generateCode(String prompt) {
        if (apiKey == null || apiKey.isEmpty()) {
            log.warn("DeepSeek API key not configured");
            return "// DeepSeek API key not configured\n// Placeholder code generated";
        }

        Map<String, Object> request = Map.of(
                "model", model,
                "messages", new Object[]{
                        Map.of("role", "system", "content", "You are an expert CS2 plugin developer using SourceMod and MetaMod."),
                        Map.of("role", "user", "content", prompt)
                },
                "max_tokens", maxTokens,
                "temperature", 0.7
        );

        try {
            Map<String, Object> response = webClientBuilder.build()
                    .post()
                    .uri(apiUrl + "/chat/completions")
                    .header("Authorization", "Bearer " + apiKey)
                    .header("Content-Type", "application/json")
                    .bodyValue(request)
                    .retrieve()
                    .bodyToMono(Map.class)
                    .block();

            if (response != null && response.containsKey("choices")) {
                Object[] choices = (Object[]) response.get("choices");
                if (choices.length > 0) {
                    Map<String, Object> choice = (Map<String, Object>) choices[0];
                    Map<String, Object> message = (Map<String, Object>) choice.get("message");
                    return (String) message.get("content");
                }
            }

            log.error("Unexpected response from DeepSeek API");
            return "// Error generating code";

        } catch (Exception e) {
            log.error("Failed to call DeepSeek API", e);
            throw new RuntimeException("DeepSeek API call failed", e);
        }
    }
}
