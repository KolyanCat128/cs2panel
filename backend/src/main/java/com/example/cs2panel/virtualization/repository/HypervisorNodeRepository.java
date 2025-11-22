package com.example.cs2panel.virtualization.repository;

import com.example.cs2panel.virtualization.entity.HypervisorNode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface HypervisorNodeRepository extends JpaRepository<HypervisorNode, Long> {
    Optional<HypervisorNode> findByHostname(String hostname);
    List<HypervisorNode> findByEnabledTrueAndStatus(String status);
    List<HypervisorNode> findByStatus(String status);
}
