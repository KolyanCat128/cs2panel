package com.example.cs2panel.firewall.entity;

import com.example.cs2panel.virtualization.entity.HypervisorNode;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "firewall_rules")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FirewallRule {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "node_id")
    private HypervisorNode node;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(nullable = false, length = 20)
    private String action; // ACCEPT, DROP, REJECT

    @Column(length = 20)
    private String protocol; // TCP, UDP, ICMP, ALL

    @Column(name = "source_ip", length = 50)
    private String sourceIp;

    @Column(name = "source_port", length = 50)
    private String sourcePort;

    @Column(name = "destination_ip", length = 50)
    private String destinationIp;

    @Column(name = "destination_port", length = 50)
    private String destinationPort;

    @Column(length = 20)
    private String direction; // INBOUND, OUTBOUND

    @Column(length = 50)
    private String zone;

    @Builder.Default
    private Integer priority = 100;

    @Builder.Default
    private Boolean enabled = true;

    @Column(columnDefinition = "TEXT")
    private String description;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
