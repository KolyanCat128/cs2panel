package com.example.cs2panel.virtualization.entity;

import com.example.cs2panel.auth.entity.User;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "virtual_machines")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VirtualMachine {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    @Builder.Default
    private UUID uuid = UUID.randomUUID();

    @Column(nullable = false, length = 200)
    private String name;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "node_id")
    private HypervisorNode node;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id")
    private User owner;

    @Column(length = 50)
    @Builder.Default
    private String status = "STOPPED"; // STOPPED, RUNNING, PAUSED, SUSPENDED

    @Column(name = "cpu_cores", nullable = false)
    private Integer cpuCores;

    @Column(name = "memory_mb", nullable = false)
    private Integer memoryMb;

    @Column(name = "disk_gb", nullable = false)
    private Integer diskGb;

    @Column(name = "os_type", length = 50)
    private String osType;

    @Column(name = "os_version", length = 100)
    private String osVersion;

    @Column(name = "ip_address", length = 45)
    private String ipAddress;

    @Column(name = "vnc_port")
    private Integer vncPort;

    @Column(name = "vnc_password", length = 100)
    private String vncPassword;

    @Column(name = "cloud_init_enabled")
    @Builder.Default
    private Boolean cloudInitEnabled = false;

    @Column(name = "cloud_init_data", columnDefinition = "TEXT")
    private String cloudInitData;

    @Column(name = "auto_start")
    @Builder.Default
    private Boolean autoStart = false;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;
}
