package com.example.cs2panel.virtualization.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.Map;

@Entity
@Table(name = "hypervisor_nodes")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HypervisorNode {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(unique = true, nullable = false, length = 255)
    private String hostname;

    @Column(name = "ip_address", nullable = false, length = 45)
    private String ipAddress;

    @Builder.Default
    private Integer port = 8080;

    @Column(length = 50)
    @Builder.Default
    private String status = "OFFLINE"; // ONLINE, OFFLINE, MAINTENANCE

    @Column(name = "cpu_cores")
    private Integer cpuCores;

    @Column(name = "cpu_used")
    @Builder.Default
    private Integer cpuUsed = 0;

    @Column(name = "memory_total_mb")
    private Long memoryTotalMb;

    @Column(name = "memory_used_mb")
    @Builder.Default
    private Long memoryUsedMb = 0L;

    @Column(name = "disk_total_gb")
    private Long diskTotalGb;

    @Column(name = "disk_used_gb")
    @Builder.Default
    private Long diskUsedGb = 0L;

    @Column(length = 100)
    private String location;

    @Column(length = 100)
    private String datacenter;

    @Builder.Default
    private Boolean enabled = true;

    @Column(name = "last_heartbeat")
    private LocalDateTime lastHeartbeat;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private Map<String, Object> metadata;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
