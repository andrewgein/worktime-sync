# WorkTime-Sync
Система управления командами, расписаниями и рисками перегрузки сотрудников. Архитектура построена на микросервисах с использованием event-driven подхода через Apache Kafka.
##  Архитектура
<img width="1535" height="910" alt="изображение" src="https://github.com/user-attachments/assets/4c55846c-47ff-4546-8a62-eb85096cbb5e" />

##  Стек технологий

### Бэкенд
*   **Java 21**
*   **Spring Framework**
*   **Apache Kafka** (для асинхронного взаимодействия)
*   **PostgreSQL** (основное хранилище данных)
*   **Docker** (контейнеризация)
*   **Redis** (кэширование и балансировка нагрузки gateway)

### Фронтенд
*   **JavaScript**
*   **React (Vite)**
*   **Tailwind CSS**

### ML / LLM Интеграция (Risk Service)
*   **Python 3.13**
*   **FastAPI**
*   **Scikit-learn**
*   **Numpy**
*   **Joblib**
*   **Qwen 2.5** (LLM для анализа и рекомендаций)

### Тестирование
*   **JUnit**
*   **Mockito**

##  Архитектура и Сервисы
Система состоит из микросервисов, взаимодействующих через API Gateway и шину событий Kafka.

### Frontend
*   **Worktime-frontend:3000**: Визуальная состовляющая проекта.

### Микросервисы
*   **API Gateway:8080**: Точка входа и маршрутизации запросов.
*   **Auth Service:8081**: Отвечает за аутентификацию и регистрацию пользователей.
*   **Profile Service:8082**: Управляет профилями сотрудников, общей информацией и графиками работы.
*   **Task service (Calendar Service):8083**: Синхронизирует календарные события сотрудников, импортирует данные из внешних источников и приводит их к единому формату.
*   **Team Service:8086**: Хранит команды пользователей. При регистрации нового пользователя (через Auth Service) автоматически создается запись о новом сотруднике.
*   **Conflict Service:8088**: Сервис обнаружения конфликтов. Принимает данные о графиках и календарных событиях, обнаруживает наложения и конфликты.
*   **Risk Service:8005**: Считает метрики перегрузки и риски выгорания. На выходе показывает **Risk Score (0-10)** и генерирует рекомендации (использует ML/LLM).
*   **Notification Service:8085**: Формирует и отправляет уведомления сотрудникам, чей график требует подтверждения или обновления.

### Kafka Topics

*   **password.reset.requested** (`auth-service` → `notification-service`) - Запрос сброса пароля
*   **email.verification.requested** (`auth-service` → `notification-service`) - Подтверждение email
*   **user.created** (`auth-service` → `team-service`) - Регистрация пользователя
*   **calendar.reminder** (`task-service` → `notification-service`) - Напоминание о событии
*   **calendar.created/updated/deleted** (`task-service` → `notification-service`, `conflict-service`) - Изменения календаря
*   **profile.created/updated/deleted** (`profile-service` → `conflict-service`) - Изменения профиля
*   **workday-exception.created** (`profile-service` → `conflict-service`) - Создание исключения
*   **workday-exception.deleted** (`profile-service` → `conflict-service`) - Удаление исключения
*   **conflict.detected** (`conflict-service` → `notification-service`) - Обнаружен конфликт

##  Хранилища данных
Данные распределены по базе данных PostgreSQL в зависимости от домена:
*   `users` — Пользователи
*   `profiles` — Профили
*   `teams` — Команды
*   `events` — События
*   `conflicts` — Конфликты

**Redis** используется для хранения данных о нагрузке на Gateway.

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

## Запуск

```bash
# Перейдите(создайте) в папку проекта
mkdir TimeSync
cd TimeSync

#Клонируйте репозиторий
git clone --recurse-submodules https://github.com/andrewgein/worktime-sync

#Обновите submodules
git submodule update --remote --recursive

#Перед запуском остановите службы
sudo systemctl stop postgresql redis

#Создайте в корневой папке .env файл на основе .env.example
```
`DB_PASSWORD`=db_password <br>
`MAIL_USERNAME`=name@gmail.com <br>
`MAIL_PASSWORD`=aaaa bbbb cccc dddd <br>
```

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
