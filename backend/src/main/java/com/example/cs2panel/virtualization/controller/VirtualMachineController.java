package com.example.cs2panel.virtualization.controller;

import com.example.cs2panel.common.dto.ApiResponse;
import com.example.cs2panel.virtualization.entity.VirtualMachine;
import com.example.cs2panel.virtualization.service.VirtualMachineService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/vms")
@RequiredArgsConstructor
@Tag(name = "Virtual Machines", description = "VM management operations")
public class VirtualMachineController {

    private final VirtualMachineService vmService;

    @PostMapping
    @Operation(summary = "Create a new VM")
    @PreAuthorize("hasAuthority('VM_CREATE')")
    public ResponseEntity<ApiResponse<VirtualMachine>> createVM(@RequestBody VirtualMachine vm) {
        VirtualMachine created = vmService.createVM(vm);
        return ResponseEntity.ok(ApiResponse.success(created, "VM created"));
    }

    @GetMapping
    @Operation(summary = "Get all VMs")
    @PreAuthorize("hasAuthority('VM_READ')")
    public ResponseEntity<ApiResponse<List<VirtualMachine>>> getAllVMs() {
        List<VirtualMachine> vms = vmService.getAllVMs();
        return ResponseEntity.ok(ApiResponse.success(vms, "VMs retrieved"));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get VM by ID")
    @PreAuthorize("hasAuthority('VM_READ')")
    public ResponseEntity<ApiResponse<VirtualMachine>> getVM(@PathVariable Long id) {
        VirtualMachine vm = vmService.getVM(id);
        return ResponseEntity.ok(ApiResponse.success(vm, "VM retrieved"));
    }

    @PostMapping("/{id}/start")
    @Operation(summary = "Start VM")
    @PreAuthorize("hasAuthority('VM_START')")
    public ResponseEntity<ApiResponse<Void>> startVM(@PathVariable Long id) {
        vmService.startVM(id);
        return ResponseEntity.ok(ApiResponse.success(null, "VM started"));
    }

    @PostMapping("/{id}/stop")
    @Operation(summary = "Stop VM")
    @PreAuthorize("hasAuthority('VM_STOP')")
    public ResponseEntity<ApiResponse<Void>> stopVM(@PathVariable Long id) {
        vmService.stopVM(id);
        return ResponseEntity.ok(ApiResponse.success(null, "VM stopped"));
    }

    @PostMapping("/{id}/reboot")
    @Operation(summary = "Reboot VM")
    @PreAuthorize("hasAuthority('VM_UPDATE')")
    public ResponseEntity<ApiResponse<Void>> rebootVM(@PathVariable Long id) {
        vmService.rebootVM(id);
        return ResponseEntity.ok(ApiResponse.success(null, "VM rebooted"));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete VM")
    @PreAuthorize("hasAuthority('VM_DELETE')")
    public ResponseEntity<ApiResponse<Void>> deleteVM(@PathVariable Long id) {
        vmService.deleteVM(id);
        return ResponseEntity.ok(ApiResponse.success(null, "VM deleted"));
    }

    @GetMapping("/{id}/console")
    @Operation(summary = "Get console access token")
    @PreAuthorize("hasAuthority('VM_READ')")
    public ResponseEntity<ApiResponse<String>> getConsoleToken(@PathVariable Long id) {
        String token = vmService.getConsoleToken(id);
        return ResponseEntity.ok(ApiResponse.success(token, "Console token generated"));
    }
}
