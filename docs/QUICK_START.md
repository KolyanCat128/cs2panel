# CS2Panel Hypervisor - Быстрый старт

## 🚀 За 3 минуты

### Вариант 1: Если скрипт уже на Ubuntu VM

```bash
cd ~/cs2panel/scripts
chmod +x install-hypervisor.sh
sudo ./install-hypervisor.sh
```

### Вариант 2: Копирование с Windows на Ubuntu VM

#### Способ 1: Через общую папку VMware

1. В VMware Workstation:
   - VM → Settings → Options → Shared Folders
   - Включите "Always enabled"
   - Добавьте папку: `C:\Users\Галина\12345`

2. На Ubuntu VM:
   ```bash
   # Установите VMware tools если нужно
   sudo apt-get install -y open-vm-tools

   # Скопируйте скрипт
   mkdir -p ~/cs2panel
   cp /mnt/hgfs/12345/scripts/install-hypervisor.sh ~/cs2panel/
   chmod +x ~/cs2panel/install-hypervisor.sh
   ```

#### Способ 2: Через SCP (если SSH настроен)

На Windows (PowerShell или Git Bash):
```bash
scp C:\Users\Галина\12345\scripts\install-hypervisor.sh user@ubuntu-vm-ip:~/
```

На Ubuntu VM:
```bash
chmod +x ~/install-hypervisor.sh
sudo ./install-hypervisor.sh
```

#### Способ 3: Вручную (копировать-вставить)

На Ubuntu VM:
```bash
# Создайте файл
nano ~/install-hypervisor.sh

# Вставьте содержимое скрипта (правая кнопка мыши в терминале)
# Сохраните: Ctrl+O, Enter, Ctrl+X

# Сделайте исполняемым
chmod +x ~/install-hypervisor.sh

# Запустите
sudo ./install-hypervisor.sh
```

## ⚡ Самый простой способ (для вашего случая)

Так как у вас Ubuntu уже установлена в VMware, используйте этот метод:

### Шаг 1: Настройте сеть в Ubuntu

```bash
# Проверьте сеть
ip addr

# Если нет IP, настройте через Netplan
sudo nano /etc/netplan/01-netcfg.yaml
```

Вставьте (для DHCP):
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:  # может быть другое имя!
      dhcp4: true
```

Примените:
```bash
sudo netplan apply
```

Проверьте:
```bash
ip addr
# Должен появиться IP адрес
```

### Шаг 2: Скопируйте скрипт

Самый простой способ - создать прямо на Ubuntu:

```bash
# Создайте файл
cat > ~/install-hypervisor.sh << 'SCRIPT_END'
#!/bin/bash
# ... вставьте сюда содержимое скрипта ...
SCRIPT_END

chmod +x ~/install-hypervisor.sh
```

**ИЛИ** если у вас есть интернет на VM:

```bash
# Загрузите с GitHub (когда загрузите туда)
# wget https://raw.githubusercontent.com/YOUR_REPO/main/scripts/install-hypervisor.sh
# chmod +x install-hypervisor.sh
```

### Шаг 3: Запустите установку

```bash
sudo ./install-hypervisor.sh
```

### Шаг 4: Дождитесь завершения (10-30 минут)

Скрипт покажет прогресс:
- ✅ Проверки системы
- ✅ Установка пакетов
- ✅ Настройка сервисов
- ✅ Оптимизация

### Шаг 5: Перезагрузите

```bash
sudo reboot
```

### Шаг 6: Проверьте

После перезагрузки:

```bash
# Войдите под cs2admin
su - cs2admin
# Пароль: cs2panel

# Проверьте статус
systemctl status cs2panel-hypervisor

# Проверьте API
curl http://localhost:8080/v1/health

# Проверьте виртуализацию
virsh list --all
```

## 🎯 Что делать если...

### Нет интернета на VM (нет сети)

#### В VMware Workstation:

1. **Попробуйте NAT вместо Bridged:**
   - Выключите VM: `sudo poweroff`
   - В VMware: VM → Settings → Network Adapter
   - Выберите: NAT
   - Запустите VM
   - Проверьте: `ip addr`

2. **Проверьте Virtual Network Editor (от имени админа):**
   - Edit → Virtual Network Editor
   - Change Settings (права админа!)
   - Restore Defaults
   - OK
   - Перезапустите VM

### Не можете скопировать скрипт

Используйте метод "вручную":

```bash
# На Ubuntu создайте файл
nano ~/install.sh

# Скопируйте ВЕСЬ скрипт из Windows (Ctrl+C)
# Вставьте в терминал Ubuntu (правая кнопка мыши или Shift+Insert)
# Сохраните: Ctrl+O, Enter, Ctrl+X

chmod +x ~/install.sh
sudo ./install.sh
```

### Скрипт выдает ошибку

```bash
# Проверьте права
ls -la install-hypervisor.sh

# Проверьте sudo
sudo -v

# Запустите с подробным выводом
sudo bash -x ./install-hypervisor.sh
```

## 📋 Чек-лист перед установкой

- [ ] Ubuntu 24.04 установлена
- [ ] Минимум 10GB свободного места (`df -h`)
- [ ] Минимум 4GB RAM (`free -h`)
- [ ] Виртуализация включена в BIOS VM
- [ ] Есть права sudo/root
- [ ] Сеть настроена (хотя бы локально)

## 🎓 Полезные команды Ubuntu

```bash
# Проверить версию Ubuntu
lsb_release -a

# Проверить IP
ip addr

# Проверить диски
df -h

# Проверить RAM
free -h

# Проверить CPU
lscpu

# Обновить систему
sudo apt-get update
sudo apt-get upgrade -y

# Проверить sudo
sudo -v

# Посмотреть логи установки
tail -f /var/log/syslog
```

## 💡 После установки

### Смените пароль!

```bash
# Для cs2admin
passwd

# Для вашего основного пользователя
sudo passwd your_username
```

### Проверьте все сервисы

```bash
# CS2Panel
systemctl status cs2panel-hypervisor

# libvirt
systemctl status libvirtd

# SSH
systemctl status ssh
```

### Протестируйте API

```bash
# Health check
curl http://localhost:8080/v1/health

# Если работает, увидите JSON ответ
```

### Создайте первую VM (опционально)

```bash
# Скачайте ISO (например, Ubuntu Server)
cd /var/lib/libvirt/images
sudo wget https://releases.ubuntu.com/24.04/ubuntu-24.04-live-server-amd64.iso

# Создайте VM через virt-install
sudo virt-install \
  --name test-vm \
  --ram 2048 \
  --vcpus 2 \
  --disk path=/var/lib/libvirt/images/test-vm.qcow2,size=10 \
  --cdrom /var/lib/libvirt/images/ubuntu-24.04-live-server-amd64.iso \
  --network network=default \
  --graphics vnc,listen=0.0.0.0 \
  --noautoconsole

# Проверьте статус
virsh list --all
```

## 📞 Нужна помощь?

Если что-то не работает:

1. Проверьте логи:
   ```bash
   journalctl -u cs2panel-hypervisor -n 100
   ```

2. Проверьте лог установки:
   ```bash
   cat /var/lib/cs2panel/install.log
   ```

3. Откройте issue на GitHub

---

**Удачи! Если возникнут вопросы - пишите! 🎉**
