package com.example.cs2panel.ai.repository;

import com.example.cs2panel.ai.entity.AIJob;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AIJobRepository extends JpaRepository<AIJob, Long> {
    List<AIJob> findByScenarioIdOrderByCreatedAtDesc(Long scenarioId);
    List<AIJob> findByStatus(String status);
}
