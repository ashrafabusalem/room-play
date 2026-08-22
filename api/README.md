# Room Play API

Laravel backend for the **Room Play** Flutter app (`../room_play`).

**Current state: auth works.** Laravel 12 with Sanctum token auth — register,
login, logout, current user and password reset are built and tested. No rooms,
coins or games yet.

---

## Run it

```bash
php artisan serve          # REST API on http://127.0.0.1:8000
php artisan reverb:start   # WebSocket server on ws://127.0.0.1:8080
```

Both are needed. They are separate processes — see the deployment note below.

Database is SQLite (`database/database.sqlite`) for development. Swap to MySQL
in `.env` before anything real; XAMPP already has MySQL if you want it locally.

---

## What's installed

| Piece | Purpose |
|---|---|
| Laravel 12.67 | Framework |
| Sanctum | Token auth for the Flutter app (`php artisan install:api`) |
| Reverb | WebSocket server for rooms, presence and chat |

Reverb's app id, key and secret were generated into `.env` on install. The key
is public (the app needs it); **the secret is not** — it never ships in the app.

---

## Endpoints

| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST | `/api/register` | — | Create an account, return a token |
| POST | `/api/login` | — | Exchange credentials for a token |
| POST | `/api/forgot-password` | — | Email a reset link |
| GET | `/api/me` | Bearer | The signed-in user |
| POST | `/api/logout` | Bearer | Revoke the calling token |

Every response that carries a user uses the same shape, so the client never has
to special-case one endpoint:

```json
{ "token": "3|abc…", "user": { "id": "567185", "name": "Alex", "email": "alex@example.com", "level": 1 } }
```

`id` is the public six-digit id shown in the app, not the primary key.

Try it:

```bash
php artisan serve
curl -X POST http://127.0.0.1:8000/api/register \
  -H "Content-Type: application/json" -H "Accept: application/json" \
  -d '{"name":"Alex","email":"alex@example.com","password":"correct-horse","device_name":"Pixel 8"}'
```

Reset emails go to `storage/logs/laravel.log` in development (`MAIL_MAILER=log`).

### Decisions baked into these endpoints

- **A wrong password and an unknown email answer identically.** Any difference
  turns login into a way to discover which addresses are registered. There is a
  test asserting the two responses match.
- **`forgot-password` always reports success**, for the same reason, and has no
  `exists:users` rule.
- **Login is rate limited per email + IP**, five attempts. Email alone would let
  anyone lock a victim out of their own account; IP alone would let one attacker
  spray many accounts.
- **Logout revokes only the calling token**, so signing out on a phone does not
  sign the user out on their tablet.
- **`level` and `public_id` are not fillable.** A client that posts them is
  ignored — there is a test for that too.
- **No password composition rules**, only a length minimum matching the app.
  Requiring a symbol and a digit pushes people toward predictable
  substitutions.

### Tests

```bash
php artisan test --filter=AuthTest    # 17 tests
```

PHPUnit, not Pest — `composer.json` mentions `pestphp/pest-plugin` only in the
plugin allow-list, and Pest itself is not installed.

---

## Verified on this machine

- PHP 8.2.12 (XAMPP), all extensions Laravel needs present; `sodium` was
  disabled in `php.ini` and has been enabled.
- Composer 2.10.2 installed to `C:\xampp\php` as `composer.phar` + `composer.bat`.
- **Reverb runs on Windows.** It does not require `ext-pcntl` (which does not
  exist on Windows) — it is pure PHP on ReactPHP. Confirmed by connecting to
  `ws://127.0.0.1:8080/app/<key>` and receiving `pusher:connection_established`.

---

## Deployment note, worth knowing now

`reverb:start` is a **long-running daemon**, not a web request. Shared hosting
and cPanel cannot run it — this is the main departure from deploying a
WordPress site.

Production needs:

- a VPS (or Laravel Cloud / Forge),
- a supervisor keeping `reverb:start` alive across crashes and reboots,
- a reverse proxy terminating TLS so the app can reach `wss://`.

---

## Next

The server half of Phase 1 is done. What remains:

1. **Point the app at it.** `features/auth/auth_controller.dart` in the Flutter
   project fakes these four calls; each carries a `// SERVER:` comment naming
   the endpoint that replaces it. The response shapes already match.
2. **Decide the base URL.** An Android emulator reaches the host machine at
   `http://10.0.2.2:8000`, not `127.0.0.1`. A physical phone needs this
   machine's LAN address and the firewall opened on port 8000.
3. **Email delivery**, before anyone outside development can reset a password.

Then Phase 2: rooms, seats and presence over Reverb.

The full phased plan lives in the build-plan artifact.
