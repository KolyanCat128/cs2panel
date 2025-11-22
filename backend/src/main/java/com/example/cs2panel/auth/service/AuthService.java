package com.example.cs2panel.auth.service;

import com.example.cs2panel.auth.dto.*;
import com.example.cs2panel.auth.entity.RefreshToken;
import com.example.cs2panel.auth.entity.Role;
import com.example.cs2panel.auth.entity.User;
import com.example.cs2panel.auth.repository.RefreshTokenRepository;
import com.example.cs2panel.auth.repository.RoleRepository;
import com.example.cs2panel.auth.repository.UserRepository;
import com.example.cs2panel.common.exception.BadRequestException;
import com.example.cs2panel.common.exception.UnauthorizedException;
import com.example.cs2panel.security.JwtService;
import com.warrenstrange.googleauth.GoogleAuthenticator;
import com.warrenstrange.googleauth.GoogleAuthenticatorKey;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final UserDetailsService userDetailsService;
    private final GoogleAuthenticator googleAuthenticator;

    @Value("${app.jwt.refresh-token-expiration}")
    private long refreshTokenExpiration;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new BadRequestException("Username already exists");
        }

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email already exists");
        }

        Role userRole = roleRepository.findByName(Role.RoleName.ROLE_USER)
                .orElseThrow(() -> new RuntimeException("Default role not found"));

        User user = User.builder()
                .username(request.getUsername())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .phone(request.getPhone())
                .enabled(true)
                .emailVerified(false)
                .twoFaEnabled(false)
                .accountLocked(false)
                .failedLoginAttempts(0)
                .roles(Set.of(userRole))
                .build();

        user = userRepository.save(user);
        log.info("New user registered: {}", user.getUsername());

        UserDetails userDetails = userDetailsService.loadUserByUsername(user.getUsername());
        String accessToken = jwtService.generateAccessToken(userDetails);
        String refreshToken = createRefreshToken(user, null, null);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(900000L) // 15 minutes
                .user(convertToDTO(user))
                .build();
    }

    @Transactional
    public AuthResponse login(LoginRequest request, String ipAddress, String userAgent) {
        User user = userRepository.findByUsernameOrEmail(request.getUsernameOrEmail())
                .orElseThrow(() -> new UnauthorizedException("Invalid credentials"));

        if (user.getAccountLocked()) {
            throw new UnauthorizedException("Account is locked. Contact support.");
        }

        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getUsernameOrEmail(),
                            request.getPassword()
                    )
            );

            if (user.getTwoFaEnabled()) {
                if (request.getTotpCode() == null) {
                    throw new UnauthorizedException("2FA code required");
                }

                if (!verifyTotpCode(user, request.getTotpCode())) {
                    throw new UnauthorizedException("Invalid 2FA code");
                }
            }

            user.resetFailedLoginAttempts();
            user.setLastLoginAt(LocalDateTime.now());
            user.setLastLoginIp(ipAddress);
            userRepository.save(user);

            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            String accessToken = jwtService.generateAccessToken(userDetails);
            String refreshToken = createRefreshToken(user, ipAddress, userAgent);

            log.info("User logged in successfully: {}", user.getUsername());

            return AuthResponse.builder()
                    .accessToken(accessToken)
                    .refreshToken(refreshToken)
                    .tokenType("Bearer")
                    .expiresIn(900000L)
                    .user(convertToDTO(user))
                    .build();

        } catch (Exception e) {
            user.incrementFailedLoginAttempts();
            userRepository.save(user);
            throw new UnauthorizedException("Invalid credentials");
        }
    }

    @Transactional
    public AuthResponse refreshToken(String refreshToken) {
        RefreshToken token = refreshTokenRepository.findByToken(refreshToken)
                .orElseThrow(() -> new UnauthorizedException("Invalid refresh token"));

        if (token.getRevoked() || token.isExpired()) {
            throw new UnauthorizedException("Refresh token expired or revoked");
        }

        User user = token.getUser();
        UserDetails userDetails = userDetailsService.loadUserByUsername(user.getUsername());
        String newAccessToken = jwtService.generateAccessToken(userDetails);

        return AuthResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(900000L)
                .user(convertToDTO(user))
                .build();
    }

    @Transactional
    public void logout(String refreshToken) {
        refreshTokenRepository.findByToken(refreshToken).ifPresent(token -> {
            token.setRevoked(true);
            refreshTokenRepository.save(token);
        });
    }

    public TotpSetupResponse setupTotp(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BadRequestException("User not found"));

        GoogleAuthenticatorKey key = googleAuthenticator.createCredentials();
        user.setTwoFaSecret(key.getKey());
        userRepository.save(user);

        String qrCodeUrl = String.format(
                "otpauth://totp/CS2Panel:%s?secret=%s&issuer=CS2Panel",
                user.getUsername(),
                key.getKey()
        );

        return TotpSetupResponse.builder()
                .secret(key.getKey())
                .qrCodeUrl(qrCodeUrl)
                .build();
    }

    @Transactional
    public void enableTotp(Long userId, String totpCode) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BadRequestException("User not found"));

        if (user.getTwoFaSecret() == null) {
            throw new BadRequestException("2FA not set up");
        }

        if (!verifyTotpCode(user, totpCode)) {
            throw new BadRequestException("Invalid 2FA code");
        }

        user.setTwoFaEnabled(true);
        userRepository.save(user);
        log.info("2FA enabled for user: {}", user.getUsername());
    }

    @Transactional
    public void disableTotp(Long userId, String totpCode) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BadRequestException("User not found"));

        if (!verifyTotpCode(user, totpCode)) {
            throw new BadRequestException("Invalid 2FA code");
        }

        user.setTwoFaEnabled(false);
        user.setTwoFaSecret(null);
        userRepository.save(user);
        log.info("2FA disabled for user: {}", user.getUsername());
    }

    private boolean verifyTotpCode(User user, String code) {
        if (user.getTwoFaSecret() == null) {
            return false;
        }
        try {
            int codeInt = Integer.parseInt(code);
            return googleAuthenticator.authorize(user.getTwoFaSecret(), codeInt);
        } catch (NumberFormatException e) {
            return false;
        }
    }

    private String createRefreshToken(User user, String ipAddress, String userAgent) {
        String tokenString = jwtService.generateRefreshToken(
                userDetailsService.loadUserByUsername(user.getUsername())
        );

        RefreshToken refreshToken = RefreshToken.builder()
                .token(tokenString)
                .user(user)
                .expiresAt(LocalDateTime.now().plusSeconds(refreshTokenExpiration / 1000))
                .createdAt(LocalDateTime.now())
                .revoked(false)
                .ipAddress(ipAddress)
                .userAgent(userAgent)
                .build();

        refreshTokenRepository.save(refreshToken);
        return tokenString;
    }

    private UserDTO convertToDTO(User user) {
        return UserDTO.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .phone(user.getPhone())
                .avatarUrl(user.getAvatarUrl())
                .twoFaEnabled(user.getTwoFaEnabled())
                .enabled(user.getEnabled())
                .emailVerified(user.getEmailVerified())
                .roles(user.getRoles().stream()
                        .map(role -> role.getName())
                        .collect(Collectors.toSet()))
                .organizationId(user.getOrganization() != null ? user.getOrganization().getId() : null)
                .organizationName(user.getOrganization() != null ? user.getOrganization().getName() : null)
                .createdAt(user.getCreatedAt())
                .lastLoginAt(user.getLastLoginAt())
                .build();
    }
}
