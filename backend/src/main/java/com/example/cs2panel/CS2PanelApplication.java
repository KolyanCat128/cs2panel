package com.example.cs2panel;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * CS2 Infrastructure Panel - Main Application
 *
 * Multi-platform infrastructure management panel unifying:
 * - VMware vSphere/ESXi
 * - FortiGate Firewall
 * - SolusVM
 * - VMmanager
 * - ISPmanager
 * - BILLmanager
 * - Pterodactyl/Pelican Panel
 * - Platform9K (Kubernetes)
 * - Zabbix monitoring
 * - CS2 Game server deployment with SteamCMD
 * - AI-powered plugin constructor with DeepSeek
 * - Custom Hypervisor Daemon (Go-based KVM controller)
 * - Discord & Telegram bot automation
 */
@SpringBootApplication
@EnableCaching
@EnableAsync
@EnableScheduling
public class CS2PanelApplication {

    public static void main(String[] args) {
        SpringApplication.run(CS2PanelApplication.class, args);
    }
}
