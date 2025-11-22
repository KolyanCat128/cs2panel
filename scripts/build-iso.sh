#!/bin/bash
set -e

# CS2Panel Hypervisor ISO Builder (ESXi-style)
# Создает загрузочный ISO для установки bare-metal гипервизора

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/iso-build"
ISO_DIR="${BUILD_DIR}/iso"
OUTPUT_DIR="${SCRIPT_DIR}"
ISO_NAME="cs2panel-hypervisor-${VERSION}.iso"

ARCH="amd64"
DISTRO="ubuntu"
DISTRO_VERSION="22.04"
DISTRO_CODENAME="jammy"

echo "╔═══════════════════════════════════════════════════╗"
echo "║   CS2Panel Hypervisor ISO Builder v${VERSION}       ║"
echo "║   ESXi-style Bare-Metal Installation              ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Этот скрипт должен запускаться с правами root"
    echo "   Используйте: sudo $0"
    exit 1
fi

# Проверка зависимостей
echo "📦 Проверка зависимостей..."
DEPENDENCIES=(
    "debootstrap"
    "genisoimage"
    "xorriso"
    "isolinux"
    "syslinux"
    "squashfs-tools"
    "grub-pc-bin"
    "grub-efi-amd64-bin"
)

MISSING_DEPS=()
for dep in "${DEPENDENCIES[@]}"; do
    if ! dpkg -l | grep -q "^ii  $dep"; then
        MISSING_DEPS+=("$dep")
    fi
done

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo "❌ Отсутствуют зависимости: ${MISSING_DEPS[*]}"
    echo "   Установите: apt-get install ${MISSING_DEPS[*]}"
    exit 1
fi

echo "✅ Все зависимости установлены"
echo ""

# Очистка предыдущей сборки
if [ -d "${BUILD_DIR}" ]; then
    echo "🧹 Очистка предыдущей сборки..."
    rm -rf "${BUILD_DIR}"
fi

# Создание структуры директорий
echo "📁 Создание структуры директорий..."
mkdir -p "${BUILD_DIR}"/{chroot,iso/{live,install,boot/{grub,isolinux}}}
cd "${BUILD_DIR}"

# ==================== ЭТАП 1: Создание базовой системы ====================
echo ""
echo "═══════════════════════════════════════════════════"
echo "ЭТАП 1: Создание базовой системы Ubuntu ${DISTRO_VERSION}"
echo "═══════════════════════════════════════════════════"
echo ""

echo "⏳ Загрузка базовой системы (это может занять несколько минут)..."
debootstrap \
    --arch=${ARCH} \
    --variant=minbase \
    ${DISTRO_CODENAME} \
    chroot \
    http://archive.ubuntu.com/ubuntu/

echo "✅ Базовая система создана"

# ==================== ЭТАП 2: Настройка chroot ====================
echo ""
echo "═══════════════════════════════════════════════════"
echo "ЭТАП 2: Настройка системы"
echo "═══════════════════════════════════════════════════"
echo ""

# Монтирование необходимых файловых систем
mount -o bind /dev chroot/dev
mount -o bind /dev/pts chroot/dev/pts
mount -t proc proc chroot/proc
mount -t sysfs sysfs chroot/sys

# Создание скрипта настройки для выполнения в chroot
cat > chroot/tmp/setup-chroot.sh << 'CHROOT_SCRIPT'
#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

echo "📦 Обновление списка пакетов..."
apt-get update

echo "📦 Установка ядра Linux и базовых пакетов..."
apt-get install -y \
    linux-image-generic \
    linux-headers-generic \
    grub-pc \
    grub-efi-amd64 \
    grub-efi-amd64-signed \
    shim-signed

echo "📦 Установка системных утилит..."
apt-get install -y \
    systemd \
    systemd-sysv \
    udev \
    dbus \
    sudo \
    bash-completion \
    curl \
    wget \
    vim \
    nano \
    htop \
    net-tools \
    iputils-ping \
    iproute2 \
    ethtool \
    vlan \
    bridge-utils

echo "📦 Установка SSH сервера..."
apt-get install -y openssh-server

echo "📦 Установка Network Manager..."
apt-get install -y \
    network-manager \
    resolvconf

echo "📦 Установка QEMU/KVM и виртуализации..."
apt-get install -y \
    qemu-kvm \
    qemu-system-x86 \
    qemu-utils \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    virt-manager \
    ovmf

echo "📦 Установка дополнительных драйверов..."
apt-get install -y \
    firmware-linux \
    linux-firmware

echo "📦 Установка инструментов мониторинга..."
apt-get install -y \
    lm-sensors \
    smartmontools \
    nvme-cli \
    dmidecode

echo "🧹 Очистка кэша..."
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "✅ Установка пакетов завершена"
CHROOT_SCRIPT

chmod +x chroot/tmp/setup-chroot.sh

echo "⏳ Установка пакетов в chroot (это займет время)..."
chroot chroot /tmp/setup-chroot.sh

# ==================== ЭТАП 3: Настройка системы ====================
echo ""
echo "═══════════════════════════════════════════════════"
echo "ЭТАП 3: Настройка CS2Panel Hypervisor"
echo "═══════════════════════════════════════════════════"
echo ""

# Создание пользователя cs2admin
echo "👤 Создание пользователя cs2admin..."
chroot chroot useradd -m -s /bin/bash -G sudo cs2admin || true
echo "cs2admin:cs2panel" | chroot chroot chpasswd

# Настройка sudo без пароля
echo "cs2admin ALL=(ALL) NOPASSWD:ALL" > chroot/etc/sudoers.d/cs2admin
chmod 0440 chroot/etc/sudoers.d/cs2admin

# Установка hostname
echo "cs2panel-hypervisor" > chroot/etc/hostname

# Настройка hosts
cat > chroot/etc/hosts << 'EOF'
127.0.0.1   localhost
127.0.1.1   cs2panel-hypervisor

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

# Копирование hypervisor daemon
echo "📦 Установка CS2Panel Hypervisor Daemon..."
if [ -f "${SCRIPT_DIR}/../hypervisor/bin/hypervisor-daemon" ]; then
    cp "${SCRIPT_DIR}/../hypervisor/bin/hypervisor-daemon" chroot/usr/local/bin/
    chmod +x chroot/usr/local/bin/hypervisor-daemon
    echo "✅ Hypervisor daemon установлен"
else
    echo "⚠️  Hypervisor daemon не найден, создание заглушки..."
    cat > chroot/usr/local/bin/hypervisor-daemon << 'EOF'
#!/bin/bash
echo "CS2Panel Hypervisor Daemon (stub)"
echo "Скомпилируйте реальный daemon из hypervisor/"
sleep infinity
EOF
    chmod +x chroot/usr/local/bin/hypervisor-daemon
fi

# Создание systemd service для hypervisor
cat > chroot/etc/systemd/system/cs2panel-hypervisor.service << 'EOF'
[Unit]
Description=CS2Panel Hypervisor Daemon
Documentation=https://github.com/cs2panel/hypervisor
After=network-online.target libvirtd.service
Wants=network-online.target

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
Environment="DB_PATH=/var/lib/cs2panel/hypervisor.db"
Environment="LOG_LEVEL=info"

# Security
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/lib/cs2panel /var/log

[Install]
WantedBy=multi-user.target
EOF

# Создание директории для данных
mkdir -p chroot/var/lib/cs2panel
chown root:root chroot/var/lib/cs2panel
chmod 755 chroot/var/lib/cs2panel

# Включение сервиса
chroot chroot systemctl enable cs2panel-hypervisor.service

# Настройка автозапуска KVM
chroot chroot systemctl enable libvirtd.service

# Настройка SSH
echo "🔒 Настройка SSH..."
cat > chroot/etc/ssh/sshd_config.d/cs2panel.conf << 'EOF'
# CS2Panel SSH Configuration
PermitRootLogin prohibit-password
PasswordAuthentication yes
PubkeyAuthentication yes
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
EOF

chroot chroot systemctl enable ssh.service

# Создание MOTD
cat > chroot/etc/motd << 'EOF'

╔═══════════════════════════════════════════════════════════════╗
║                                                                ║
║   ██████╗███████╗██████╗ ██████╗  █████╗ ███╗   ██╗███████╗██╗║
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
   • Статус: systemctl status cs2panel-hypervisor
   • Логи:   journalctl -u cs2panel-hypervisor -f
   • API:    curl http://localhost:8080/v1/health

📊 Мониторинг:
   • VMs:    virsh list --all
   • CPU:    lscpu
   • RAM:    free -h
   • Disk:   df -h

📚 Документация: https://docs.cs2panel.example.com

EOF

# Создание скрипта первого запуска
cat > chroot/usr/local/bin/cs2panel-first-boot << 'EOF'
#!/bin/bash

MARKER="/var/lib/cs2panel/.first-boot-done"

if [ -f "$MARKER" ]; then
    exit 0
fi

echo "═══════════════════════════════════════════════════"
echo "CS2Panel Hypervisor - Первый запуск"
echo "═══════════════════════════════════════════════════"

# Генерация SSH ключей хоста
ssh-keygen -A

# Настройка часового пояса
timedatectl set-timezone UTC

# Обновление системы
echo "Обновление системы..."
apt-get update
apt-get upgrade -y

# Создание маркера
mkdir -p /var/lib/cs2panel
touch "$MARKER"

echo "✅ Первоначальная настройка завершена"
echo ""
EOF

chmod +x chroot/usr/local/bin/cs2panel-first-boot

# Создание systemd unit для первого запуска
cat > chroot/etc/systemd/system/cs2panel-first-boot.service << 'EOF'
[Unit]
Description=CS2Panel First Boot Setup
After=network-online.target
Before=cs2panel-hypervisor.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/cs2panel-first-boot
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

chroot chroot systemctl enable cs2panel-first-boot.service

# ==================== ЭТАП 4: Создание installer ====================
echo ""
echo "═══════════════════════════════════════════════════"
echo "ЭТАП 4: Создание установщика"
echo "═══════════════════════════════════════════════════"
echo ""

# Создание скрипта установщика
cat > chroot/usr/local/bin/cs2panel-installer << 'INSTALLER_SCRIPT'
#!/bin/bash

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
cat << 'BANNER'
╔═══════════════════════════════════════════════════════════════╗
║                                                                ║
║          CS2Panel Hypervisor Installation Wizard              ║
║                         Version 1.0.0                          ║
║                                                                ║
╚═══════════════════════════════════════════════════════════════╝
BANNER

echo ""
echo -e "${CYAN}Этот мастер установит CS2Panel Hypervisor на ваш сервер.${NC}"
echo ""

# Проверка UEFI/BIOS
if [ -d /sys/firmware/efi ]; then
    BOOT_MODE="UEFI"
    echo -e "${GREEN}✅ Режим загрузки: UEFI${NC}"
else
    BOOT_MODE="BIOS"
    echo -e "${GREEN}✅ Режим загрузки: Legacy BIOS${NC}"
fi

# Определение дисков
echo ""
echo -e "${CYAN}Доступные диски:${NC}"
lsblk -d -n -o NAME,SIZE,TYPE | grep disk | nl
echo ""

# Выбор диска
while true; do
    read -p "Выберите диск для установки (например, sda): " DISK_NAME
    if [ -b "/dev/${DISK_NAME}" ]; then
        TARGET_DISK="/dev/${DISK_NAME}"
        break
    else
        echo -e "${RED}❌ Диск не найден. Попробуйте снова.${NC}"
    fi
done

# Подтверждение
DISK_SIZE=$(lsblk -d -n -o SIZE "/dev/${DISK_NAME}")
echo ""
echo -e "${YELLOW}⚠️  ВНИМАНИЕ: ВСЕ ДАННЫЕ НА ${TARGET_DISK} (${DISK_SIZE}) БУДУТ УДАЛЕНЫ!${NC}"
read -p "Продолжить? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Установка отменена."
    exit 0
fi

echo ""
echo -e "${CYAN}🔧 Начало установки...${NC}"

# Размонтирование если примонтирован
umount ${TARGET_DISK}* 2>/dev/null || true

# Очистка диска
echo "🧹 Очистка диска..."
wipefs -a ${TARGET_DISK}
sgdisk -Z ${TARGET_DISK}

# Создание разделов
echo "📁 Создание разделов..."
if [ "$BOOT_MODE" = "UEFI" ]; then
    # UEFI: EFI + root
    sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI" ${TARGET_DISK}
    sgdisk -n 2:0:0 -t 2:8300 -c 2:"root" ${TARGET_DISK}

    EFI_PART="${TARGET_DISK}1"
    ROOT_PART="${TARGET_DISK}2"
else
    # BIOS: BIOS boot + root
    sgdisk -n 1:0:+1M -t 1:ef02 -c 1:"BIOS" ${TARGET_DISK}
    sgdisk -n 2:0:0 -t 2:8300 -c 2:"root" ${TARGET_DISK}

    ROOT_PART="${TARGET_DISK}2"
fi

# Обновление таблицы разделов
partprobe ${TARGET_DISK}
sleep 2

# Форматирование
echo "💾 Форматирование разделов..."
if [ "$BOOT_MODE" = "UEFI" ]; then
    mkfs.vfat -F32 ${EFI_PART}
fi
mkfs.ext4 -F ${ROOT_PART}

# Монтирование
echo "📌 Монтирование..."
mkdir -p /mnt/target
mount ${ROOT_PART} /mnt/target

if [ "$BOOT_MODE" = "UEFI" ]; then
    mkdir -p /mnt/target/boot/efi
    mount ${EFI_PART} /mnt/target/boot/efi
fi

# Копирование системы
echo "📦 Копирование системы (это займет несколько минут)..."
rsync -aAXv --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/cdrom"} / /mnt/target/

# Создание недостающих директорий
mkdir -p /mnt/target/{dev,proc,sys,tmp,run,mnt,media}

# Монтирование системных директорий
mount -o bind /dev /mnt/target/dev
mount -o bind /dev/pts /mnt/target/dev/pts
mount -t proc proc /mnt/target/proc
mount -t sysfs sysfs /mnt/target/sys

# Установка GRUB
echo "🔧 Установка загрузчика GRUB..."
if [ "$BOOT_MODE" = "UEFI" ]; then
    chroot /mnt/target grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=CS2Panel --recheck
else
    chroot /mnt/target grub-install --target=i386-pc ${TARGET_DISK}
fi

# Обновление конфигурации GRUB
chroot /mnt/target update-grub

# Настройка fstab
echo "📝 Настройка fstab..."
ROOT_UUID=$(blkid -s UUID -o value ${ROOT_PART})

cat > /mnt/target/etc/fstab << FSTAB_EOF
# CS2Panel Hypervisor fstab
UUID=${ROOT_UUID}  /          ext4    errors=remount-ro  0  1
FSTAB_EOF

if [ "$BOOT_MODE" = "UEFI" ]; then
    EFI_UUID=$(blkid -s UUID -o value ${EFI_PART})
    echo "UUID=${EFI_UUID}  /boot/efi  vfat    umask=0077         0  1" >> /mnt/target/etc/fstab
fi

# Настройка сети
echo "🌐 Настройка сети..."
read -p "Введите hostname (по умолчанию cs2panel-hypervisor): " HOSTNAME
HOSTNAME=${HOSTNAME:-cs2panel-hypervisor}
echo $HOSTNAME > /mnt/target/etc/hostname

cat > /mnt/target/etc/netplan/00-installer-config.yaml << NETPLAN_EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    all:
      match:
        name: en*
      dhcp4: true
      dhcp6: false
NETPLAN_EOF

# Размонтирование
echo "🔓 Размонтирование..."
umount /mnt/target/dev/pts
umount /mnt/target/dev
umount /mnt/target/proc
umount /mnt/target/sys

if [ "$BOOT_MODE" = "UEFI" ]; then
    umount /mnt/target/boot/efi
fi

umount /mnt/target

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✅ Установка завершена успешно!                 ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Система установлена на ${TARGET_DISK}${NC}"
echo ""
echo -e "${YELLOW}После перезагрузки:${NC}"
echo "  • Логин: cs2admin"
echo "  • Пароль: cs2panel"
echo "  • API: http://$(hostname -I | awk '{print $1}'):8080"
echo ""
read -p "Нажмите Enter для перезагрузки..."

reboot
INSTALLER_SCRIPT

chmod +x chroot/usr/local/bin/cs2panel-installer

# ==================== ЭТАП 5: Создание Live ISO ====================
echo ""
echo "═══════════════════════════════════════════════════"
echo "ЭТАП 5: Создание загрузочного образа"
echo "═══════════════════════════════════════════════════"
echo ""

# Размонтирование chroot
umount chroot/dev/pts
umount chroot/dev
umount chroot/proc
umount chroot/sys

# Создание squashfs
echo "📦 Создание squashfs образа..."
mksquashfs chroot iso/live/filesystem.squashfs \
    -comp xz \
    -e boot \
    -wildcards

# Копирование ядра и initrd
echo "📦 Копирование ядра..."
cp chroot/boot/vmlinuz-* iso/live/vmlinuz
cp chroot/boot/initrd.img-* iso/live/initrd

# Настройка ISOLINUX (BIOS)
echo "🔧 Настройка ISOLINUX..."
cp /usr/lib/ISOLINUX/isolinux.bin iso/boot/isolinux/
cp /usr/lib/syslinux/modules/bios/ldlinux.c32 iso/boot/isolinux/
cp /usr/lib/syslinux/modules/bios/menu.c32 iso/boot/isolinux/
cp /usr/lib/syslinux/modules/bios/libutil.c32 iso/boot/isolinux/

cat > iso/boot/isolinux/isolinux.cfg << 'EOF'
DEFAULT menu.c32
TIMEOUT 100
PROMPT 0

MENU TITLE CS2Panel Hypervisor Installer

LABEL install
  MENU LABEL ^Install CS2Panel Hypervisor
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live live-config toram ip=dhcp quiet splash ---

LABEL live
  MENU LABEL ^Live Mode (без установки)
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live live-config ip=dhcp quiet splash ---

LABEL rescue
  MENU LABEL ^Rescue Mode
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live live-config single ip=dhcp ---
EOF

# Настройка GRUB (UEFI)
echo "🔧 Настройка GRUB..."
cat > iso/boot/grub/grub.cfg << 'EOF'
set default="0"
set timeout=10

menuentry "Install CS2Panel Hypervisor" {
    linux /live/vmlinuz boot=live live-config toram ip=dhcp quiet splash ---
    initrd /live/initrd
}

menuentry "Live Mode (без установки)" {
    linux /live/vmlinuz boot=live live-config ip=dhcp quiet splash ---
    initrd /live/initrd
}

menuentry "Rescue Mode" {
    linux /live/vmlinuz boot=live live-config single ip=dhcp ---
    initrd /live/initrd
}
EOF

# Создание EFI образа
echo "📦 Создание EFI образа..."
grub-mkstandalone \
    --format=x86_64-efi \
    --output=iso/boot/grub/bootx64.efi \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=iso/boot/grub/grub.cfg"

# Создание EFI boot образа
dd if=/dev/zero of=iso/boot/efiboot.img bs=1M count=10
mkfs.vfat iso/boot/efiboot.img
mmd -i iso/boot/efiboot.img ::EFI ::EFI/BOOT
mcopy -i iso/boot/efiboot.img iso/boot/grub/bootx64.efi ::EFI/BOOT/

# Создание файла описания
cat > iso/.disk/info << EOF
CS2Panel Hypervisor ${VERSION} - Ubuntu ${DISTRO_VERSION}
EOF

mkdir -p iso/.disk
echo "CS2Panel Hypervisor" > iso/.disk/info

# ==================== ЭТАП 6: Создание ISO ====================
echo ""
echo "═══════════════════════════════════════════════════"
echo "ЭТАП 6: Создание финального ISO образа"
echo "═══════════════════════════════════════════════════"
echo ""

echo "🔨 Создание ISO..."
xorriso -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -volid "CS2PANEL" \
    -output "${OUTPUT_DIR}/${ISO_NAME}" \
    -eltorito-boot boot/isolinux/isolinux.bin \
    -eltorito-catalog boot/isolinux/boot.cat \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -eltorito-alt-boot \
    -e boot/efiboot.img \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -append_partition 2 0xef iso/boot/efiboot.img \
    iso/

# Делаем ISO hybrid (bootable USB)
isohybrid --uefi "${OUTPUT_DIR}/${ISO_NAME}"

# Вычисление контрольных сумм
echo "🔐 Вычисление контрольных сумм..."
cd "${OUTPUT_DIR}"
md5sum "${ISO_NAME}" > "${ISO_NAME}.md5"
sha256sum "${ISO_NAME}" > "${ISO_NAME}.sha256"

# Очистка временных файлов
echo ""
echo "🧹 Очистка временных файлов..."
cd "${SCRIPT_DIR}"
rm -rf "${BUILD_DIR}"

ISO_SIZE=$(du -h "${OUTPUT_DIR}/${ISO_NAME}" | cut -f1)

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║           ✅ ISO ОБРАЗ СОЗДАН УСПЕШНО!                         ║"
echo "║                                                                ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "📀 Файл:     ${OUTPUT_DIR}/${ISO_NAME}"
echo "📦 Размер:   ${ISO_SIZE}"
echo ""
echo "🔐 Контрольные суммы:"
echo "   MD5:    $(cat ${OUTPUT_DIR}/${ISO_NAME}.md5 | awk '{print $1}')"
echo "   SHA256: $(cat ${OUTPUT_DIR}/${ISO_NAME}.sha256 | awk '{print $1}')"
echo ""
echo "📝 Инструкции по использованию:"
echo ""
echo "1️⃣  Запись на USB (Linux):"
echo "   sudo dd if=${ISO_NAME} of=/dev/sdX bs=4M status=progress"
echo "   sudo sync"
echo ""
echo "2️⃣  Запись на USB (Windows):"
echo "   Используйте Rufus или Etcher"
echo ""
echo "3️⃣  Загрузка в виртуальной машине:"
echo "   VirtualBox: Settings → Storage → Add Optical Drive"
echo "   VMware: Edit → CD/DVD → Use ISO image"
echo ""
echo "4️⃣  После загрузки выберите: Install CS2Panel Hypervisor"
echo ""
echo "📚 Документация: https://docs.cs2panel.example.com"
echo ""
