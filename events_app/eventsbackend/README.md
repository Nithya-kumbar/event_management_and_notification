# Events Backend — New Features

All changes are additive. Existing endpoints (`/api/events`, `/api/login`, `/api/register`,
`/api/register-event`, `/api/user-registrations`, `/api/registration-count`) are untouched
and keep working exactly as before.

## 1. File map

Drop these into your existing project at the matching package paths
(`src/main/java/com/college/eventsbackend/...`).

**New files:**
- `model/Admin.java`
- `model/AdminToken.java`
- `model/ReminderLog.java`
- `dto/AdminLoginRequest.java`
- `dto/AddRegistrationRequest.java`
- `dto/UpdateProfileRequest.java`
- `repository/AdminRepository.java`
- `repository/AdminTokenRepository.java`
- `repository/ReminderLogRepository.java`
- `service/AdminAuthService.java`
- `service/AdminRegistrationService.java`
- `service/ProfileService.java`
- `service/EmailService.java`
- `service/ReminderService.java`
- `service/ReminderInboxService.java`
- `security/AdminAuthFilter.java`
- `scheduler/ReminderScheduler.java`
- `config/SchedulingConfig.java`
- `config/FilterConfig.java`
- `config/AdminBootstrap.java`
- `controller/AdminLoginController.java`
- `controller/AdminRegistrationController.java`
- `controller/ProfileController.java`
- `controller/ReminderController.java`

**Modified files (replace existing):**
- `model/User.java` — added `phone` field + getter/setter
- `repository/RegistrationRepository.java` — added filtering/scheduling query methods

## 2. Database changes

Run `migration.sql` against your MySQL database. It only adds new tables
(`admins`, `admin_tokens`, `reminder_logs`) and one new nullable column
(`users.phone`) — nothing existing is altered or dropped.

## 3. pom.xml — add two dependencies

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-mail</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.security</groupId>
    <artifactId>spring-security-crypto</artifactId>
</dependency>
```

(`spring-security-crypto` gives you `BCryptPasswordEncoder` without pulling in
full Spring Security / its auto-configured login forms, so none of your
existing public endpoints get accidentally locked down.)

## 4. application.properties — add the block in `application.properties.additions.txt`

You need a Gmail **App Password** (not your normal password) for
`spring.mail.password`. Generate it from Google Account → Security →
2-Step Verification → App Passwords.

## 5. How admin auth works

- On startup, `AdminBootstrap` creates a default admin
  (`admin@college.edu` / `ChangeMe123!` unless overridden in properties) if
  the `admins` table is empty.
- `POST /api/admin/login` checks email + BCrypt-hashed password, and returns
  an opaque random token valid for 12 hours, stored in `admin_tokens`.
- Every request to `/api/admin/**` (except `/api/admin/login`) must include
  header `X-Admin-Token: <token>`, enforced by `AdminAuthFilter`. Invalid or
  missing tokens get a 401 with a JSON error body.
- This is intentionally simple (no full Spring Security filter chain) so it
  can't interfere with your existing `/api/events`, `/api/login`, etc.

## 6. How the reminder system works

Reminders are **email + in-app popup only** — no SMS is sent anywhere.

- `ReminderScheduler` runs every 60 seconds (`@Scheduled(fixedRate = 60000)`).
- For each event, it computes the event's start `LocalDateTime` from
  `event_date` + `event_time` (parsed flexibly — handles `"10:30 AM"`,
  `"14:00"`, etc.). Events with unparseable/missing date or time are skipped
  safely (no crash).
- It checks four windows: 1 day, 1 hour, 15 minutes, and event start
  (±2 minute tolerance so a 60-second poll doesn't miss or duplicate sends).
- For each due window, every `REGISTERED` registration for that event is
  checked against `reminder_logs` to avoid re-sending, then:
  1. an email is sent to the student's registered email via `EmailService`
  2. a row is written to `reminder_logs` with `acknowledged = false`
- This runs automatically — no frontend call needed to *trigger* it.
- The Flutter app shows the popup by **polling** `GET /api/reminders/pending`
  (e.g. on app launch, resume, or every minute while open). Each unseen
  reminder log is one popup to show. After showing it, the app should call
  `POST /api/reminders/{reminderId}/acknowledge` so it isn't shown again.

## 7. New API endpoints

### In-app reminder popups
| Method | Path | Description |
|---|---|---|
| GET | `/api/reminders/pending?userId={id}` | List of unacknowledged reminders for this student, to render as popups |
| POST | `/api/reminders/{reminderId}/acknowledge` | Mark a popup as shown/dismissed |

### Admin auth
| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/api/admin/login` | none | `{email, password}` -> `{token, ...}` |
| POST | `/api/admin/logout` | `X-Admin-Token` header | Invalidates the token |

### Admin — registration management
| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/api/admin/registrations?eventId=&userId=` | `X-Admin-Token` | View all registrations, optionally filtered by event and/or student |
| POST | `/api/admin/registrations` | `X-Admin-Token` | Body `{userId, eventId, status?}` — manually add a registration |
| DELETE | `/api/admin/registrations/{registrationId}` | `X-Admin-Token` | Remove a student's registration |

### Student profile
| Method | Path | Description |
|---|---|---|
| GET | `/api/profile?userId={id}` | View own profile |
| PUT | `/api/profile?requestingUserId={id}` | Body `{userId, name?, email?, department?, phone?}` — edit own profile. `requestingUserId` must equal the body's `userId` or the request is rejected (403) |

> Note on profile ownership check: the existing login flow has no JWT/session
> token for students — the Flutter app just receives the user's `id` back
> from `/api/login`. The "can't edit another student's profile" requirement
> is enforced by requiring the caller to pass their own id as
> `requestingUserId` and matching it against the target `userId` in the body.
> If you want this to be tamper-proof against a malicious client (not just
> protected from accidental misuse), you'll eventually want real student
> session tokens — happy to add that as a follow-up using the same
> token-filter pattern built for admin auth.

## 8. Things intentionally left alone

- `Event.java`, `TestController.java`, `RegistrationController.java`,
  `RegistrationService.java`, `LoginController.java`, `RegisterController.java`
  are unchanged.
- No existing endpoint signatures, paths, or response shapes changed.
