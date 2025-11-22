# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to: security@cs2panel.example.com

You should receive a response within 48 hours. If for some reason you do not, please follow up via email to ensure we received your original message.

Please include the following information:

- Type of issue (e.g., SQL injection, XSS, RCE, etc.)
- Full paths of source file(s) related to the manifestation of the issue
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

## Security Measures

CS2Panel implements multiple security layers:

### Authentication & Authorization
- JWT-based authentication with refresh tokens
- TOTP 2FA support
- Role-Based Access Control (RBAC) with granular permissions
- Account lockout after failed login attempts
- IP-based access logging

### Input Validation
- All user inputs are validated and sanitized
- SQL injection protection via JPA/Hibernate
- XSS protection through Spring Security
- CSRF protection enabled

### API Security
- Rate limiting on all endpoints
- CORS configuration
- API authentication required for all non-public endpoints
- Secure password hashing (BCrypt with cost factor 12)

### Infrastructure Security
- Database credentials stored in Kubernetes secrets
- JWT secrets rotated regularly
- Encrypted communication between services
- Regular security scanning via Trivy and CodeQL

### Audit Logging
- All administrative actions logged
- Authentication attempts tracked
- Dangerous operations require explicit confirmation

## Best Practices

When deploying CS2Panel in production:

1. **Change all default passwords** immediately
2. **Use strong JWT secrets** (256+ bits of entropy)
3. **Enable HTTPS/TLS** for all external connections
4. **Configure firewall rules** to restrict access
5. **Keep dependencies updated** regularly
6. **Monitor logs** for suspicious activity
7. **Backup databases** regularly
8. **Use Kubernetes secrets** for sensitive data
9. **Enable 2FA** for all admin accounts
10. **Review RBAC permissions** periodically

## Responsible Disclosure

We follow responsible disclosure practices. Security researchers who report vulnerabilities will be acknowledged (with permission) in our security advisories.

We request that you:

- Give us reasonable time to address the issue before public disclosure
- Make a good faith effort to avoid privacy violations, data destruction, and service interruption
- Do not exploit the vulnerability beyond what is necessary to demonstrate it

## Security Updates

Security updates will be released as patch versions (e.g., 1.0.1) and announced via:

- GitHub Security Advisories
- Release notes
- Security mailing list (security-announce@cs2panel.example.com)

## Contact

Security Team: security@cs2panel.example.com
PGP Key: [Available on request]
