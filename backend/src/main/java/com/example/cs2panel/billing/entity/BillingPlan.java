package com.example.cs2panel.billing.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;

@Entity
@Table(name = "billing_plans")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BillingPlan {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "plan_type", length = 50)
    private String planType; // VM, CS2_SERVER, STORAGE, etc.

    @Column(name = "billing_cycle", length = 50)
    private String billingCycle; // MONTHLY, QUARTERLY, YEARLY

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal price;

    @Column(length = 3)
    @Builder.Default
    private String currency = "USD";

    @Column(name = "cpu_cores")
    private Integer cpuCores;

    @Column(name = "memory_mb")
    private Integer memoryMb;

    @Column(name = "disk_gb")
    private Integer diskGb;

    @Column(name = "bandwidth_gb")
    private Integer bandwidthGb;

    @Column(name = "game_slots")
    private Integer gameSlots;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private Map<String, Object> features;

    @Builder.Default
    private Boolean active = true;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
