# Room Play

Voice chat rooms with social games inside them — the same shape as TopTop.
Flutter app for Android and iOS, Laravel backend.

```
room-play/
  app/    Flutter app          → app/README.md
  api/    Laravel API + admin  → api/README.md, api/DEPLOYMENT.md
```

## Why one repository

The two halves change together. Adding a rooms endpoint and wiring the room
screen to it is one change, not two — in separate repositories that becomes two
commits that can drift apart, with nothing recording that they belong together.
One repo means one commit, one tag, one revert.

The server clones the whole thing and serves `api/public`. It carries a few MB
of Flutter source it never reads, which is a cheap price for the above.

## Where things stand

| | |
|---|---|
| **App** | 10 screens, English + Arabic with RTL, logo and icon, 25 tests passing |
| **API** | Laravel 12 + Sanctum + Reverb. Auth done, 17 tests passing |
| **Connected** | Auth only. Rooms, games and coins are still mock data in the app |

## Getting started

```bash
# API
cd api && composer install && php artisan serve

# App — talks to the API above
cd app && flutter pub get && flutter run
```

The app's API address is platform-dependent and set at build time; see
`app/README.md`.

## Versioning

Push whenever something works. **Tag only at releases** — a tag means "this
exact code went somewhere real", so it needs to stay rare enough to be
meaningful.

```
v0.x.y   pre-launch, nothing shipped to a store yet
v1.0.0   first store release
v1.0.1   fixes only
v1.1.0   new features, nothing broken
v2.0.0   something existing changed shape
```

One tag covers both halves, which is the point of the single repo.

```bash
git tag -a v0.2.0 -m "Auth end to end"
git push origin v0.2.0
```

### The Android build number is separate, and unforgiving

`app/pubspec.yaml` ends with `version: 1.0.0+1`. The part after the `+` is the
build number, and Google Play requires it to **increase on every single upload**
— including re-uploads of the same version after a rejection. It can never be
reused or lowered, ever, for the life of the app.

Bump it every time you upload, whether or not the version before the `+`
changed.
