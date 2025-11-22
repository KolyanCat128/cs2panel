package com.example.cs2panel.monitoring.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class MonitoringService {

    public Map<String, Object> getSystemMetrics() {
        Map<String, Object> metrics = new HashMap<>();
        metrics.put("timestamp", System.currentTimeMillis());
        metrics.put("cpu_usage", 45.2);
        metrics.put("memory_usage", 62.8);
        metrics.put("disk_usage", 73.1);
        return metrics;
    }

    public void recordMetric(String resourceType, Long resourceId, String metricName, Double value) {
        log.info("Recording metric: {}={} for {}:{}", metricName, value, resourceType, resourceId);
        // Store to database or send to Prometheus
    }
}
