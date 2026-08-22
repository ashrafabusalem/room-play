# Deploying to CyberPanel

CyberPanel is OpenLiteSpeed plus a control panel. Laravel runs on it well, but
four things differ from a normal LAMP deploy and each one fails in a way that
looks like something else. They are marked **TRAP** below.

Replace `api.example.com` with your actual API hostname throughout.

---

## 1. Create the site

CyberPanel → **Websites → Create Website**.

- Domain: `api.example.com`
- PHP: **8.2 or newer**. Laravel 12 requires `^8.2` and will refuse to install
  otherwise. If the dropdown has nothing recent, install it first:
  `sudo yum install lsphp83 lsphp83-common lsphp83-mysqlnd lsphp83-process lsphp83-pdo`
  (`apt install` on Ubuntu).

Then issue SSL: **SSL → Manage SSL → Issue**. Do this before pointing the app at
it — the whole reason the API is HTTPS is so the app can drop its cleartext
exemption.

---

## 2. TRAP — the document root

CyberPanel points the site at `/home/api.example.com/public_html`. Laravel must
be served from its `public/` directory. Anything else exposes `.env`, your
database credentials and your `APP_KEY` to the open internet, on a URL anyone
can guess.

Fix it in **Websites → List Websites → Manage → vHost Conf**:

```
docRoot                   $VH_ROOT/public_html/public
```

Verify afterwards by requesting `https://api.example.com/.env` — it must return
404, not a file.

---

## 3. Put the code on the server

```bash
cd /home/api.example.com
rm -rf public_html && git clone <your-repo> public_html
cd public_html

# Use the site's PHP, not the system one — see the trap below.
/usr/local/lsws/lsphp83/bin/php /usr/local/bin/composer install \
  --no-dev --optimize-autoloader

cp .env.production.example .env
/usr/local/lsws/lsphp83/bin/php artisan key:generate
```

### TRAP — two different PHP binaries

The system `php` on a CyberPanel box is usually an older build than the `lsphp`
serving the site. Running `composer install` or `artisan migrate` with the wrong
one produces a working-looking deploy that fails at runtime with missing
extensions or syntax errors from newer language features.

Check both and use the lsphp path everywhere:

```bash
php -v                                  # system
/usr/local/lsws/lsphp83/bin/php -v      # the one that matters
```

### Permissions

```bash
chown -R api.example.com:api.example.com /home/api.example.com/public_html
chmod -R 775 storage bootstrap/cache
```

`storage` not being writable is the single most common Laravel-on-CyberPanel
symptom: a blank 500 with nothing in the browser and the reason sitting in a log
file the app could not create.

---

## 4. Database

CyberPanel → **Databases → Create Database**. Then fill in `.env`, and:

```bash
/usr/local/lsws/lsphp83/bin/php artisan migrate --force
```

`--force` is required — Laravel refuses to migrate in production without it.

---

## 5. TRAP — Reverb needs a process *and* a proxy

Two separate pieces, and missing either one leaves the REST API working while
rooms silently never update.

### The process

```bash
sudo cp deploy/roomplay-reverb.conf /etc/supervisord.d/roomplay-reverb.ini
sudo cp deploy/roomplay-queue.conf  /etc/supervisord.d/roomplay-queue.ini
# replace REPLACE_DOMAIN and REPLACE_SITE_USER in both first
sudo supervisorctl reread && sudo supervisorctl update
sudo supervisorctl status
```

Reverb binds to `127.0.0.1:8080` only. It must not be reachable directly from
the internet — that would serve unencrypted `ws://` beside your `wss://` and
leak bearer tokens.

### The proxy

OpenLiteSpeed has a dedicated feature for this. It is **not** the same as a
normal reverse proxy and a standard proxy rule will not upgrade the connection.

**vHost Conf → Web Socket Proxy → Add**:

| Field | Value |
|---|---|
| URI | `/app` |
| Address | `127.0.0.1:8080` |

Reverb serves WebSocket connections under `/app/{key}`. Its HTTP publishing
endpoint `/apps/{id}/events` is called by Laravel on the same machine, so it
needs no proxy — leave it on loopback.

Then graceful-restart OpenLiteSpeed.

### Confirm it actually upgraded

```bash
curl -i -N -H "Connection: Upgrade" -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Version: 13" -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
  https://api.example.com/app/YOUR_REVERB_KEY
```

`101 Switching Protocols` means the proxy is right. A `200` with HTML means the
request never reached Reverb.

---

## 6. Point the app at it

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com
```

Once the API is HTTPS, delete
`android/app/src/main/res/xml/network_security_config.xml` and its
`android:networkSecurityConfig` line in `AndroidManifest.xml`. That file exists
only to permit plain HTTP to local development addresses; shipping it to
production keeps an exemption you no longer need.

---

## 7. Every deploy after the first

```bash
cd /home/api.example.com/public_html
git pull
/usr/local/lsws/lsphp83/bin/php /usr/local/bin/composer install --no-dev --optimize-autoloader
/usr/local/lsws/lsphp83/bin/php artisan migrate --force
/usr/local/lsws/lsphp83/bin/php artisan config:cache
/usr/local/lsws/lsphp83/bin/php artisan route:cache
/usr/local/lsws/lsphp83/bin/php artisan queue:restart
sudo supervisorctl restart roomplay-reverb
```

### TRAP — cached config and long-running workers

`config:cache` makes Laravel ignore `.env` entirely and read the cached file. A
`.env` change with no `config:cache` afterwards appears to do nothing.

Queue workers and Reverb hold the old code in memory until restarted. Deploying
without the last two lines leaves them running the previous release — including
the previous database schema expectations.

---

## Before real users

- `APP_DEBUG=false`. With it on, any error page prints your environment
  variables — database password, `APP_KEY`, mail credentials — to whoever
  triggered it.
- Real SMTP. Password resets go nowhere on the `log` mailer.
- Automated database backups. CyberPanel has them; they are off by default.
- Set `SANCTUM_STATEFUL_DOMAINS` only if a browser client is added later. A
  phone app uses bearer tokens and does not need it.
