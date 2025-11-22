package com.example.cs2panel.virtualization.service;

import com.example.cs2panel.virtualization.client.HypervisorClient;
import com.example.cs2panel.virtualization.entity.HypervisorNode;
import com.example.cs2panel.virtualization.entity.VirtualMachine;
import com.example.cs2panel.virtualization.repository.HypervisorNodeRepository;
import com.example.cs2panel.virtualization.repository.VirtualMachineRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class VirtualMachineService {

    private final VirtualMachineRepository vmRepository;
    private final HypervisorNodeRepository nodeRepository;
    private final HypervisorClient hypervisorClient;

    @Transactional
    public VirtualMachine createVM(VirtualMachine vm) {
        // Select node with available resources
        HypervisorNode node = selectAvailableNode(vm.getCpuCores(), vm.getMemoryMb(), vm.getDiskGb());
        vm.setNode(node);
        vm.setUuid(UUID.randomUUID());
        vm.setStatus("STOPPED");

        vm = vmRepository.save(vm);

        // Call hypervisor daemon to create VM
        try {
            hypervisorClient.createVM(node, vm);
            log.info("VM created: {} on node: {}", vm.getName(), node.getName());
        } catch (Exception e) {
            log.error("Failed to create VM on hypervisor", e);
            throw new RuntimeException("Failed to create VM", e);
        }

        return vm;
    }

    public VirtualMachine getVM(Long id) {
        return vmRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("VM not found"));
    }

    public List<VirtualMachine> getAllVMs() {
        return vmRepository.findAll();
    }

    public List<VirtualMachine> getUserVMs(Long userId) {
        return vmRepository.findByOwnerId(userId);
    }

    @Transactional
    public void startVM(Long id) {
        VirtualMachine vm = getVM(id);
        hypervisorClient.startVM(vm.getNode(), vm.getUuid());
        vm.setStatus("RUNNING");
        vmRepository.save(vm);
        log.info("VM started: {}", vm.getName());
    }

    @Transactional
    public void stopVM(Long id) {
        VirtualMachine vm = getVM(id);
        hypervisorClient.stopVM(vm.getNode(), vm.getUuid());
        vm.setStatus("STOPPED");
        vmRepository.save(vm);
        log.info("VM stopped: {}", vm.getName());
    }

    @Transactional
    public void rebootVM(Long id) {
        VirtualMachine vm = getVM(id);
        hypervisorClient.rebootVM(vm.getNode(), vm.getUuid());
        log.info("VM rebooted: {}", vm.getName());
    }

    @Transactional
    public void deleteVM(Long id) {
        VirtualMachine vm = getVM(id);
        hypervisorClient.deleteVM(vm.getNode(), vm.getUuid());
        vmRepository.delete(vm);
        log.info("VM deleted: {}", vm.getName());
    }

    public String getConsoleToken(Long id) {
        VirtualMachine vm = getVM(id);
        // Generate WebSocket token for console access
        return "console-token-" + vm.getUuid();
    }

    private HypervisorNode selectAvailableNode(int cpuCores, int memoryMb, int diskGb) {
        List<HypervisorNode> nodes = nodeRepository.findByEnabledTrueAndStatus("ONLINE");

        for (HypervisorNode node : nodes) {
            long availableCpu = node.getCpuCores() - node.getCpuUsed();
            long availableMemory = node.getMemoryTotalMb() - node.getMemoryUsedMb();
            long availableDisk = node.getDiskTotalGb() - node.getDiskUsedGb();

            if (availableCpu >= cpuCores && availableMemory >= memoryMb && availableDisk >= diskGb) {
                return node;
            }
        }

        throw new RuntimeException("No available node with sufficient resources");
    }
}
