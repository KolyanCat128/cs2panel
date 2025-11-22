package com.example.cs2panel.virtualization.dto;

import lombok.Data;

@Data
public class HypervisorNodeDTO {
    private String name;
    private String ipAddress;
    private int port;
}
