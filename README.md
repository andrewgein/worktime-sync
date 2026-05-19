# TimeSync

Система учёта рабочего времени. Микросервисная архитектура на Spring Boot 3 + React.

## Сервисы

 Сервис  - Порт -   Описание <br>
 `worktime-frontend` - 5173 - React / Vite UI <br>
 `api-gateway` - 8080 - Единая точка входа, JWT-фильтр, rate limiting <br>
 `auth-service` - 8081 - Аутентификация, JWT, управление пользователями <br>
 `profile-service` - 8082 - Профили сотрудников, рабочие исключения <br> 
 `notification-service` - 8085 - Email-уведомления через Kafka  <br>


## .env config:
`DB_PASSWORD`=db_password <br>
`MAIL_USERNAME`=name@gmail.com <br>
`MAIL_PASSWORD`=aaaa bbbb cccc dddd <br>


## Запуск

```bash
# Клонировать репозиторий, перейти в папку проекта
cd TimeSync

#Перед запуском остановите службы
sudo systemctl stop postgresql redis

# Запустить весь стек
docker compose up --build

# Открыть UI
open http://localhost:5173
```

Остановить:
```bash
docker compose down
```

Пересобрать с нуля (сбрасывает данные БД):
```bash
docker compose down -v && docker compose build --no-cache
```

При изменении кода в микросервисе лучше пересобирать конкретные микросервисы: например profile-service
```bash
docker compose up --build profile-service
```

## Kafka Topics

Topic, Producer , Consumer<br> 
`schedule-notifications` - auth-service - notification-service <br>
`password.reset.requested` - auth-service -notification-service <br>
`profile.events` - profile-service - пока нету <br>
`workday-exception.events` - profile-service - пока нету <br> 

