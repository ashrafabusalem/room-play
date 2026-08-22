# Room Play

Flutter app for Android and iOS. Voice/text chat rooms with social games —
the same shape as TopTop.

**Current state: UI shell.** Every screen from the mockup renders and navigates,
driven by mock data. There is no backend, no voice, no game logic yet.

---

## Run it

```bash
flutter pub get
flutter run                 # attached device or emulator
flutter build apk --release # build/app/outputs/flutter-apk/app-release.apk
```

Tests and visual review:

```bash
flutter test                                        # widget tests
flutter test test/screenshots.dart --update-goldens # re-render test/goldens/*.png
```

`test/screenshots.dart` deliberately does not end in `_test.dart`, so a plain
`flutter test` skips it — otherwise every intentional layout change would fail
the suite as a golden mismatch. It loads the real Inter, Material-icon and
emoji faces and precaches asset images before capturing; without both, glyphs
render as boxes and every `Image` comes out blank.

---

## What's built

| Screen | Source | Notes |
|---|---|---|
| Login / Signup / Reset | `features/auth/` | **Not in the mockup** — designed to match. Email + password |
| Home | `features/home/` | Hero carousel, categories, game rail, room list |
| Room | `features/rooms/room_screen.dart` | 9 seats, host crown, mute state, live chat, control bar |
| Games | `features/games/` | Catalogue with working category filters |
| Create | `features/create/` | Modal sheet: create room, go live, quick start |
| Messages | `features/messages/` | Conversation list |
| Rooms tab | `features/rooms/rooms_screen.dart` | **Not in the mockup** — built to match |
| Profile | `features/profile/` | **Not in the mockup** — built to match |

Working interactions: bottom-nav switching, open a room, send a chat message,
toggle mic (updates the seat badge), filter the game catalogue, follow/unfollow.

## What's mock

`data/mock_data.dart` holds every user, room, game, and message. It is the only
file that knows about fake data — swap it for a real repository with the same
method signatures and no screen needs to change.

**Auth is no longer mock.** `features/auth/auth_controller.dart` talks to the
real Laravel API in `../roomplay-api` — register, login, logout and password
reset. The token is stored in `SharedPreferences`; the password never is.

---

## Talking to the API

`core/api/` holds the client. `ApiClient` turns every outcome — success,
validation failure, expired token, dead network, an HTML error page — into
either a decoded map or an `ApiException`. Screens catch that and show
`error.localized(l10n)`.

### Base URL

Set at build time, because the address that reaches the host machine is
different on every platform and guessing wrong looks exactly like the server
being down:

```bash
flutter run                                                   # emulator: 10.0.2.2:8000
flutter run --dart-define=API_BASE_URL=http://192.168.0.104:8000   # physical phone
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com
```

Defaults live in `core/api/api_config.dart`.

### Testing against a real phone

Three things have to line up, and each fails the same silent way:

1. **Serve on all interfaces**, not just loopback:
   `php artisan serve --host=0.0.0.0 --port=8000`
2. **Open port 8000** in Windows Firewall for the private network. Needs admin:
   ```powershell
   New-NetFirewallRule -DisplayName "Laravel dev" -Direction Inbound `
     -Action Allow -Protocol TCP -LocalPort 8000 -Profile Private
   ```
3. **Cleartext HTTP.** Android 9+ blocks it by default and gives no error worth
   reading. `android/app/src/main/res/xml/network_security_config.xml` allows it
   for `10.0.2.2`, `localhost` and `192.168.0.104` only — not a blanket
   `usesCleartextTraffic`, which would permit plaintext to any host.
   **Delete that file and its manifest reference once the API is HTTPS.**

### Rules the client holds up

- Store the **token**, never the password.
- `Accept: application/json` on every request — without it Laravel answers
  validation failures with an HTML redirect and the app sees an unparseable
  body.
- `Accept-Language` is sent, so server messages localise as soon as Laravel
  carries translations. Until then those specific strings arrive in English.
- **Sign-out clears the session even if the network call fails.** The user asked
  to leave; refusing because the server is unreachable would trap them.

Avatars and game icons are generated (initials on a gradient, emoji on a
gradient). **Real artwork is needed before launch.**

---

## Branding

Source logo: `Desktop/Room play/roomplaylogo.png` (1254x1254, opaque, black
surround). Everything below is derived from it — re-run the steps if it changes.

| Output | Purpose |
|---|---|
| `icon/icon.png` | 1024px square, badge at 92% on black. Legacy Android + iOS + web icon |
| `icon/icon_foreground.png` | 1024px, circle-clipped badge on transparency. Android adaptive foreground |
| `assets/brand/logo.png` | 512px, transparent outside the ring. Splash + in-app header mark |

Regenerate the platform assets after replacing those files:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Two things to know if you redo the source crops:

- The badge is located by detecting **gold-rim pixels**, not the outer glow, so
  the crop hugs the ring rather than the halo.
- `flutter_launcher_icons` wraps the adaptive foreground in
  `<inset android:inset="16%">`. Do **not** also pre-shrink the badge to the
  66% safe zone — the two compound and leave a tiny badge floating in a black
  ring. The foreground fills 92% of its canvas and lets the generated inset do
  the work.

App display name is `Room Play` (`android:label` in the manifest,
`CFBundleDisplayName` on iOS).

---

## Design decisions worth knowing

**Colours are sampled from the mockup**, not eyeballed — see
`core/theme/app_colors.dart`. If the design changes, re-sample and update that
one file.

**Inter is bundled** (`assets/fonts/`) rather than fetched at runtime, so the
app renders correctly offline and on first launch. `kEmojiFallback` in
`core/theme/app_theme.dart` points text at a colour emoji font; Android and iOS
fall back on their own, but web and desktop need telling.

**Games sit behind an interface.** `games/game_module.dart` defines
`GameModule` / `GameTransport` / `GameSyncModel`. Every game in the current
design is `turnBased` — one player acts, the server validates, everyone is told
the result. `realtime` exists in the enum but is unimplemented: it is reserved
for continuous-simulation games like 8-ball pool, which need server-side physics
and snapshot sync. Drawing the boundary now means adding pool later is an
addition, not a rewrite.

`GameRegistry` is empty. Registering a module there is the single step that
makes a game playable, so that map doubles as the to-do list.

---

## Languages

Ships with **English** and **Arabic**. Arabic also exercises RTL, so if a layout
survives it, it will survive most languages.

The picker lives in Profile → Language. Default is "System default" (follow the
phone); an explicit choice is saved to `SharedPreferences` and loaded before the
first frame, so the app never flashes the wrong language or direction on launch.

### Adding a language

Two steps. Nothing else in the codebase needs editing — not the picker, not the
controller:

```bash
cp lib/l10n/app_en.arb lib/l10n/app_tr.arb   # translate the values
flutter gen-l10n
```

`AppLocalizations.supportedLocales` picks it up and the picker lists it.

Keep `languageName` in each file written **in that language's own script**
("English", "العربية"). The picker reads it from that locale's own ARB so every
option is legible to the person looking for it, even when the current UI is in a
language they cannot read.

### What is and isn't translated

Translated: all UI chrome, promo banner copy, category and filter labels.

**Not** translated: game titles, room names, usernames, chat messages. Those are
content, not chrome — "Ludo" is a proper noun, and once there is a backend the
titles will arrive already localised for the requested locale.

### Things that bit us, so they don't bite again

- **Inter has no Arabic glyphs.** Cairo is bundled and listed in
  `kFontFallback`, which every text style uses. It is a *fallback* rather than a
  per-locale family swap so mixed strings work — an Arabic room name beside an
  English username picks the right face character by character.
- **Fixed heights break on translation.** Cairo's line metrics are taller than
  Inter's and translated copy is a different length; the hero card overflowed by
  4px in Arabic. It is now sized for the tallest script, with `Flexible` +
  `maxLines` as a backstop. Be suspicious of any hardcoded height wrapping text.
- **Icons do not mirror themselves.** A "forward" chevron has to be swapped for
  a back chevron in RTL — see `Directionality.of(context)` checks in
  `widgets/common.dart` and the profile menu.
- **Content needs its own direction.** A Latin string inside an RTL paragraph
  gets bidi-reordered — "Who's The Spy?" rendered as "?Who's The Spy". Content
  text is wrapped with `directionOf()` (in `widgets/common.dart`), which detects
  direction per string.
- **Switch on enums, not on labels.** The games filter used to `switch` on the
  tab's display string, which silently stops matching once translated. It is a
  `GameFilter` enum now.

### Reviewing a language

`test/screenshots.dart` renders every screen in both locales to
`test/goldens/*.png` (`11_*_ar` and up are the Arabic set). That is the fastest
way to eyeball a new translation for overflow and mirroring.

---

## Not built yet

**Missing screens** (need design):

- Login / signup / onboarding
- The actual game surfaces — the Ludo board, the UNO table, the Werewolf night
  phase. Largest missing chunk by far.
- Wallet, coin top-up, IAP store
- Gift picker sheet, tap-a-user profile popup, room settings

**Missing engineering**, roughly in order:

1. **Backend.** The open decision. Firebase ships fastest; a custom server
   (WebSockets + Redis + Postgres) is required if coins are ever staked on a
   match, because the server must own game state or players will cheat.
2. Auth and user accounts
3. Real-time rooms: presence, seats, chat
4. Voice — buy it (Agora / ZEGOCLOUD), don't build it. Billed per user-minute;
   this becomes the largest running cost.
5. Coins, gifting, Google Play Billing + StoreKit, server-side ledger
6. Matchmaking and the challenge flow
7. Game modules, turn-based first

Points marked `// SERVER:` in the code flag logic that is currently client-side
and must move server-side — the treasure-chest timer especially, which will be
farmed otherwise.

---

## Compliance note

Purchasable coins wagered on match outcomes is what gets apps in this category
rejected or pulled — Apple and Google treat it as gambling in many
jurisdictions. Survivable designs exist (entry fees into a prize pool,
cosmetic-only gifting, no cash-out), but the rules have to shape the economy
before it is built, not after.

---

## Toolchain notes

- Flutter 3.47.1 at `C:\src\flutter`, Android SDK 36 + NDK 28.2.13676358.
- iOS builds require the Mac. Everything else works from Windows.
- `applicationId` is `com.roomplay.room_play` — change it in
  `android/app/build.gradle.kts` before publishing if you want something
  cleaner.
- Release builds are currently signed with the **debug key**. A real upload key
  is needed before Play Store submission.
- The bundled `sdkmanager` shim mis-parses the legacy `platforms;android-36`
  syntax and drops the argument. Use slashes — `platforms/android-36` — if you
  need to install SDK packages by hand.
