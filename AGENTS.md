# AGENTS.md — SPARKcast

Project brief for AI coding agents (and me). Keep this updated as the app evolves.

## What this is
**SPARKcast** — a single-page weather app showing how much rain fell in the last 14 days,
the expected rainfall for the next 14 days, and how the forecast compares to today
(yesterday / today / tomorrow / 14-day average), plus a next-24-hours hourly view.
A second tab, **Models & accuracy**, compares several national models and scores their
past-month rainfall forecasts.

## Where it lives
- Local working copy: `C:\Users\Alex\weather-app`
- GitHub (source of truth): https://github.com/arnoldsparkinator/SPARKcast
- Live site (GitHub Pages): https://arnoldsparkinator.github.io/SPARKcast/
- GitHub account/handle: `arnoldsparkinator`

## Architecture
- Everything is in `index.html` — HTML + CSS + vanilla JS, no build step, no dependencies.
- Two tabs: `Rainfall` (default) and `Models & accuracy` (`state.tab`).
- Weather data: Open-Meteo (free, no API key).
  - Forecast/history: `https://api.open-meteo.com/v1/forecast` with `past_days=14&forecast_days=15&timezone=auto`
  - City search (geocoding): `https://geocoding-api.open-meteo.com/v1/search`
  - Reverse geocoding for "My location": `https://api.bigdatacloud.net/data/reverse-geocode-client`
  - **Multi-model** (Models tab): same forecast URL with `&models=best_match,ukmo_seamless,ecmwf_ifs025,icon_seamless,gfs_seamless,meteofrance_seamless`. Response daily keys are suffixed per model, e.g. `precipitation_sum_ukmo_seamless`.
  - **Forecast skill** (Models tab): `https://previous-runs-api.open-meteo.com/v1/forecast` with `hourly=precipitation_previous_day1&past_days=31&forecast_days=1&models=<id>`. Hourly key is `precipitation_previous_day1` (NOT model-suffixed); sum the hours per day. `_previous_day1` = value predicted 24 h before valid time, i.e. true 1-day-ahead skill.
  - **Observed rain (truth)**: `https://archive-api.open-meteo.com/v1/archive` with `daily=precipitation_sum` (ERA5-Land reanalysis). Full coverage up to ~today; no API key.
- `FEEDS` array defines the compared models (id, name, tag, colour).
- An optional Environment Agency rain-gauge truth (`fetchTruthEA`) exists behind `TRY_EA_GAUGE = false`; validate live before enabling, otherwise ERA5 is used.
- Saved locations, units and active tab are stored in the browser's `localStorage` (key `skycast.v1`).
- `.nojekyll` is present so GitHub Pages serves the file as-is.

## Models & accuracy — method
- For each feed, compare its **1-day-ahead** hourly rain (`_previous_day1`, summed per day) with ERA5-Land daily rain over the last ~30 days.
- Metrics per feed: **MAE** (mean absolute error, mm), **bias** (mean signed error), **wet-day agreement** (share of days where feed and truth agreed on ≥1 mm). Lower MAE = better; the lowest is badged "most accurate".
- Note: for UK locations Open-Meteo's `best_match` resolves to the UK Met Office model, so the two rows often match exactly — this is expected.

## Forecast model selection
- The **Rainfall** tab fetches from a *specific* model (`fetchWeather` adds `&models=<id>`). A single-model request returns the **same unsuffixed** daily/hourly keys, so `analyze()` is unchanged.
- Choice is stored per location in `state.modelChoice` as `{ id, manual }`, persisted in `localStorage` (key `skycast.v1`).
- **Auto** (default, `manual:false`): the lowest-MAE feed from the accuracy data, but feeds flagged `noPop` (Meteo-France — no rain-probability data, would show a misleading 0%) are skipped. Only applied once the Models tab has been loaded for that location.
- **Manual**: the `Rain forecast model` `<select>` on the Models tab sets `manual:true` and the user's pick sticks.
- If `state.modelChoice` is empty (Models tab never opened) the app uses `best_match` as before, so behaviour is unchanged for existing users.
- Changing the model deletes the location's weather cache so the next render refetches with the new model; `ensureWeather(loc)` (triggered from `renderMain` when the cache is missing) handles the fetch.

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
