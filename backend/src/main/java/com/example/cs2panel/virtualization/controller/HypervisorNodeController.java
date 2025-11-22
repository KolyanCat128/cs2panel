package com.example.cs2panel.virtualization.controller;

import com.example.cs2panel.common.dto.ApiResponse;
import com.example.cs2panel.virtualization.dto.HypervisorNodeDTO;
import com.example.cs2panel.virtualization.entity.HypervisorNode;
import com.example.cs2panel.virtualization.service.HypervisorNodeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/nodes")
@RequiredArgsConstructor
@Tag(name = "Hypervisor Nodes", description = "Hypervisor node management operations")
public class HypervisorNodeController {

    private final HypervisorNodeService nodeService;

    @PostMapping
    @Operation(summary = "Add a new hypervisor node")
    @PreAuthorize("hasAuthority('NODE_CREATE')")
    public ResponseEntity<ApiResponse<HypervisorNode>> addNode(@RequestBody HypervisorNodeDTO nodeDTO) {
        HypervisorNode createdNode = nodeService.addNode(nodeDTO);
        return ResponseEntity.ok(ApiResponse.success(createdNode, "Hypervisor node added"));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get hypervisor node by ID")
    @PreAuthorize("hasAuthority('NODE_READ')")
    public ResponseEntity<ApiResponse<HypervisorNode>> getNode(@PathVariable Long id) {
        HypervisorNode node = nodeService.getNode(id);
        return ResponseEntity.ok(ApiResponse.success(node, "Node retrieved"));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete hypervisor node by ID")
    @PreAuthorize("hasAuthority('NODE_DELETE')")
    public ResponseEntity<ApiResponse<Void>> deleteNode(@PathVariable Long id) {
        nodeService.deleteNode(id);
        return ResponseEntity.ok(ApiResponse.success(null, "Node deleted"));
    }

    @GetMapping
    @Operation(summary = "Get all hypervisor nodes")
    @PreAuthorize("hasAuthority('NODE_READ')")
    public ResponseEntity<ApiResponse<List<HypervisorNode>>> getAllNodes() {
        List<HypervisorNode> nodes = nodeService.getAllNodes();
        return ResponseEntity.ok(ApiResponse.success(nodes, "Nodes retrieved"));
    }
}
