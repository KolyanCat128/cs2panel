# Исправление сети в VMware Workstation (Ubuntu 24.04)

## 🔴 Проблема: DHCP не работает в Bridged режиме

### Шаг 1: Проверка на VM

Войдите в VM (через консоль VMware) и выполните:

```bash
# Проверить интерфейсы
ip link show

# Должны увидеть что-то вроде:
# 1: lo: ...
# 2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> ...
# или ens160, ens192 и т.д.

# Проверить статус
ip addr show

# Проверить DHCP клиента
sudo systemctl status systemd-networkd
sudo systemctl status NetworkManager
```

### Шаг 2: Какой интерфейс?

```bash
# Найти имя сетевого интерфейса
ip link | grep -v lo | grep -E "^[0-9]" | awk '{print $2}' | tr -d ':'

# Обычно это:
# ens33  (VMware Workstation)
# ens160 (VMware ESXi)
# ens192 (VMware Fusion)
```

## 🔧 РЕШЕНИЕ 1: Исправление Netplan

### Вариант A: Автоматическая настройка

```bash
# Создать правильную конфигурацию
sudo nano /etc/netplan/00-installer-config.yaml
```

Вставьте это (замените `ens33` на ваш интерфейс):

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: true
      dhcp6: false
      dhcp-identifier: mac
```

Примените:
```bash
sudo netplan apply
```

### Вариант B: С фоллбэком

Если не помогло, попробуйте это:

```yaml
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    ens33:
      dhcp4: true
      dhcp6: false
      optional: true
      addresses: []
```

Примените:
```bash
sudo netplan apply
sudo systemctl restart NetworkManager
```

### Вариант C: Универсальный wildcard

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    all-en:
      match:
        name: "en*"
      dhcp4: true
      dhcp6: false
```

## 🔧 РЕШЕНИЕ 2: Перезапуск сети

```bash
# Поднять интерфейс
sudo ip link set ens33 up

# Запросить IP через DHCP вручную
sudo dhclient -v ens33

# Или через systemd
sudo systemctl restart systemd-networkd

# Проверить результат
ip addr show ens33
```

## 🔧 РЕШЕНИЕ 3: Проблема с VMware Tools

```bash
# Переустановить VMware Tools
sudo apt update
sudo apt install --reinstall open-vm-tools

# Или установить полный пакет
sudo apt install open-vm-tools open-vm-tools-desktop

# Перезагрузить
sudo reboot
```

## 🔧 РЕШЕНИЕ 4: Настройки VMware Workstation

### В Windows (где запущен VMware):

#### 1. Virtual Network Editor (как Administrator):

```
1. Запустите VMware Workstation
2. Edit → Virtual Network Editor
3. Нажмите "Change Settings" (требуются права админа)
4. Выберите VMnet0 (Bridged)
5. Убедитесь:
   ✓ Bridged to: Automatic (или выберите ваш сетевой адаптер)
   ✓ Connect a host virtual adapter to this network: НЕ отмечено
6. Нажмите Apply
7. Нажмите OK
```

#### 2. VM Settings:

```
1. VM → Settings
2. Hardware → Network Adapter
3. Выберите:
   ○ Bridged: Connected directly to the physical network
   ✓ Replicate physical network connection state
   ✓ Configure Adapters... → выберите ваш реальный адаптер
4. OK
```

#### 3. Проверка Windows Firewall:

```powershell
# Запустите PowerShell как Administrator

# Проверить правила для VMware
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*VMware*"}

# Разрешить VMware Bridge
New-NetFirewallRule -DisplayName "VMware Bridge" -Direction Inbound -Action Allow

# Перезапустить VMware DHCP (если используется NAT где-то еще)
Restart-Service -Name "VMware DHCP Service"
```

## 🔧 РЕШЕНИЕ 5: Статический IP (временно)

Если DHCP совсем не работает, назначьте статический IP:

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      addresses:
        - 192.168.1.100/24    # Измените на вашу подсеть!
      routes:
        - to: default
          via: 192.168.1.1     # Ваш шлюз (роутер)
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
      dhcp4: false
```

Примените:
```bash
sudo netplan apply
```

## 🔧 РЕШЕНИЕ 6: MAC адрес проблема

Иногда VMware генерирует некорректный MAC:

### В VMware:

```
1. Выключите VM
2. VM → Settings → Network Adapter
3. Advanced
4. MAC Address → Generate (сгенерировать новый)
5. OK
6. Запустить VM
```

### В Ubuntu:

```bash
# Проверить MAC
ip link show ens33 | grep link/ether

# Если MAC странный (00:00:00:...), сгенерировать новый в VMware
```

## 🔧 РЕШЕНИЕ 7: Антивирус/Firewall блокирует

### Windows:

```
1. Временно отключите Windows Defender Firewall
2. Отключите антивирус (Kaspersky, Norton, etc.)
3. Проверьте, заработало ли
4. Если да - добавьте VMware в исключения
```

### VMware Services:

```
1. Win + R → services.msc
2. Проверьте что запущены:
   - VMware Authorization Service
   - VMware DHCP Service (если используется)
   - VMware NAT Service (если используется)
   - VMware USB Arbitration Service
3. Все должны быть "Running" и "Automatic"
```

## 🔍 Полная диагностика

Выполните этот скрипт на VM:

```bash
#!/bin/bash
echo "=== CS2Panel Network Diagnostic ==="
echo ""

echo "1. Интерфейсы:"
ip link show
echo ""

echo "2. IP адреса:"
ip addr show
echo ""

echo "3. Маршруты:"
ip route show
echo ""

echo "4. Netplan конфигурация:"
cat /etc/netplan/*.yaml
echo ""

echo "5. Статус systemd-networkd:"
systemctl status systemd-networkd --no-pager
echo ""

echo "6. Статус NetworkManager:"
systemctl status NetworkManager --no-pager
echo ""

echo "7. DHCP lease:"
cat /var/lib/dhcp/dhclient.*.leases 2>/dev/null || echo "Нет lease файлов"
echo ""

echo "8. DNS:"
cat /etc/resolv.conf
echo ""

echo "9. Ping шлюза:"
GATEWAY=$(ip route | grep default | awk '{print $3}')
ping -c 3 $GATEWAY
echo ""

echo "10. Ping интернета:"
ping -c 3 8.8.8.8
```

Сохраните как `network-diag.sh`, выполните:
```bash
chmod +x network-diag.sh
./network-diag.sh
```

## ✅ Рабочая конфигурация для VMware + Ubuntu 24.04

### Файл: `/etc/netplan/00-installer-config.yaml`

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: true
      dhcp6: false
      optional: true
      dhcp-identifier: mac
      link-local: []
```

### После изменений:

```bash
# Применить конфигурацию
sudo netplan generate
sudo netplan apply

# Перезапустить сеть
sudo systemctl restart systemd-networkd

# Получить IP
sudo dhclient -v ens33

# Проверить
ip addr show ens33
ping -c 3 8.8.8.8
```

## 🎯 Быстрое решение (Most Common)

**90% случаев решается так:**

```bash
# 1. Найти интерфейс
IFACE=$(ip link | grep -v lo | grep -E "^[0-9]" | awk '{print $2}' | tr -d ':' | head -1)
echo "Интерфейс: $IFACE"

# 2. Создать конфигурацию
sudo tee /etc/netplan/00-installer-config.yaml > /dev/null << EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $IFACE:
      dhcp4: true
      dhcp6: false
EOF

# 3. Применить
sudo netplan apply

# 4. Получить IP
sudo dhclient -v $IFACE

# 5. Проверить
ip addr show $IFACE
```

## 🔴 Если ничего не помогло

### Последняя надежда:

```bash
# Переключиться на NetworkManager полностью
sudo apt install network-manager

# Удалить netplan конфигурацию
sudo rm /etc/netplan/*.yaml

# Создать минимальную конфигурацию для NetworkManager
sudo tee /etc/netplan/01-network-manager-all.yaml > /dev/null << EOF
network:
  version: 2
  renderer: NetworkManager
EOF

sudo netplan apply
sudo systemctl restart NetworkManager

# Подключиться через nmtui
sudo nmtui
```

## 📱 Нужна помощь?

Если проблема осталась, отправьте вывод:

```bash
# На VM выполните:
sudo dmesg | grep -i network > ~/network-log.txt
ip addr > ~/ip-info.txt
cat /etc/netplan/*.yaml > ~/netplan-config.txt

# Посмотрите эти файлы
cat ~/network-log.txt
cat ~/ip-info.txt
cat ~/netplan-config.txt
```

## 🎉 Типичные причины

1. ❌ **Неправильное имя интерфейса в netplan** (ens33 vs ens160)
2. ❌ **Windows Firewall блокирует VMware Bridge**
3. ❌ **VMware Tools не установлены**
4. ❌ **В VMware выбран не тот физический адаптер**
5. ❌ **MAC адрес не уникальный**
6. ❌ **DHCP сервер в сети недоступен**

---

**Попробуйте решения по порядку! Обычно помогает решение #1 или #6!**
