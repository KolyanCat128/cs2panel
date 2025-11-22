#!/bin/bash
set -e

# CS2Panel Hypervisor Installation Script
# Для установки на уже установленную Ubuntu 24.04 с NVMe

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}"
cat << 'BANNER'
╔═══════════════════════════════════════════════════════════════╗
║                                                                ║
║   ██████╗███████╗██████╗ ██████╗  █████╗ ███╗   ██╗███████╗██║║
║  ██╔════╝██╔════╝╚════██╗██╔══██╗██╔══██╗████╗  ██║██╔════╝██║║
║  ██║     ███████╗ █████╔╝██████╔╝███████║██╔██╗ ██║█████╗  ██║║
║  ██║     ╚════██║██╔═══╝ ██╔═══╝ ██╔══██║██║╚██╗██║██╔══╝  ██║║
║  ╚██████╗███████║███████╗██║     ██║  ██║██║ ╚████║███████╗███████╗
║   ╚═════╝╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝
║                                                                ║
║         CS2Panel Hypervisor Installation Script v${VERSION}       ║
║              For Ubuntu 24.04 with NVMe Support                ║
║                                                                ║
╚═══════════════════════════════════════════════════════════════╝
BANNER
echo -e "${NC}"
echo ""

# ==================== ПРОВЕРКИ ====================

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Этот скрипт должен запускаться с правами root${NC}"
    echo -e "   Используйте: ${YELLOW}sudo $0${NC}"
    exit 1
fi

# Проверка Ubuntu 24.04
echo -e "${BLUE}🔍 Проверка системы...${NC}"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" != "ubuntu" ]; then
        echo -e "${RED}❌ Этот скрипт предназначен для Ubuntu${NC}"
        echo -e "   Обнаружено: $ID"
        exit 1
    fi

    # Проверка версии (24.04 или новее)
    VERSION_NUM=$(echo $VERSION_ID | cut -d. -f1)
    if [ "$VERSION_NUM" -lt 24 ]; then
        echo -e "${YELLOW}⚠️  Обнаружена Ubuntu $VERSION_ID${NC}"
        echo -e "   Рекомендуется Ubuntu 24.04 или новее"
        read -p "Продолжить? (yes/no): " CONFIRM
        if [ "$CONFIRM" != "yes" ]; then
            exit 0
        fi
    else
        echo -e "${GREEN}✅ Ubuntu $VERSION_ID обнаружена${NC}"
    fi
else
    echo -e "${RED}❌ Не удалось определить версию ОС${NC}"
    exit 1
fi

# Проверка виртуализации
echo ""
echo -e "${BLUE}🔍 Проверка поддержки виртуализации...${NC}"
if grep -E 'vmx|svm' /proc/cpuinfo > /dev/null 2>&1; then
    if grep -q 'vmx' /proc/cpuinfo; then
        VT_TYPE="Intel VT-x"
    else
        VT_TYPE="AMD-V"
    fi
    echo -e "${GREEN}✅ Виртуализация поддерживается ($VT_TYPE)${NC}"
else
    echo -e "${RED}❌ Виртуализация не поддерживается или не включена в BIOS${NC}"
    echo -e "   Включите Intel VT-x / AMD-V в настройках BIOS"
    exit 1
fi

# Проверка KVM модуля
if lsmod | grep -q kvm; then
    echo -e "${GREEN}✅ KVM модуль загружен${NC}"
else
    echo -e "${YELLOW}⚠️  KVM модуль не загружен, будет загружен автоматически${NC}"
fi

# Проверка NVMe дисков
echo ""
echo -e "${BLUE}🔍 Проверка дисков...${NC}"
if ls /dev/nvme* > /dev/null 2>&1; then
    echo -e "${GREEN}✅ NVMe диски обнаружены:${NC}"
    lsblk -d -o NAME,SIZE,MODEL | grep nvme || true
    HAS_NVME=true
else
    echo -e "${YELLOW}⚠️  NVMe диски не обнаружены${NC}"
    lsblk -d -o NAME,SIZE,MODEL | grep -E 'sd|hd' || true
    HAS_NVME=false
fi

# Проверка свободного места
echo ""
echo -e "${BLUE}🔍 Проверка свободного места...${NC}"
ROOT_AVAILABLE=$(df -BG / | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$ROOT_AVAILABLE" -lt 10 ]; then
    echo -e "${RED}❌ Недостаточно свободного места (минимум 10GB)${NC}"
    echo -e "   Доступно: ${ROOT_AVAILABLE}GB"
    exit 1
fi
echo -e "${GREEN}✅ Свободное место: ${ROOT_AVAILABLE}GB${NC}"

# Проверка RAM
echo ""
echo -e "${BLUE}🔍 Проверка оперативной памяти...${NC}"
TOTAL_RAM=$(free -g | grep Mem | awk '{print $2}')
if [ "$TOTAL_RAM" -lt 4 ]; then
    echo -e "${YELLOW}⚠️  Рекомендуется минимум 4GB RAM${NC}"
    echo -e "   Обнаружено: ${TOTAL_RAM}GB"
    read -p "Продолжить? (yes/no): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        exit 0
    fi
else
    echo -e "${GREEN}✅ RAM: ${TOTAL_RAM}GB${NC}"
fi

# Подтверждение установки
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}⚠️  Эта установка выполнит следующие действия:${NC}"
echo ""
echo "  1. Обновит список пакетов"
echo "  2. Установит QEMU/KVM и libvirt"
echo "  3. Установит системные утилиты и мониторинг"
echo "  4. Создаст пользователя cs2admin"
echo "  5. Установит CS2Panel Hypervisor Daemon"
echo "  6. Настроит systemd сервисы"
echo "  7. Настроит SSH и безопасность"
echo "  8. Оптимизирует систему для виртуализации"
if [ "$HAS_NVME" = true ]; then
    echo "  9. Применит оптимизации для NVMe"
fi
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""
read -p "Начать установку? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Установка отменена."
    exit 0
fi

# ==================== УСТАНОВКА ====================

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         ЭТАП 1: Обновление системы                ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

export DEBIAN_FRONTEND=noninteractive

echo -e "${BLUE}📦 Обновление списка пакетов...${NC}"
apt-get update -qq

echo -e "${BLUE}📦 Обновление существующих пакетов...${NC}"
apt-get upgrade -y -qq

echo -e "${GREEN}✅ Система обновлена${NC}"

# ==================== ЭТАП 2: Виртуализация ====================

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         ЭТАП 2: Установка виртуализации           ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}📦 Установка QEMU/KVM...${NC}"
apt-get install -y -qq \
    qemu-kvm \
    qemu-system-x86 \
    qemu-utils \
    qemu-block-extra \
    qemu-system-gui

echo -e "${BLUE}📦 Установка libvirt...${NC}"
apt-get install -y -qq \
    libvirt-daemon-system \
    libvirt-daemon \
    libvirt-clients \
    libvirt-daemon-driver-qemu

echo -e "${BLUE}📦 Установка сетевых утилит для виртуализации...${NC}"
apt-get install -y -qq \
    bridge-utils \
    virt-manager \
    ovmf \
    vlan \
    dnsmasq

echo -e "${GREEN}✅ Виртуализация установлена${NC}"

# ==================== ЭТАП 3: Системные утилиты ====================

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         ЭТАП 3: Установка системных утилит        ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}📦 Установка базовых утилит...${NC}"
apt-get install -y -qq \
    curl \
    wget \
    vim \
    nano \
    htop \
    iotop \
    net-tools \
    iputils-ping \
    iproute2 \
    ethtool \
    tcpdump \
    socat \
    jq \
    git

echo -e "${BLUE}📦 Установка SSH сервера...${NC}"
apt-get install -y -qq openssh-server

echo -e "${BLUE}📦 Установка инструментов мониторинга...${NC}"
apt-get install -y -qq \
    lm-sensors \
    smartmontools \
    nvme-cli \
    sysstat \
    dmidecode \
    lshw \
    hwinfo

if [ "$HAS_NVME" = true ]; then
    echo -e "${BLUE}📦 Установка NVMe утилит...${NC}"
    apt-get install -y -qq \
        nvme-cli \
        nvme-stas
fi

echo -e "${BLUE}📦 Установка инструментов для производительности...${NC}"
apt-get install -y -qq \
    linux-tools-common \
    linux-tools-generic \
    cpufrequtils \
    irqbalance

echo -e "${GREEN}✅ Системные утилиты установлены${NC}"

# ==================== ЭТАП 4: Настройка пользователя ====================

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         ЭТАП 4: Настройка пользователей           ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

# Создание пользователя cs2admin (если не существует)
if id "cs2admin" &>/dev/null; then
    echo -e "${YELLOW}⚠️  Пользователь cs2admin уже существует${NC}"
else
    echo -e "${BLUE}👤 Создание пользователя cs2admin...${NC}"
    useradd -m -s /bin/bash -G sudo,libvirt,kvm cs2admin
    echo "cs2admin:cs2panel" | chpasswd

    # Настройка sudo без пароля
    cat > /etc/sudoers.d/cs2admin << 'EOF'
# CS2Panel admin user
cs2admin ALL=(ALL) NOPASSWD:ALL
EOF
    chmod 0440 /etc/sudoers.d/cs2admin

    echo -e "${GREEN}✅ Пользователь cs2admin создан${NC}"
    echo -e "${YELLOW}   Логин: cs2admin${NC}"
    echo -e "${YELLOW}   Пароль: cs2panel${NC}"
    echo -e "${RED}   ⚠️  ИЗМЕНИТЕ ПАРОЛЬ ПОСЛЕ ПЕРВОГО ВХОДА!${NC}"
fi

# Добавление текущего пользователя в группы
CURRENT_USER="${SUDO_USER:-$USER}"
if [ "$CURRENT_USER" != "root" ] && [ -n "$CURRENT_USER" ]; then
    echo -e "${BLUE}👤 Добавление пользователя $CURRENT_USER в группы libvirt и kvm...${NC}"
    usermod -aG libvirt,kvm "$CURRENT_USER" || true
    echo -e "${GREEN}✅ Пользователь $CURRENT_USER добавлен в группы${NC}"
fi

# ==================== ЭТАП 5: CS2Panel Hypervisor ====================

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         ЭТАП 5: Установка CS2Panel Hypervisor     ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

# Создание директорий
echo -e "${BLUE}📁 Создание директорий...${NC}"
mkdir -p /var/lib/cs2panel
mkdir -p /var/log/cs2panel
mkdir -p /etc/cs2panel

# Копирование или создание hypervisor daemon
if [ -f "${SCRIPT_DIR}/../hypervisor/bin/hypervisor-daemon" ]; then
    echo -e "${BLUE}📦 Установка CS2Panel Hypervisor Daemon...${NC}"
    cp "${SCRIPT_DIR}/../hypervisor/bin/hypervisor-daemon" /usr/local/bin/
    chmod +x /usr/local/bin/hypervisor-daemon
    echo -e "${GREEN}✅ Hypervisor daemon установлен${NC}"
else
    echo -e "${YELLOW}⚠️  Hypervisor daemon не найден${NC}"
    echo -e "${BLUE}📦 Создание заглушки daemon...${NC}"
    cat > /usr/local/bin/hypervisor-daemon << 'EOF'
#!/bin/bash
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║        CS2Panel Hypervisor Daemon (Development Mode)          ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "⚠️  Запущена заглушка daemon."
echo "📝 Для работы реального daemon выполните:"
echo ""
echo "   cd $(dirname $0)/../hypervisor"
echo "   go build -o bin/hypervisor-daemon ."
echo "   sudo cp bin/hypervisor-daemon /usr/local/bin/"
echo "   sudo systemctl restart cs2panel-hypervisor"
echo ""
echo "🔧 Сервис работает в режиме ожидания..."
sleep infinity
EOF
    chmod +x /usr/local/bin/hypervisor-daemon
    echo -e "${GREEN}✅ Заглушка daemon создана${NC}"
fi

# Создание конфигурационного файла
echo -e "${BLUE}⚙️  Создание конфигурационного файла...${NC}"
cat > /etc/cs2panel/hypervisor.yaml << 'EOF'
# CS2Panel Hypervisor Configuration

server:
  http_port: 8080
  grpc_port: 9090

database:
  path: /var/lib/cs2panel/hypervisor.db

logging:
  level: info
  file: /var/log/cs2panel/hypervisor.log

virtualization:
  default_driver: qemu:///system
  storage_pool: default
  network: default

resources:
  max_vms: 100
  default_cpu: 2
  default_memory: 2048

EOF

# Создание systemd service
echo -e "${BLUE}⚙️  Создание systemd сервиса...${NC}"
cat > /etc/systemd/system/cs2panel-hypervisor.service << 'EOF'
[Unit]
Description=CS2Panel Hypervisor Daemon
Documentation=https://github.com/cs2panel/hypervisor
After=network-online.target libvirtd.service
Wants=network-online.target
Requires=libvirtd.service

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/local/bin/hypervisor-daemon
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

# Environment
Environment="HTTP_PORT=8080"
Environment="GRPC_PORT=9090"
Environment="CONFIG_FILE=/etc/cs2panel/hypervisor.yaml"
Environment="DB_PATH=/var/lib/cs2panel/hypervisor.db"
Environment="LOG_LEVEL=info"

# Security
NoNewPrivileges=false
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/lib/cs2panel /var/log/cs2panel /run/libvirt

# Resource limits
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

# Перезагрузка systemd
systemctl daemon-reload

# Включение сервисов
echo -e "${BLUE}⚙️  Включение сервисов...${NC}"
systemctl enable libvirtd.service
systemctl enable cs2panel-hypervisor.service

echo -e "${GREEN}✅ CS2Panel Hypervisor установлен${NC}"

# ==================== ЭТАП 6: Настройка SSH ====================

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         ЭТАП 6: Настройка SSH                     ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}🔒 Настройка SSH...${NC}"
mkdir -p /etc/ssh/sshd_config.d

cat > /etc/ssh/sshd_config.d/cs2panel.conf << 'EOF'
# CS2Panel SSH Configuration
PermitRootLogin prohibit-password
PasswordAuthentication yes
PubkeyAuthentication yes
X11Forwarding no
PrintMotd yes
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server

# Security
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
EOF

systemctl enable ssh.service
systemctl restart ssh.service || true

echo -e "${GREEN}✅ SSH настроен${NC}"

# ==================== ЭТАП 7: Создание MOTD ====================

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         ЭТАП 7: Настройка приветствия             ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}🎨 Создание MOTD...${NC}"

# Отключаем стандартные MOTD скрипты
chmod -x /etc/update-motd.d/* 2>/dev/null || true

# Создаем свой MOTD
cat > /etc/motd << 'EOF'

╔═══════════════════════════════════════════════════════════════╗
║                                                                ║
║   ██████╗███████╗██████╗ ██████╗  █████╗ ███╗   ██╗███████╗██║║
║  ██╔════╝██╔════╝╚════██╗██╔══██╗██╔══██╗████╗  ██║██╔════╝██║║
║  ██║     ███████╗ █████╔╝██████╔╝███████║██╔██╗ ██║█████╗  ██║║
║  ██║     ╚════██║██╔═══╝ ██╔═══╝ ██╔══██║██║╚██╗██║██╔══╝  ██║║
║  ╚██████╗███████║███████╗██║     ██║  ██║██║ ╚████║███████╗███████╗
║   ╚═════╝╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝
║                                                                ║
║              CS2 Infrastructure Panel - Hypervisor             ║
║                         Version 1.0.0                          ║
║                                                                ║
╚═══════════════════════════════════════════════════════════════╝

Добро пожаловать в CS2Panel Hypervisor!

🔧 Управление:
   • Статус:    systemctl status cs2panel-hypervisor
   • Логи:      journalctl -u cs2panel-hypervisor -f
   • Перезапуск: systemctl restart cs2panel-hypervisor
   • API:       curl http://localhost:8080/v1/health

📊 Мониторинг виртуальных машин:
   • Список VMs:    virsh list --all
   • Создать VM:    virt-install ...
   • Подключиться:  virsh console <vm-name>
   • Информация:    virsh dominfo <vm-name>

💻 Системная информация:
   • CPU:    lscpu
   • RAM:    free -h
   • Диск:   df -h
   • NVMe:   nvme list
   • Сеть:   ip addr

🔗 Полезные команды:
   • Virsh pool:    virsh pool-list --all
   • Virsh network: virsh net-list --all
   • QEMU версия:   qemu-system-x86_64 --version

📚 Документация: https://docs.cs2panel.example.com
🐛 Баги/Вопросы:  https://github.com/cs2panel/hypervisor/issues

EOF

echo -e "${GREEN}✅ MOTD создан${NC}"

# ==================== ЭТАП 8: Оптимизация системы ====================

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         ЭТАП 8: Оптимизация системы               ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}⚡ Применение оптимизаций для виртуализации...${NC}"

# Настройка sysctl для виртуализации
cat > /etc/sysctl.d/99-cs2panel-virtualization.conf << 'EOF'
# CS2Panel Hypervisor - Virtualization Optimizations

# Networking
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-ip6tables = 0

# Memory
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_ratio = 40
vm.dirty_background_ratio = 10

# KVM
kernel.sched_migration_cost_ns = 5000000
kernel.sched_autogroup_enabled = 0

# Network buffers
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864

# File handles
fs.file-max = 2097152
EOF

# Применение настроек
sysctl -p /etc/sysctl.d/99-cs2panel-virtualization.conf > /dev/null 2>&1 || true

# Настройка limits
cat > /etc/security/limits.d/99-cs2panel.conf << 'EOF'
# CS2Panel Hypervisor Limits
* soft nofile 65536
* hard nofile 65536
* soft nproc 4096
* hard nproc 4096
root soft nofile 65536
root hard nofile 65536
EOF

# Оптимизация для NVMe
if [ "$HAS_NVME" = true ]; then
    echo -e "${BLUE}⚡ Применение оптимизаций для NVMe...${NC}"

    cat > /etc/udev/rules.d/60-nvme-scheduler.rules << 'EOF'
# NVMe disk scheduler optimization for CS2Panel
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/nomerges}="2"
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/nr_requests}="256"
EOF

    # Применение правил udev
    udevadm control --reload-rules
    udevadm trigger

    echo -e "${GREEN}✅ NVMe оптимизации применены${NC}"
fi

# Настройка KVM модуля
if [ -f /sys/module/kvm_intel/parameters/nested ]; then
    # Intel
    cat > /etc/modprobe.d/kvm.conf << 'EOF'
# KVM Intel optimizations
options kvm_intel nested=1
options kvm_intel enable_shadow_vmcs=1
options kvm_intel enable_apicv=1
options kvm_intel ept=1
EOF
elif [ -f /sys/module/kvm_amd/parameters/nested ]; then
    # AMD
    cat > /etc/modprobe.d/kvm.conf << 'EOF'
# KVM AMD optimizations
options kvm_amd nested=1
EOF
fi

# Настройка huge pages для лучшей производительности VM
echo -e "${BLUE}⚡ Настройка huge pages...${NC}"
TOTAL_RAM_MB=$(free -m | grep Mem | awk '{print $2}')
HUGEPAGES_COUNT=$((TOTAL_RAM_MB / 4))  # 25% RAM для hugepages

cat > /etc/sysctl.d/99-cs2panel-hugepages.conf << EOF
# Huge pages for better VM performance
vm.nr_hugepages = $HUGEPAGES_COUNT
EOF

sysctl -p /etc/sysctl.d/99-cs2panel-hugepages.conf > /dev/null 2>&1 || true

echo -e "${GREEN}✅ Оптимизации применены${NC}"

# ==================== ЭТАП 9: Настройка libvirt ====================

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         ЭТАП 9: Настройка libvirt                 ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}⚙️  Настройка libvirt...${NC}"

# Запуск libvirt если еще не запущен
systemctl start libvirtd || true

# Настройка default network
virsh net-autostart default 2>/dev/null || true
virsh net-start default 2>/dev/null || true

# Настройка default storage pool
if ! virsh pool-list --all | grep -q default; then
    echo -e "${BLUE}📁 Создание default storage pool...${NC}"
    virsh pool-define-as default dir --target /var/lib/libvirt/images
    virsh pool-build default
    virsh pool-start default
    virsh pool-autostart default
fi

echo -e "${GREEN}✅ libvirt настроен${NC}"

# ==================== ЭТАП 10: Очистка ====================

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         ЭТАП 10: Очистка                          ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}🧹 Очистка кэша пакетов...${NC}"
apt-get autoremove -y -qq
apt-get clean

echo -e "${GREEN}✅ Очистка завершена${NC}"

# ==================== ЗАВЕРШЕНИЕ ====================

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                    ║${NC}"
echo -e "${GREEN}║   ✅ УСТАНОВКА УСПЕШНО ЗАВЕРШЕНА! ✅              ║${NC}"
echo -e "${GREEN}║                                                    ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

# Получение IP адреса
IP_ADDR=$(hostname -I | awk '{print $1}')

echo -e "${CYAN}📋 Информация о системе:${NC}"
echo ""
echo -e "  🖥️  Hostname:    $(hostname)"
echo -e "  🌐 IP адрес:    ${IP_ADDR}"
echo -e "  💾 RAM:         ${TOTAL_RAM}GB"
if [ "$HAS_NVME" = true ]; then
    echo -e "  💿 Диск:       NVMe (оптимизировано)"
else
    echo -e "  💿 Диск:       HDD/SSD"
fi
echo -e "  🔧 Виртуализация: $VT_TYPE"
echo ""

echo -e "${CYAN}👤 Учетные данные:${NC}"
echo ""
echo -e "  Пользователь: ${YELLOW}cs2admin${NC}"
echo -e "  Пароль:       ${YELLOW}cs2panel${NC}"
echo -e "  ${RED}⚠️  ОБЯЗАТЕЛЬНО СМЕНИТЕ ПАРОЛЬ!${NC}"
echo ""

echo -e "${CYAN}🔗 Доступ к сервисам:${NC}"
echo ""
echo -e "  API:      http://${IP_ADDR}:8080"
echo -e "  gRPC:     ${IP_ADDR}:9090"
echo -e "  SSH:      ssh cs2admin@${IP_ADDR}"
echo ""

echo -e "${CYAN}🚀 Полезные команды:${NC}"
echo ""
echo -e "  Проверить статус hypervisor:"
echo -e "    ${YELLOW}systemctl status cs2panel-hypervisor${NC}"
echo ""
echo -e "  Просмотр логов:"
echo -e "    ${YELLOW}journalctl -u cs2panel-hypervisor -f${NC}"
echo ""
echo -e "  Проверить API:"
echo -e "    ${YELLOW}curl http://localhost:8080/v1/health${NC}"
echo ""
echo -e "  Список виртуальных машин:"
echo -e "    ${YELLOW}virsh list --all${NC}"
echo ""
echo -e "  Запустить сервисы:"
echo -e "    ${YELLOW}systemctl start cs2panel-hypervisor${NC}"
echo -e "    ${YELLOW}systemctl start libvirtd${NC}"
echo ""

echo -e "${YELLOW}⚠️  ВАЖНО:${NC}"
echo ""
echo -e "  1. Настройте сеть если нужно (см. /etc/netplan/)"
echo -e "  2. Смените пароль пользователя cs2admin"
echo -e "  3. Настройте firewall если необходимо"
echo -e "  4. Перезагрузите систему для применения всех настроек:"
echo -e "     ${YELLOW}sudo reboot${NC}"
echo ""

echo -e "${CYAN}📚 Дополнительная информация:${NC}"
echo ""
echo -e "  Конфигурация:  /etc/cs2panel/hypervisor.yaml"
echo -e "  Логи:          /var/log/cs2panel/"
echo -e "  Данные:        /var/lib/cs2panel/"
echo -e "  Документация:  https://docs.cs2panel.example.com"
echo ""

echo -e "${GREEN}Спасибо за использование CS2Panel! 🎉${NC}"
echo ""

# Создание маркера успешной установки
touch /var/lib/cs2panel/.installed
date > /var/lib/cs2panel/.install-date

# Логирование установки
cat > /var/lib/cs2panel/install.log << EOF
CS2Panel Hypervisor Installation Log
=====================================
Date: $(date)
Version: $VERSION
OS: $(lsb_release -d | cut -f2)
Kernel: $(uname -r)
Hostname: $(hostname)
IP: $IP_ADDR
RAM: ${TOTAL_RAM}GB
NVMe: $HAS_NVME
Virtualization: $VT_TYPE
EOF

echo -e "${BLUE}💾 Лог установки сохранен в /var/lib/cs2panel/install.log${NC}"
echo ""
