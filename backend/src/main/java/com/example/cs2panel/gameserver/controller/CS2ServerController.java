package com.example.cs2panel.gameserver.controller;

import com.example.cs2panel.common.dto.ApiResponse;
import com.example.cs2panel.gameserver.entity.CS2Server;
import com.example.cs2panel.gameserver.service.CS2ServerService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/cs2-servers")
@RequiredArgsConstructor
@Tag(name = "CS2 Servers", description = "Counter-Strike 2 game server management")
public class CS2ServerController {

    private final CS2ServerService serverService;

    @PostMapping
    @Operation(summary = "Create a new CS2 server")
    @PreAuthorize("hasAuthority('CS2_CREATE')")
    public ResponseEntity<ApiResponse<CS2Server>> createServer(@RequestBody CS2Server server) {
        CS2Server created = serverService.createServer(server);
        return ResponseEntity.ok(ApiResponse.success(created, "CS2 server created"));
    }

    @GetMapping
    @Operation(summary = "Get all CS2 servers")
    @PreAuthorize("hasAuthority('CS2_READ')")
    public ResponseEntity<ApiResponse<List<CS2Server>>> getAllServers() {
        List<CS2Server> servers = serverService.getAllServers();
        return ResponseEntity.ok(ApiResponse.success(servers, "Servers retrieved"));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get CS2 server by ID")
    @PreAuthorize("hasAuthority('CS2_READ')")
    public ResponseEntity<ApiResponse<CS2Server>> getServer(@PathVariable Long id) {
        CS2Server server = serverService.getServer(id);
        return ResponseEntity.ok(ApiResponse.success(server, "Server retrieved"));
    }

    @PostMapping("/{id}/start")
    @Operation(summary = "Start CS2 server")
    @PreAuthorize("hasAuthority('CS2_UPDATE')")
    public ResponseEntity<ApiResponse<Void>> startServer(@PathVariable Long id) {
        serverService.startServer(id);
        return ResponseEntity.ok(ApiResponse.success(null, "Server started"));
    }

    @PostMapping("/{id}/stop")
    @Operation(summary = "Stop CS2 server")
    @PreAuthorize("hasAuthority('CS2_UPDATE')")
    public ResponseEntity<ApiResponse<Void>> stopServer(@PathVariable Long id) {
        serverService.stopServer(id);
        return ResponseEntity.ok(ApiResponse.success(null, "Server stopped"));
    }

    @PostMapping("/{id}/update")
    @Operation(summary = "Update CS2 server via SteamCMD")
    @PreAuthorize("hasAuthority('CS2_UPDATE')")
    public ResponseEntity<ApiResponse<Void>> updateServer(@PathVariable Long id) {
        serverService.updateServer(id);
        return ResponseEntity.ok(ApiResponse.success(null, "Server update initiated"));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete CS2 server")
    @PreAuthorize("hasAuthority('CS2_DELETE')")
    public ResponseEntity<ApiResponse<Void>> deleteServer(@PathVariable Long id) {
        serverService.deleteServer(id);
        return ResponseEntity.ok(ApiResponse.success(null, "Server deleted"));
    }
}
