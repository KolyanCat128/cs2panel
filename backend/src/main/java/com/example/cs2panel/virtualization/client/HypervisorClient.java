package com.example.cs2panel.virtualization.client;

import com.example.cs2panel.virtualization.entity.HypervisorNode;
import com.example.cs2panel.virtualization.entity.VirtualMachine;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.Map;
import java.util.UUID;

@Component
@RequiredArgsConstructor
@Slf4j
public class HypervisorClient {

    private final WebClient.Builder webClientBuilder;

    @Value("${app.hypervisor.timeout:30000}")
    private long timeout;

    @CircuitBreaker(name = "hypervisor", fallbackMethod = "fallbackCreateVM")
    @Retry(name = "hypervisor")
    public void createVM(HypervisorNode node, VirtualMachine vm) {
        String url = buildNodeUrl(node) + "/v1/vms";

        Map<String, Object> request = Map.of(
                "uuid", vm.getUuid().toString(),
                "name", vm.getName(),
                "cpu_cores", vm.getCpuCores(),
                "memory_mb", vm.getMemoryMb(),
                "disk_gb", vm.getDiskGb(),
                "os_type", vm.getOsType() != null ? vm.getOsType() : "linux"
        );

        webClientBuilder.build()
                .post()
                .uri(url)
                .bodyValue(request)
                .retrieve()
                .bodyToMono(Map.class)
                .block();

        log.info("VM created on hypervisor: {}", vm.getUuid());
    }

    @CircuitBreaker(name = "hypervisor")
    @Retry(name = "hypervisor")
    public void startVM(HypervisorNode node, UUID vmUuid) {
        String url = buildNodeUrl(node) + "/v1/vms/" + vmUuid + "/start";

        webClientBuilder.build()
                .post()
                .uri(url)
                .retrieve()
                .bodyToMono(Map.class)
                .block();

        log.info("VM started on hypervisor: {}", vmUuid);
    }

    @CircuitBreaker(name = "hypervisor")
    @Retry(name = "hypervisor")
    public void stopVM(HypervisorNode node, UUID vmUuid) {
        String url = buildNodeUrl(node) + "/v1/vms/" + vmUuid + "/stop";

        webClientBuilder.build()
                .post()
                .uri(url)
                .retrieve()
                .bodyToMono(Map.class)
                .block();

        log.info("VM stopped on hypervisor: {}", vmUuid);
    }

    @CircuitBreaker(name = "hypervisor")
    @Retry(name = "hypervisor")
    public void rebootVM(HypervisorNode node, UUID vmUuid) {
        String url = buildNodeUrl(node) + "/v1/vms/" + vmUuid + "/reboot";

        webClientBuilder.build()
                .post()
                .uri(url)
                .retrieve()
                .bodyToMono(Map.class)
                .block();

        log.info("VM rebooted on hypervisor: {}", vmUuid);
    }

    @CircuitBreaker(name = "hypervisor")
    @Retry(name = "hypervisor")
    public void deleteVM(HypervisorNode node, UUID vmUuid) {
        String url = buildNodeUrl(node) + "/v1/vms/" + vmUuid;

        webClientBuilder.build()
                .delete()
                .uri(url)
                .retrieve()
                .bodyToMono(Void.class)
                .block();

        log.info("VM deleted on hypervisor: {}", vmUuid);
    }

    private String buildNodeUrl(HypervisorNode node) {
        return String.format("http://%s:%d", node.getIpAddress(), node.getPort());
    }

    private void fallbackCreateVM(HypervisorNode node, VirtualMachine vm, Exception e) {
        log.error("Fallback: Failed to create VM on hypervisor", e);
        throw new RuntimeException("Hypervisor unavailable", e);
    }
}
