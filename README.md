# TimeSync

Система учёта рабочего времени. Микросервисная архитектура на Spring Boot  + React.

## Сервисы

 Сервис  - Порт -   Описание <br>
 `worktime-frontend` - 3000 - React UI <br>
 `api-gateway` - 8080 - Единая точка входа, JWT-фильтр, rate limiting <br>
 `auth-service` - 8081 - Аутентификация, JWT, управление пользователями <br>
 `profile-service` - 8082 - Профили сотрудников, рабочие исключения <br> 
 `notification-service` - 8085 - Email-уведомления через Kafka  <br>
`task-service`  - 8083 - Хранит таски <br>
`team-service` - 8086 — Хранит информацию о командах <br>
`conflict-service`- 8088 — Отвечает за конфликты <br>
`risk-service`- 8005 — Анализ рисков <br>


 ## Маршруты
api-gateway - ```http://api-gateway:8080```
### Публичные (без токена)
```POST /api/v1/auth/login``` -`http://auth-service:8081` <br>
```POST /api/v1/auth/refresh``` - `http://auth-service:8081` <br>
```POST /api/v1/register``` - `http://auth-service:8081` <br>

### Защищённые (требуют `Authorization: Bearer`)
```/api/v1/profiles/**``` - `http://profile-service:8082` — роли: ADMIN, EMPLOYEE, TEAM_LEAD, HR <br>
```/api/v1/teams/**```  - `http://team-service:8086` — роли: все <br>
```/api/v1/users/**```  - `http://team-service:8086` — роли: ADMIN, TEAM_LEAD <br>
```/api/v1/tasks/**```  - `http://task-service:8087` — роли: все <br>
```/api/v1/сonflicts/```  - `http://conflict-service:8088` — роли: все <br>
```/api/v1/сonflicts/**```  - `http://conflict-service:8088` — роли: все кроме EMPLOYEE <br>
```/api/v1/risk/**``` - `http://risk-service:8005` - роли: все <br>


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
open http://localhost:3000
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
