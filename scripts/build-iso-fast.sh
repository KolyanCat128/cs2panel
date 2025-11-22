#!/bin/bash
set -e

# CS2Panel Hypervisor ISO Builder (Оптимизировано для HDD)
# Более быстрая сборка с меньшим использованием диска

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Используем tmpfs (RAM) для временных файлов если доступно
if [ -d "/dev/shm" ] && [ $(df /dev/shm --output=avail | tail -1) -gt 10000000 ]; then
    BUILD_DIR="/dev/shm/cs2panel-iso-build"
    echo "✅ Используется RAM диск для ускорения сборки"
else
    BUILD_DIR="${SCRIPT_DIR}/iso-build"
    echo "ℹ️  Используется HDD для сборки"
fi

OUTPUT_DIR="${SCRIPT_DIR}"
ISO_NAME="cs2panel-hypervisor-${VERSION}.iso"

echo "╔═══════════════════════════════════════════════════╗"
echo "║   CS2Panel Hypervisor ISO Builder (Fast Mode)    ║"
echo "║   Оптимизировано для HDD                          ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Запустите с sudo: sudo $0"
    exit 1
fi

# Проверка RAM
TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
if [ $TOTAL_RAM -lt 4096 ]; then
    echo "⚠️  Предупреждение: Мало RAM (${TOTAL_RAM}MB)"
    echo "   Рекомендуется минимум 4GB для быстрой сборки"
    read -p "Продолжить? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Оптимизации для HDD
echo "🔧 Применение оптимизаций для HDD..."

# Отключаем fsync для ускорения (только для сборки!)
export LD_PRELOAD=/lib/x86_64-linux-gnu/libeatmydata.so 2>/dev/null || true

# Используем все доступные ядра CPU
CORES=$(nproc)
export MAKEFLAGS="-j${CORES}"

echo "   • Используется ${CORES} ядер CPU"
echo "   • Отключен fsync (ускорение записи)"
echo "   • Кэширование в RAM"
echo ""

# Установка зависимостей с минимальными рекомендациями
echo "📦 Установка минимальных зависимостей..."
apt-get update -qq
apt-get install -y --no-install-recommends \
    debootstrap \
    xorriso \
    isolinux \
    syslinux \
    squashfs-tools \
    rsync

echo ""
echo "⏳ Начинаем сборку..."
echo "   Примерное время на HDD: 30-50 минут"
echo "   Вы можете закрыть терминал - процесс продолжится"
echo ""

# Создание директорий
mkdir -p "${BUILD_DIR}"/{chroot,iso/live,iso/boot/{grub,isolinux}}
cd "${BUILD_DIR}"

# Минимальная bootstrap система (меньше пакетов = быстрее)
echo "1/6 Создание базовой системы..."
debootstrap \
    --arch=amd64 \
    --variant=minbase \
    --include=linux-image-generic,systemd,openssh-server \
    jammy \
    chroot \
    http://archive.ubuntu.com/ubuntu/ \
    > /dev/null 2>&1 &

DEBOOTSTRAP_PID=$!
echo "   PID: $DEBOOTSTRAP_PID (можно проверить: ps -p $DEBOOTSTRAP_PID)"

# Показываем прогресс
while kill -0 $DEBOOTSTRAP_PID 2>/dev/null; do
    echo -n "."
    sleep 5
done
wait $DEBOOTSTRAP_PID

echo ""
echo "✅ Базовая система готова"

# Минимальная установка пакетов
echo ""
echo "2/6 Установка пакетов..."
mount -o bind /dev chroot/dev
mount -t proc proc chroot/proc
mount -t sysfs sysfs chroot/sys

cat > chroot/tmp/setup.sh << 'SETUP'
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y --no-install-recommends \
    qemu-kvm \
    libvirt-daemon-system \
    grub-pc \
    grub-efi-amd64 \
    sudo \
    curl \
    > /dev/null 2>&1
apt-get clean
rm -rf /var/lib/apt/lists/*
SETUP

chmod +x chroot/tmp/setup.sh
chroot chroot /tmp/setup.sh

# Быстрая настройка
echo ""
echo "3/6 Настройка системы..."
echo "cs2panel-hypervisor" > chroot/etc/hostname
chroot chroot useradd -m -s /bin/bash -G sudo cs2admin 2>/dev/null || true
echo "cs2admin:cs2panel" | chroot chroot chpasswd

# Копирование daemon
if [ -f "${SCRIPT_DIR}/../hypervisor/bin/hypervisor-daemon" ]; then
    cp "${SCRIPT_DIR}/../hypervisor/bin/hypervisor-daemon" chroot/usr/local/bin/
    chmod +x chroot/usr/local/bin/hypervisor-daemon
fi

# Systemd service
cat > chroot/etc/systemd/system/cs2panel-hypervisor.service << 'EOF'
[Unit]
Description=CS2Panel Hypervisor
After=network.target

[Service]
ExecStart=/usr/local/bin/hypervisor-daemon
Restart=always

[Install]
WantedBy=multi-user.target
EOF

chroot chroot systemctl enable cs2panel-hypervisor.service 2>/dev/null || true

umount chroot/proc
umount chroot/sys
umount chroot/dev

# Создание squashfs с максимальной компрессией
echo ""
echo "4/6 Создание образа (это самая долгая часть)..."
mksquashfs chroot iso/live/filesystem.squashfs \
    -comp xz \
    -Xbcj x86 \
    -e boot \
    -b 1M \
    -no-progress \
    > /dev/null 2>&1 &

SQUASH_PID=$!
while kill -0 $SQUASH_PID 2>/dev/null; do
    CURRENT_SIZE=$(du -m iso/live/filesystem.squashfs 2>/dev/null | cut -f1)
    echo -ne "\r   Сжато: ${CURRENT_SIZE}MB..."
    sleep 3
done
wait $SQUASH_PID

echo ""
echo "✅ Образ создан"

# Копирование ядра
echo ""
echo "5/6 Финализация..."
cp chroot/boot/vmlinuz-* iso/live/vmlinuz 2>/dev/null || true
cp chroot/boot/initrd.img-* iso/live/initrd 2>/dev/null || true

# ISOLINUX
cp /usr/lib/ISOLINUX/isolinux.bin iso/boot/isolinux/ 2>/dev/null || true
cp /usr/lib/syslinux/modules/bios/*.c32 iso/boot/isolinux/ 2>/dev/null || true

cat > iso/boot/isolinux/isolinux.cfg << 'EOF'
DEFAULT linux
LABEL linux
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live
TIMEOUT 30
EOF

# GRUB
cat > iso/boot/grub/grub.cfg << 'EOF'
menuentry "CS2Panel Hypervisor" {
    linux /live/vmlinuz boot=live
    initrd /live/initrd
}
EOF

# Создание ISO
echo ""
echo "6/6 Создание ISO файла..."
xorriso -as mkisofs \
    -iso-level 3 \
    -volid "CS2PANEL" \
    -output "${OUTPUT_DIR}/${ISO_NAME}" \
    -b boot/isolinux/isolinux.bin \
    -c boot/isolinux/boot.cat \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    iso/ \
    > /dev/null 2>&1

# Контрольные суммы
cd "${OUTPUT_DIR}"
md5sum "${ISO_NAME}" > "${ISO_NAME}.md5"
sha256sum "${ISO_NAME}" > "${ISO_NAME}.sha256"

# Очистка
echo ""
echo "🧹 Очистка..."
rm -rf "${BUILD_DIR}"

ISO_SIZE=$(du -h "${OUTPUT_DIR}/${ISO_NAME}" | cut -f1)

echo ""
echo "╔═══════════════════════════════════════════════════╗"
echo "║           ✅ ISO СОЗДАН УСПЕШНО!                  ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""
echo "📀 Файл:   ${OUTPUT_DIR}/${ISO_NAME}"
echo "📦 Размер: ${ISO_SIZE}"
echo ""
echo "🔐 Контрольные суммы:"
echo "   MD5:    $(cat ${ISO_NAME}.md5 | awk '{print $1}')"
echo "   SHA256: $(cat ${ISO_NAME}.sha256 | awk '{print $1}')"
echo ""
