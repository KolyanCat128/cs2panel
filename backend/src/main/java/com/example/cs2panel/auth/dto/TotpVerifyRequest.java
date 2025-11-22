package com.example.cs2panel.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
public class TotpVerifyRequest {
    @NotBlank(message = "2FA code is required")
    @Pattern(regexp = "\\d{6}", message = "2FA code must be 6 digits")
    private String code;
}
