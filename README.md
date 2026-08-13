# Flapverse: Neon Flight

A landscape-first, installable arcade game prototype for Android and iPhone. It is a lightweight PWA with no runtime dependencies.

## Run locally

Serve this directory over HTTP (service workers do not run from `file://`):

```powershell
npm start
```

Open `http://localhost:4173` on a phone or desktop browser. Rotate a phone to landscape. On Android use **Install app**; on iPhone use **Share → Add to Home Screen**.

## Controls

- Tap / Space / Up Arrow: flap
- Swipe left/right / Left or Right Arrow: change lane
- The bird travels automatically

Progress, best score, and coins persist locally. The game includes home, characters, worlds, missions, shop, leaderboard, settings, gameplay, pause, and game-over screens.

## Native-store packaging

The web build can be wrapped with Capacitor for Play Store/App Store distribution. Native signing, store accounts, icons, screenshots, privacy metadata, and final device QA are separate release steps.
