package com.example.cs2panel.ai.service;

import com.example.cs2panel.ai.entity.AIJob;
import com.example.cs2panel.ai.entity.AIScenario;
import com.example.cs2panel.ai.repository.AIJobRepository;
import com.example.cs2panel.ai.repository.AIScenarioRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class AIScenarioService {

    private final AIScenarioRepository scenarioRepository;
    private final AIJobRepository jobRepository;
    private final DeepSeekService deepSeekService;

    @Transactional
    public AIScenario createScenario(AIScenario scenario) {
        scenario.setStatus("DRAFT");
        scenario.setVersion(1);
        scenario = scenarioRepository.save(scenario);
        log.info("AI scenario created: {}", scenario.getName());
        return scenario;
    }

    public AIScenario getScenario(Long id) {
        return scenarioRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Scenario not found"));
    }

    public List<AIScenario> getAllScenarios() {
        return scenarioRepository.findAll();
    }

    @Transactional
    public AIJob executeScenario(Long scenarioId) {
        AIScenario scenario = getScenario(scenarioId);

        AIJob job = AIJob.builder()
                .scenario(scenario)
                .status("PENDING")
                .build();

        job = jobRepository.save(job);
        log.info("AI job created: {} for scenario: {}", job.getId(), scenario.getName());

        // Execute asynchronously
        executeJobAsync(job.getId());

        return job;
    }

    @Async("aiJobExecutor")
    @Transactional
    public void executeJobAsync(Long jobId) {
        AIJob job = jobRepository.findById(jobId)
                .orElseThrow(() -> new RuntimeException("Job not found"));

        try {
            job.setStatus("RUNNING");
            job.setStartedAt(LocalDateTime.now());
            jobRepository.save(job);

            // Build prompt from scenario
            String prompt = buildPromptFromScenario(job.getScenario());

            // Call DeepSeek API
            String generatedCode = deepSeekService.generateCode(prompt);

            // Save result
            job.setStatus("COMPLETED");
            job.setCompletedAt(LocalDateTime.now());
            job.setResultData(Map.of("code", generatedCode));
            job.setArtifactUrl("/artifacts/" + job.getId() + "/plugin.sp");

            jobRepository.save(job);
            log.info("AI job completed: {}", job.getId());

        } catch (Exception e) {
            log.error("AI job failed: {}", jobId, e);
            job.setStatus("FAILED");
            job.setCompletedAt(LocalDateTime.now());
            job.setErrorMessage(e.getMessage());
            jobRepository.save(job);
        }
    }

    public AIJob getJob(Long id) {
        return jobRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Job not found"));
    }

    public List<AIJob> getScenarioJobs(Long scenarioId) {
        return jobRepository.findByScenarioIdOrderByCreatedAtDesc(scenarioId);
    }

    private String buildPromptFromScenario(AIScenario scenario) {
        Map<String, Object> data = scenario.getScenarioData();

        StringBuilder prompt = new StringBuilder();
        prompt.append("Generate a CS2 SourceMod plugin with the following requirements:\n\n");

        if (data.containsKey("plugin_name")) {
            prompt.append("Plugin Name: ").append(data.get("plugin_name")).append("\n");
        }

        if (data.containsKey("description")) {
            prompt.append("Description: ").append(data.get("description")).append("\n");
        }

        if (data.containsKey("features")) {
            prompt.append("\nFeatures:\n");
            Object features = data.get("features");
            if (features instanceof List) {
                for (Object feature : (List<?>) features) {
                    prompt.append("- ").append(feature).append("\n");
                }
            }
        }

        prompt.append("\nGenerate complete, production-ready SourcePawn code.");

        return prompt.toString();
    }
}
