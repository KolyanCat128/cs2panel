package com.example.cs2panel.ai.repository;

import com.example.cs2panel.ai.entity.AIScenario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AIScenarioRepository extends JpaRepository<AIScenario, Long> {
    List<AIScenario> findByCreatedById(Long createdById);
    List<AIScenario> findByStatus(String status);
}
