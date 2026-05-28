# Деплой TymeSinc на 'your_domain'

## Архитектура

```
Браузер - 'your_domain' (443 HTTPS) -  Router VM (nginx + SSL Certbot) -  'your_ip' (nginx на worktime VM)
      -/api/** -> localhost:8080 (api-gateway)
      - /       -? localhost:3000 (frontend)
```


## 1. Router VM — SSL и nginx

### Получить SSL сертификат через Certbot
```bash
sudo certbot certonly --nginx -d worktime-sync.ru -d www.worktime-sync.ru
```

### Добавить конфиг nginx
```bash
sudo cp nginx.router.conf /etc/nginx/conf.d/worktime-sync.conf
sudo nginx -t && sudo systemctl reload nginx
```


## 2. Worktime VM ('your_ip') — подготовка

### Установить зависимости
```bash
sudo apt update
sudo apt install -y nginx docker.io docker-compose-plugin
sudo systemctl enable nginx docker
sudo usermod -aG docker $USER
```

### Настроить nginx
```bash
sudo cp deploy/nginx.vm.conf /etc/nginx/conf.d/worktime-sync.conf
sudo nginx -t && sudo systemctl reload nginx
```


## 3. Worktime VM — запуск проекта

### Клонировать репозиторий (ветка deploy)
```bash
git clone --recurse-submodules -b deploy <repo-url>
cd worktime-sync
```

### Создать .env файл
```bash
cp .env.example .env
nano .env
```

Заполнить:
```
DB_PASSWORD=your_secure_password
MAIL_USERNAME=name@gmail.com
MAIL_PASSWORD=aaaa bbbb cccc dddd
```

### Сгенерировать RSA ключи для JWT
```bash
mkdir -p secrets
openssl genrsa -out secrets/private.pem 2048
openssl rsa -in secrets/private.pem -pubout -out secrets/public.pem
```

### Запустить
```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

---

## 4. Проверка

```bash
# Все контейнеры должны быть Up
docker compose ps

# Проверить gateway
curl http://localhost:8080/api/v1/auth/login -X POST

# Проверить frontend
curl http://localhost:3000
```

Из браузера:
- `https://worktime-sync.ru` → открывается frontend
- `https://worktime-sync.ru/api/v1/auth/login` → ответ от gateway

---

## 5. Обновление проекта

```bash
git pull --recurse-submodules
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```
