# AGENTS.md — SPARKcast

Project brief for AI coding agents (and me). Keep this updated as the app evolves.

## What this is
**SPARKcast** — a single-page weather app showing how much rain fell in the last 14 days,
the expected rainfall for the next 14 days, and how the forecast compares to today
(yesterday / today / tomorrow / 14-day average), plus a next-24-hours hourly view.

## Where it lives
- Local working copy: `C:\Users\Alex\weather-app`
- GitHub (source of truth): https://github.com/arnoldsparkinator/SPARKcast
- Live site (GitHub Pages): https://arnoldsparkinator.github.io/SPARKcast/
- GitHub account/handle: `arnoldsparkinator`

## Architecture
- Everything is in `index.html` — HTML + CSS + vanilla JS, no build step, no dependencies.
- Weather data: Open-Meteo (free, no API key).
  - Forecast/history: `https://api.open-meteo.com/v1/forecast` with `past_days=14&forecast_days=15&timezone=auto`
  - City search (geocoding): `https://geocoding-api.open-meteo.com/v1/search`
  - Reverse geocoding for "My location": `https://api.bigdatacloud.net/data/reverse-geocode-client`
- Saved locations and units are stored in the browser's `localStorage` (key `skycast.v1`).
- `.nojekyll` is present so GitHub Pages serves the file as-is.

## Conventions / gotchas
- Tap handling on mobile uses the `onTap()` helper (pointer events) — do NOT switch these
  back to plain `click`, or iOS swallows the first tap while the keyboard is open.
- "Today" is derived from the API's location-local date (`data.current.time`), not the browser date.
- No comments in code unless truly necessary. Keep it a single file.

## Deploy
Push to `main`; GitHub Pages rebuilds automatically in ~1 minute. The URL never changes.
```
.\backup.ps1 "your message"     # stages, commits, pushes
```
(Or: `git add -A; git commit -m "..."; git push`.)

## Backup / recovery
- Only **pushed** code exists in the cloud — run `backup.ps1` after each work session.
- opencode chat history lives only on this machine (`C:\Users\Alex\.local\share\opencode`).
  Export important sessions with `/export` and store the Markdown in the private
  `opencode-notes` repo.
- Keep GitHub 2FA recovery codes off this laptop.
