package com.example.cs2panel.gameserver.entity;

import com.example.cs2panel.auth.entity.User;
import com.example.cs2panel.virtualization.entity.HypervisorNode;
import com.example.cs2panel.virtualization.entity.VirtualMachine;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "cs2_servers")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CS2Server {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 200)
    private String name;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id")
    private User owner;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "node_id")
    private HypervisorNode node;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vm_id")
    private VirtualMachine vm;

    @Column(length = 50)
    @Builder.Default
    private String status = "STOPPED"; // STOPPED, STARTING, RUNNING, STOPPING

    @Column(name = "ip_address", length = 45)
    private String ipAddress;

    @Builder.Default
    private Integer port = 27015;

    @Column(name = "rcon_password", length = 100)
    private String rconPassword;

    @Column(name = "server_password", length = 100)
    private String serverPassword;

    @Column(name = "max_players")
    @Builder.Default
    private Integer maxPlayers = 32;

    @Builder.Default
    private Integer tickrate = 128;

    @Column(length = 100)
    @Builder.Default
    private String map = "de_dust2";

    @Column(name = "game_mode", length = 50)
    private String gameMode;

    @Column(name = "steamcmd_path", length = 500)
    private String steamcmdPath;

    @Column(name = "install_path", length = 500)
    private String installPath;

    @Column(length = 50)
    private String version;

    @Column(name = "auto_update")
    @Builder.Default
    private Boolean autoUpdate = true;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
