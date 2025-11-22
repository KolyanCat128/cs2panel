package com.example.cs2panel.ai.controller;

import com.example.cs2panel.ai.entity.AIJob;
import com.example.cs2panel.ai.entity.AIScenario;
import com.example.cs2panel.ai.service.AIScenarioService;
import com.example.cs2panel.common.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/ai/scenarios")
@RequiredArgsConstructor
@Tag(name = "AI Scenarios", description = "AI-powered CS2 plugin generation")
public class AIScenarioController {

    private final AIScenarioService scenarioService;

    @PostMapping
    @Operation(summary = "Create AI scenario")
    @PreAuthorize("hasAuthority('AI_SCENARIO_CREATE')")
    public ResponseEntity<ApiResponse<AIScenario>> createScenario(@RequestBody AIScenario scenario) {
        AIScenario created = scenarioService.createScenario(scenario);
        return ResponseEntity.ok(ApiResponse.success(created, "Scenario created"));
    }

    @GetMapping
    @Operation(summary = "Get all scenarios")
    @PreAuthorize("hasAuthority('AI_SCENARIO_CREATE')")
    public ResponseEntity<ApiResponse<List<AIScenario>>> getAllScenarios() {
        List<AIScenario> scenarios = scenarioService.getAllScenarios();
        return ResponseEntity.ok(ApiResponse.success(scenarios, "Scenarios retrieved"));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get scenario by ID")
    @PreAuthorize("hasAuthority('AI_SCENARIO_CREATE')")
    public ResponseEntity<ApiResponse<AIScenario>> getScenario(@PathVariable Long id) {
        AIScenario scenario = scenarioService.getScenario(id);
        return ResponseEntity.ok(ApiResponse.success(scenario, "Scenario retrieved"));
    }

    @PostMapping("/{id}/execute")
    @Operation(summary = "Execute AI scenario")
    @PreAuthorize("hasAuthority('AI_SCENARIO_EXECUTE')")
    public ResponseEntity<ApiResponse<AIJob>> executeScenario(@PathVariable Long id) {
        AIJob job = scenarioService.executeScenario(id);
        return ResponseEntity.ok(ApiResponse.success(job, "Job created and queued"));
    }

    @GetMapping("/{id}/jobs")
    @Operation(summary = "Get scenario jobs")
    @PreAuthorize("hasAuthority('AI_SCENARIO_CREATE')")
    public ResponseEntity<ApiResponse<List<AIJob>>> getScenarioJobs(@PathVariable Long id) {
        List<AIJob> jobs = scenarioService.getScenarioJobs(id);
        return ResponseEntity.ok(ApiResponse.success(jobs, "Jobs retrieved"));
    }

    @GetMapping("/jobs/{jobId}")
    @Operation(summary = "Get job by ID")
    @PreAuthorize("hasAuthority('AI_SCENARIO_CREATE')")
    public ResponseEntity<ApiResponse<AIJob>> getJob(@PathVariable Long jobId) {
        AIJob job = scenarioService.getJob(jobId);
        return ResponseEntity.ok(ApiResponse.success(job, "Job retrieved"));
    }
}
