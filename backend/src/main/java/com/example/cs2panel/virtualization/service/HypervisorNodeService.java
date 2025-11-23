package com.example.cs2panel.virtualization.service;

import com.example.cs2panel.virtualization.client.HypervisorClient;
import com.example.cs2panel.virtualization.dto.HypervisorNodeDTO;
import com.example.cs2panel.virtualization.entity.HypervisorNode;
import com.example.cs2panel.virtualization.repository.HypervisorNodeRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class HypervisorNodeService {

    private final HypervisorNodeRepository nodeRepository;
    private final HypervisorClient hypervisorClient;

    @Transactional
    public HypervisorNode addNode(HypervisorNodeDTO nodeDTO) {
        HypervisorNode node = new HypervisorNode();
        node.setName(nodeDTO.getName());
        node.setIpAddress(nodeDTO.getIpAddress());
        node.setPort(nodeDTO.getPort());
        node.setEnabled(true);
        node.setStatus("UNKNOWN");
        // Persist the node first
        node = nodeRepository.save(node);
        log.info("Added new hypervisor node: {}", node.getName());
        // Immediately try to update its status
        updateNodeStatus(node);
        return node;
    }

    public HypervisorNode getNode(Long id) {
        return nodeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Node not found"));
    }

    public void deleteNode(Long id) {
        nodeRepository.deleteById(id);
    }

    public List<HypervisorNode> getAllNodes() {
        return nodeRepository.findAll();
    }

    @Scheduled(fixedRate = 60000) // Update every 60 seconds
    @Transactional
    public void updateAllNodeStatuses() {
        log.info("Starting scheduled update of all hypervisor node statuses.");
        List<HypervisorNode> nodes = nodeRepository.findAll();
        for (HypervisorNode node : nodes) {
            updateNodeStatus(node);
        }
        log.info("Finished scheduled update of all hypervisor node statuses.");
    }

    private void updateNodeStatus(HypervisorNode node) {
        try {
            Map<String, Object> metrics = hypervisorClient.getMetrics(node);
            node.setStatus("ONLINE");
            // Assuming the metrics map contains these keys.
            // This needs to match the response from the hypervisor's /v1/metrics endpoint
            if (metrics.containsKey("cpu_cores_total")) {
                node.setCpuCores(((Number) metrics.get("cpu_cores_total")).intValue());
            }
            if (metrics.containsKey("cpu_cores_used")) {
                node.setCpuUsed(((Number) metrics.get("cpu_cores_used")).intValue());
            }
            if (metrics.containsKey("memory_total_mb")) {
                node.setMemoryTotalMb(((Number) metrics.get("memory_total_mb")).longValue());
            }
            if (metrics.containsKey("memory_used_mb")) {
                node.setMemoryUsedMb(((Number) metrics.get("memory_used_mb")).longValue());
            }
            if (metrics.containsKey("disk_total_gb")) {
                node.setDiskTotalGb(((Number) metrics.get("disk_total_gb")).longValue());
            }
            if (metrics.containsKey("disk_used_gb")) {
                node.setDiskUsedGb(((Number) metrics.get("disk_used_gb")).longValue());
            }
            nodeRepository.save(node);
            log.info("Successfully updated status for node: {}", node.getName());
        } catch (Exception e) {
            node.setStatus("OFFLINE");
            nodeRepository.save(node);
            log.error("Failed to update status for node: {}. Marking as OFFLINE.", node.getName(), e);
        }
    }
}
