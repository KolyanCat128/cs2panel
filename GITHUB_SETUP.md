# Настройка GitHub репозитория для CS2Panel

## 🎯 Цель

Создать публичный GitHub репозиторий чтобы пользователи могли установить CS2Panel одной командой:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/cs2panel/main/scripts/install-hypervisor.sh | sudo bash
```

## 📝 Пошаговая инструкция

### Шаг 1: Инициализация Git репозитория

На вашем компьютере (в Windows):

```bash
# Откройте Git Bash или PowerShell
cd C:\Users\Галина\12345

# Инициализируйте git
git init

# Добавьте все файлы
git add .

# Создайте первый коммит
git commit -m "Initial commit: CS2Panel v1.0.0

- Backend (Java Spring Boot)
- Hypervisor daemon (Go)
- Kubernetes manifests
- Installation scripts
- Documentation"
```

### Шаг 2: Создайте GitHub репозиторий

1. **Зайдите на GitHub.com**
   - Войдите в свой аккаунт
   - Нажмите "+" в правом верхнем углу
   - Выберите "New repository"

2. **Настройте репозиторий:**
   - **Repository name:** `cs2panel`
   - **Description:** "Modern infrastructure management platform with KVM virtualization, CS2 game servers, and Kubernetes integration"
   - **Visibility:** ✅ Public (чтобы можно было скачивать скрипт)
   - **❌ НЕ** ставьте галочки на:
     - Initialize with README (у нас уже есть)
     - Add .gitignore (у нас уже есть)
     - Choose a license (добавим позже)

3. **Нажмите "Create repository"**

### Шаг 3: Привяжите локальный репозиторий к GitHub

GitHub покажет инструкции. Используйте команды для существующего репозитория:

```bash
# В Git Bash / PowerShell в C:\Users\Галина\12345

# Добавьте remote (ЗАМЕНИТЕ YOUR_USERNAME на ваш GitHub username!)
git remote add origin https://github.com/YOUR_USERNAME/cs2panel.git

# Переименуйте ветку в main
git branch -M main

# Отправьте код на GitHub
git push -u origin main
```

**Если попросит авторизацию:**
- Username: ваш GitHub username
- Password: используйте **Personal Access Token** (не обычный пароль!)

### Шаг 4: Создайте Personal Access Token (если нужно)

1. GitHub.com → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. "Generate new token (classic)"
3. Название: `cs2panel-push`
4. Права: ✅ `repo` (full control)
5. Generate token
6. **Скопируйте токен** (показывается только один раз!)
7. Используйте его вместо пароля при `git push`

### Шаг 5: Проверьте что всё загрузилось

Зайдите на:
```
https://github.com/YOUR_USERNAME/cs2panel
```

Должны видеть:
- ✅ README.md
- ✅ backend/
- ✅ hypervisor/
- ✅ scripts/
- ✅ docs/
- ✅ k8s/
- ✅ и т.д.

### Шаг 6: Проверьте скрипт установки

Откройте в браузере:
```
https://raw.githubusercontent.com/YOUR_USERNAME/cs2panel/main/scripts/install-hypervisor.sh
```

Должен показать содержимое скрипта (не HTML страницу!)

## ✅ Готово! Теперь можно устанавливать одной командой:

```bash
# На Ubuntu 24.04
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/cs2panel/main/scripts/install-hypervisor.sh | sudo bash
```

ИЛИ безопаснее (сначала скачать, проверить, потом запустить):

```bash
# Скачать
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/cs2panel/main/scripts/install-hypervisor.sh -o install.sh

# Проверить содержимое
cat install.sh

# Запустить
chmod +x install.sh
sudo ./install.sh
```

## 📦 Что скачивается откуда

### ✅ Из официальных репозиториев Ubuntu (через apt-get):

Эти пакеты скачиваются из `archive.ubuntu.com` и безопасны:

- `qemu-kvm` - виртуализация
- `libvirt-daemon-system` - управление VM
- `openssh-server` - SSH
- `curl`, `wget`, `vim`, `htop` - утилиты
- `lm-sensors`, `smartmontools`, `nvme-cli` - мониторинг
- И другие системные пакеты

### ✅ Из вашего GitHub репозитория:

- `install-hypervisor.sh` - скрипт установки
- (опционально) `hypervisor-daemon` - если добавите pre-built бинарник

### ⚠️ Hypervisor Daemon

Сейчас скрипт:
1. Пытается найти локальный бинарник в `../hypervisor/bin/hypervisor-daemon`
2. Если не находит - создаёт **заглушку** (stub)

**Варианты решения:**

#### Вариант 1: Pre-built бинарник в GitHub (проще для пользователей)

```bash
# На вашем компьютере скомпилируйте для Linux
cd hypervisor

# Для Linux AMD64
GOOS=linux GOARCH=amd64 go build -o bin/hypervisor-daemon-linux-amd64 .

# Добавьте в git
git add bin/hypervisor-daemon-linux-amd64
git commit -m "Add pre-built hypervisor daemon for Linux AMD64"
git push
```

Обновите `.gitignore`:
```bash
# Исключите general bin, но разрешите pre-built
!hypervisor/bin/hypervisor-daemon-linux-amd64
```

#### Вариант 2: Компиляция на Ubuntu (безопаснее)

Пользователь сам компилирует:
```bash
# После установки
cd ~/cs2panel/hypervisor
go build -o bin/hypervisor-daemon .
sudo cp bin/hypervisor-daemon /usr/local/bin/
sudo systemctl restart cs2panel-hypervisor
```

#### Вариант 3: GitHub Releases (самый профессиональный)

1. Создайте Release на GitHub
2. Прикрепите бинарники для разных платформ
3. Скрипт скачивает из Releases:

```bash
RELEASE_URL="https://github.com/YOUR_USERNAME/cs2panel/releases/download/v1.0.0/hypervisor-daemon-linux-amd64"
curl -fsSL $RELEASE_URL -o /usr/local/bin/hypervisor-daemon
chmod +x /usr/local/bin/hypervisor-daemon
```

## 🔄 Обновления

### Как обновлять код:

```bash
# Внесите изменения в файлы
# Затем:

git add .
git commit -m "Описание изменений"
git push
```

### Создание релиза:

1. GitHub → Releases → "Create a new release"
2. Tag: `v1.0.0`
3. Title: `CS2Panel v1.0.0`
4. Description: опишите что нового
5. Прикрепите бинарники (если есть)
6. "Publish release"

## 🔐 Безопасность

### Что НЕ загружать на GitHub:

❌ **Секреты и пароли:**
- `.env` файлы с реальными данными
- `credentials.json`
- SSH ключи (`.pem`, `.key`)
- API токены
- Database credentials

✅ **Что МОЖНО:**
- `.env.example` - шаблоны без реальных данных
- Код
- Документация
- Скрипты
- Конфигурационные файлы (без секретов)

### Проверка перед push:

```bash
# Проверьте что будет отправлено
git status

# Проверьте что .gitignore работает
git check-ignore -v **/*
```

## 📊 Структура для GitHub

Рекомендуемые файлы в корне репозитория:

```
cs2panel/
├── README.md              ← Главная страница (уже есть)
├── LICENSE                ← Лицензия (создайте)
├── CONTRIBUTING.md        ← Как контрибьютить
├── CHANGELOG.md           ← История версий
├── SECURITY.md            ← Security policy
├── .gitignore            ← Что не загружать (уже есть)
├── .env.example          ← Пример env файла
└── CODE_OF_CONDUCT.md    ← Кодекс поведения
```

### Создайте LICENSE (MIT):

```bash
# Создайте файл LICENSE с содержимым:
```

```
MIT License

Copyright (c) 2025 YOUR_NAME

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 🎨 Улучшение README на GitHub

GitHub автоматически покажет badges если добавите в README.md:

```markdown
![GitHub stars](https://img.shields.io/github/stars/YOUR_USERNAME/cs2panel?style=social)
![GitHub forks](https://img.shields.io/github/forks/YOUR_USERNAME/cs2panel?style=social)
![GitHub issues](https://img.shields.io/github/issues/YOUR_USERNAME/cs2panel)
![License](https://img.shields.io/github/license/YOUR_USERNAME/cs2panel)
```

## 🚀 Продвижение

После создания репозитория:

1. **GitHub Topics** - добавьте теги:
   - `kvm` `virtualization` `hypervisor`
   - `cs2` `game-server` `counter-strike`
   - `kubernetes` `k8s` `cloud-native`
   - `go` `golang` `java` `spring-boot`
   - `infrastructure` `devops`

2. **Social Preview** - добавьте красивую картинку:
   - Settings → Social preview → Upload image
   - Размер: 1280x640 px

3. **GitHub Pages** (опционально) - документация:
   - Settings → Pages
   - Source: `main` branch, `/docs` folder
   - Получите сайт: `https://YOUR_USERNAME.github.io/cs2panel/`

## ✅ Чек-лист перед публикацией

- [ ] `.gitignore` настроен (без секретов)
- [ ] README.md заполнен
- [ ] LICENSE добавлена
- [ ] Скрипт `install-hypervisor.sh` работает
- [ ] Документация актуальна
- [ ] Нет секретов в коде
- [ ] Код прокомментирован
- [ ] Все файлы на месте

## 🎉 Готово!

Теперь у вас есть публичный GitHub репозиторий!

**Пользователи смогут установить одной командой:**

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/cs2panel/main/scripts/install-hypervisor.sh | sudo bash
```

---

**Нужна помощь?** Пишите issue на GitHub или мне!
