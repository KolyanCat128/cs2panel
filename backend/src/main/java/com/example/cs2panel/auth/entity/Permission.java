package com.example.cs2panel.auth.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "permissions")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Permission {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false, length = 100)
    private String name;

    @Column(length = 255)
    private String description;

    @Column(length = 50)
    private String category;

    // Permission examples:
    // VM_CREATE, VM_DELETE, VM_START, VM_STOP
    // FIREWALL_CREATE, FIREWALL_EDIT, FIREWALL_DELETE
    // BILLING_VIEW, BILLING_CREATE, BILLING_REFUND
    // USER_CREATE, USER_EDIT, USER_DELETE
    // CS2_SERVER_CREATE, CS2_SERVER_EDIT, CS2_SERVER_DELETE
    // AI_SCENARIO_CREATE, AI_SCENARIO_EXECUTE
}
