# CS2 Infrastructure Panel

A comprehensive, production-grade multi-platform infrastructure management panel built with **Java 17 Spring Boot** and **Go**, unifying the functionality of major enterprise infrastructure tools.

## 🎯 Features

### Core Infrastructure Management
- **VMware vSphere/ESXi** - Full VM lifecycle management
- **SolusVM / VMmanager** - Virtual machine provisioning and control
- **Custom Hypervisor Daemon** - Go-based KVM/QEMU controller

### Networking & Security
- **FortiGate-style Firewall** - Rule engine with NAT, zones, and VPN templates
- **Network Pools** - VLAN, subnet, and gateway management
- **VPN Management** - OpenVPN and WireGuard templates

### Game Server Management
- **CS2 Server Deployment** - Automated SteamCMD installation and management
- **Plugin System** - Upload, enable, and manage server plugins
- **AI-Powered Plugin Constructor** - DeepSeek v3 integration for code generation
- **Pterodactyl/Pelican Panel** - Game server control interface

### Billing & Subscriptions
- **BILLmanager / ISPmanager** - Complete billing system
- **Plans & Tariffs** - CPU, RAM, disk, bandwidth metering
- **Invoice Generation** - PDF invoices with automated delivery
- **Payment Integration** - Stripe and PayPal support

### Orchestration & Monitoring
- **Kubernetes Operator** - Custom CS2Server CRD with reconciliation
- **Platform9K-style Management** - Multi-cluster Kubernetes control
- **Zabbix-like Monitoring** - Metrics collection and alerting
- **Prometheus Integration** - Full observability stack

### Automation
- **Discord Bot** - Server management via Discord commands
- **Telegram Bot** - Notifications and control interface
- **ISO Generator** - Bare-metal hypervisor OS builder

## 🏗️ Architecture

```
cs2panel/
├── backend/                 # Spring Boot monolith
│   ├── auth/               # JWT, 2FA, RBAC
│   ├── billing/            # Plans, invoices, payments
│   ├── virtualization/     # VM management
│   ├── gameserver/         # CS2 server management
│   ├── ai/                 # DeepSeek integration
│   ├── firewall/           # Firewall rules
│   ├── monitoring/         # Metrics and alerts
│   ├── k8s/                # Kubernetes operator
│   └── bots/               # Discord/Telegram bots
├── hypervisor/             # Go daemon for VM control
├── k8s/                    # Kubernetes manifests & CRDs
├── charts/                 # Helm charts
├── scripts/                # Deployment and ISO builder
└── docker-compose.yml      # Local development
```

## 🚀 Quick Start

### Prerequisites

- **Java 17+**
- **Maven 3.8+** or **Gradle 8+**
- **Go 1.21+**
- **Docker & Docker Compose**
- **PostgreSQL 15+**
- **Redis 7+**
- **RabbitMQ 3.12+**

### Local Development Setup

1. **Clone the repository**
```bash
git clone https://github.com/your-org/cs2panel.git
cd cs2panel
```

2. **Configure environment**
```bash
cp .env.example .env
# Edit .env and add your API keys
```

3. **Build hypervisor daemon**
```bash
cd hypervisor
go build -o bin/hypervisor-daemon .
cd ..
```

4. **Start infrastructure services**
```bash
docker-compose up -d
```

5. **Build and run backend**
```bash
cd backend
./mvnw spring-boot:run
# Or with Gradle:
./gradlew bootRun
```

6. **Access the application**
- Backend API: http://localhost:8080
- Swagger UI: http://localhost:8080/swagger-ui.html
- Hypervisor API: http://localhost:8081
- Prometheus: http://localhost:9090
- RabbitMQ Management: http://localhost:15672

## 📦 Production Deployment

### Kubernetes Deployment

1. **Install CRDs**
```bash
kubectl apply -f k8s/crd-cs2server.yaml
```

2. **Create secrets**
```bash
kubectl create secret generic cs2panel-secrets \
  --from-literal=jwt-secret='your-jwt-secret' \
  --from-literal=db-password='your-db-password' \
  --from-literal=deepseek-api-key='your-api-key' \
  --namespace=cs2panel
```

3. **Deploy with Helm**
```bash
helm install cs2panel ./charts/cs2panel \
  --namespace cs2panel \
  --create-namespace \
  --values charts/cs2panel/values.yaml
```

4. **Verify deployment**
```bash
kubectl get pods -n cs2panel
kubectl logs -n cs2panel -l component=backend -f
```

### Using the deployment script

```bash
./scripts/deploy.sh
```

## 📖 API Documentation

### Authentication

**Register a new user:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "email": "admin@example.com",
    "password": "SecurePass123!",
    "firstName": "John",
    "lastName": "Doe"
  }'
```

**Login:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "usernameOrEmail": "admin",
    "password": "SecurePass123!"
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "tokenType": "Bearer",
    "expiresIn": 900000,
    "user": {
      "id": 1,
      "username": "admin",
      "email": "admin@example.com",
      "roles": ["ROLE_ADMIN"]
    }
  }
}
```

### Virtual Machine Management

**Create a VM:**
```bash
TOKEN="your-jwt-token"

curl -X POST http://localhost:8080/api/v1/vms \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "web-server-01",
    "cpuCores": 4,
    "memoryMb": 8192,
    "diskGb": 100,
    "osType": "ubuntu",
    "osVersion": "22.04"
  }'
```

**Start a VM:**
```bash
curl -X POST http://localhost:8080/api/v1/vms/1/start \
  -H "Authorization: Bearer $TOKEN"
```

**Stop a VM:**
```bash
curl -X POST http://localhost:8080/api/v1/vms/1/stop \
  -H "Authorization: Bearer $TOKEN"
```

**Get console access:**
```bash
curl -X GET http://localhost:8080/api/v1/vms/1/console \
  -H "Authorization: Bearer $TOKEN"
```

### CS2 Server Management

**Create a CS2 server:**
```bash
curl -X POST http://localhost:8080/api/v1/cs2-servers \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Competitive Server #1",
    "maxPlayers": 10,
    "tickrate": 128,
    "map": "de_dust2",
    "gameMode": "competitive"
  }'
```

**Start server:**
```bash
curl -X POST http://localhost:8080/api/v1/cs2-servers/1/start \
  -H "Authorization: Bearer $TOKEN"
```

**Update server (via SteamCMD):**
```bash
curl -X POST http://localhost:8080/api/v1/cs2-servers/1/update \
  -H "Authorization: Bearer $TOKEN"
```

### AI Plugin Generation

**Create a scenario:**
```bash
curl -X POST http://localhost:8080/api/v1/ai/scenarios \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Practice Mode Plugin",
    "description": "A plugin for practice mode with bot spawning",
    "scenarioData": {
      "plugin_name": "PracticeMode",
      "description": "Advanced practice mode for CS2",
      "features": [
        "Bot spawning with difficulty levels",
        "Practice grenade trajectories",
        "Save and load positions",
        "Timer and statistics tracking"
      ]
    }
  }'
```

**Execute scenario (generate code):**
```bash
curl -X POST http://localhost:8080/api/v1/ai/scenarios/1/execute \
  -H "Authorization: Bearer $TOKEN"
```

**Get job status:**
```bash
curl -X GET http://localhost:8080/api/v1/ai/scenarios/jobs/1 \
  -H "Authorization: Bearer $TOKEN"
```

### Billing

**Get all plans:**
```bash
curl -X GET http://localhost:8080/api/v1/billing/plans \
  -H "Authorization: Bearer $TOKEN"
```

**Get user invoices:**
```bash
curl -X GET http://localhost:8080/api/v1/billing/invoices \
  -H "Authorization: Bearer $TOKEN"
```

**Download invoice PDF:**
```bash
curl -X GET http://localhost:8080/api/v1/billing/invoices/1/pdf \
  -H "Authorization: Bearer $TOKEN" \
  --output invoice-1.pdf
```

### Kubernetes CS2 Servers

**Create a CS2Server resource:**
```bash
kubectl apply -f - <<EOF
apiVersion: cs2panel.example.com/v1
kind: CS2Server
metadata:
  name: competitive-server-01
  namespace: cs2panel
spec:
  serverName: "CS2Panel Competitive #1"
  replicas: 2
  maxPlayers: 10
  tickrate: 128
  map: "de_dust2"
  gameMode: "competitive"
  resources:
    cpu: "2000m"
    memory: "4Gi"
  plugins:
    - "practicemode"
    - "retakes"
EOF
```

**List CS2 servers:**
```bash
kubectl get cs2servers -n cs2panel
```

## 🔧 Configuration

### Environment Variables

```bash
# Database
POSTGRES_DB=cs2panel
POSTGRES_USER=cs2panel
POSTGRES_PASSWORD=your-password

# JWT
JWT_SECRET=your-very-long-secret-key-256-bits-minimum

# DeepSeek AI
DEEPSEEK_API_KEY=your-deepseek-api-key

# Discord Bot
DISCORD_BOT_TOKEN=your-discord-token
DISCORD_ENABLED=true

# Telegram Bot
TELEGRAM_BOT_TOKEN=your-telegram-token
TELEGRAM_ENABLED=true

# Hypervisor
HYPERVISOR_BASE_URL=http://hypervisor:8080

# Kubernetes
K8S_ENABLED=true
KUBECONFIG_PATH=/root/.kube/config
```

### Application Configuration

Edit `backend/src/main/resources/application.yml`:

```yaml
app:
  jwt:
    secret: ${JWT_SECRET}
    access-token-expiration: 900000    # 15 minutes
    refresh-token-expiration: 604800000 # 7 days

  deepseek:
    api-key: ${DEEPSEEK_API_KEY}
    model: deepseek-coder-v3
    max-tokens: 8000

  cs2:
    steamcmd-path: /opt/steamcmd
    servers-base-path: /opt/cs2-servers
    default-tickrate: 128
```

## 🛡️ Security

### RBAC Roles

- **ROLE_ADMIN** - Full system access
- **ROLE_OPERATOR** - Infrastructure operations
- **ROLE_BILLING** - Billing and financial operations
- **ROLE_SUPPORT** - Support tickets and user assistance
- **ROLE_USER** - Regular user

### Permissions

VM Operations:
- `VM_CREATE`, `VM_READ`, `VM_UPDATE`, `VM_DELETE`
- `VM_START`, `VM_STOP`

Firewall:
- `FIREWALL_CREATE`, `FIREWALL_READ`, `FIREWALL_UPDATE`, `FIREWALL_DELETE`

Billing:
- `BILLING_READ`, `BILLING_CREATE`, `BILLING_REFUND`

CS2 Servers:
- `CS2_CREATE`, `CS2_READ`, `CS2_UPDATE`, `CS2_DELETE`

AI Scenarios:
- `AI_SCENARIO_CREATE`, `AI_SCENARIO_EXECUTE`

### Two-Factor Authentication

**Setup 2FA:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/2fa/setup \
  -H "Authorization: Bearer $TOKEN"
```

**Enable 2FA:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/2fa/enable \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"code": "123456"}'
```

## 🏗️ Building the ISO

Build a bare-metal hypervisor ISO:

```bash
./scripts/build-iso.sh
```

This creates a bootable ISO with:
- Minimal Linux (Debian-based)
- Pre-installed hypervisor daemon
- Auto-registration via cloud-init
- Systemd service configuration

Flash to USB:
```bash
sudo dd if=cs2panel-hypervisor-20250121.iso of=/dev/sdX bs=4M status=progress
```

## 📊 Monitoring

### Prometheus Metrics

Backend metrics available at: `http://localhost:8080/actuator/prometheus`

Hypervisor metrics available at: `http://localhost:8081/v1/metrics`

### Health Checks

```bash
# Backend
curl http://localhost:8080/actuator/health

# Hypervisor
curl http://localhost:8081/v1/health
```

## 🤖 Discord Bot Commands

```
!cs2panel help              - Show help
!cs2panel servers           - List all servers
!cs2panel server <id>       - Show server details
!cs2panel start <id>        - Start server
!cs2panel stop <id>         - Stop server
!cs2panel status            - System status
```

## 🔄 CI/CD

GitHub Actions workflow included for:
- Build backend (Maven/Gradle)
- Build hypervisor daemon (Go)
- Run tests
- Build Docker images
- Push to registry
- Deploy to Kubernetes

## 🐛 Troubleshooting

### Backend won't start

Check database connection:
```bash
docker-compose logs postgres
```

Verify environment variables:
```bash
docker-compose config
```

### Hypervisor daemon issues

Check QEMU/KVM availability:
```bash
qemu-system-x86_64 --version
lsmod | grep kvm
```

View logs:
```bash
docker-compose logs hypervisor
```

### Kubernetes deployment fails

Check CRDs:
```bash
kubectl get crds
```

View pod logs:
```bash
kubectl logs -n cs2panel -l component=backend
```

## 📝 License

Proprietary - © 2025 CS2Panel Team

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📧 Support

- Email: support@cs2panel.example.com
- Discord: https://discord.gg/cs2panel
- Documentation: https://docs.cs2panel.example.com

## ⚠️ Important Notes

### Security Considerations

- **RBAC Protection**: All dangerous admin operations are gated by RBAC permissions
- **Audit Logging**: All administrative actions are logged
- **Input Validation**: All user inputs are validated and sanitized
- **Rate Limiting**: API endpoints are rate-limited to prevent abuse

### Development vs Production

This is a **functional stub implementation** intended for development and proof-of-concept. For production use:

1. **Replace stub implementations** with actual integrations
2. **Configure proper SSL/TLS** certificates
3. **Set up database backups** and replication
4. **Implement proper monitoring** and alerting
5. **Harden security** settings and secrets management
6. **Scale infrastructure** according to load requirements

### Ethical Use

This platform is designed for **legitimate infrastructure management only**:
- ✅ Managing your own game servers
- ✅ Infrastructure automation
- ✅ Educational purposes in isolated environments
- ❌ DO NOT use for hacking or cheating in multiplayer games
- ❌ DO NOT use to disrupt other players' experience
- ❌ DO NOT bypass anti-cheat systems

---

**Built with ❤️ using Spring Boot, Go, Kubernetes, and AI**
