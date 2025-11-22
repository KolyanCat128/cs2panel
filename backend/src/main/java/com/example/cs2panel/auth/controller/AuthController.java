package com.example.cs2panel.auth.controller;

import com.example.cs2panel.auth.dto.*;
import com.example.cs2panel.auth.service.AuthService;
import com.example.cs2panel.common.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Authentication and user management endpoints")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    @Operation(summary = "Register a new user")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest request) {
        AuthResponse response = authService.register(request);
        return ResponseEntity.ok(ApiResponse.success(response, "User registered successfully"));
    }

    @PostMapping("/login")
    @Operation(summary = "Login with username/email and password")
    public ResponseEntity<ApiResponse<AuthResponse>> login(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest httpRequest
    ) {
        String ipAddress = getClientIp(httpRequest);
        String userAgent = httpRequest.getHeader("User-Agent");
        AuthResponse response = authService.login(request, ipAddress, userAgent);
        return ResponseEntity.ok(ApiResponse.success(response, "Login successful"));
    }

    @PostMapping("/refresh")
    @Operation(summary = "Refresh access token using refresh token")
    public ResponseEntity<ApiResponse<AuthResponse>> refresh(@RequestBody RefreshTokenRequest request) {
        AuthResponse response = authService.refreshToken(request.getRefreshToken());
        return ResponseEntity.ok(ApiResponse.success(response, "Token refreshed"));
    }

    @PostMapping("/logout")
    @Operation(summary = "Logout and revoke refresh token")
    public ResponseEntity<ApiResponse<Void>> logout(@RequestBody RefreshTokenRequest request) {
        authService.logout(request.getRefreshToken());
        return ResponseEntity.ok(ApiResponse.success(null, "Logged out successfully"));
    }

    @GetMapping("/me")
    @Operation(summary = "Get current user information")
    public ResponseEntity<ApiResponse<UserDTO>> getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        // Implementation would fetch full user details
        return ResponseEntity.ok(ApiResponse.success(null, "Current user retrieved"));
    }

    @PostMapping("/2fa/setup")
    @Operation(summary = "Setup 2FA for current user")
    public ResponseEntity<ApiResponse<TotpSetupResponse>> setupTotp() {
        // Get current user ID from security context
        Long userId = 1L; // Placeholder
        TotpSetupResponse response = authService.setupTotp(userId);
        return ResponseEntity.ok(ApiResponse.success(response, "2FA setup initiated"));
    }

    @PostMapping("/2fa/enable")
    @Operation(summary = "Enable 2FA with verification code")
    public ResponseEntity<ApiResponse<Void>> enableTotp(@RequestBody TotpVerifyRequest request) {
        Long userId = 1L; // Get from security context
        authService.enableTotp(userId, request.getCode());
        return ResponseEntity.ok(ApiResponse.success(null, "2FA enabled"));
    }

    @PostMapping("/2fa/disable")
    @Operation(summary = "Disable 2FA")
    public ResponseEntity<ApiResponse<Void>> disableTotp(@RequestBody TotpVerifyRequest request) {
        Long userId = 1L; // Get from security context
        authService.disableTotp(userId, request.getCode());
        return ResponseEntity.ok(ApiResponse.success(null, "2FA disabled"));
    }

    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("X-Real-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        return ip;
    }
}
