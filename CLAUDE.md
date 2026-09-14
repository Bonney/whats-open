# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A static, no-build website listing restaurants in the Rockland/Thomaston/Camden/Spruce Head, Maine area — who's open and when. Plain HTML/CSS/JS, no framework, no package manager, no build step, no tests.

## Running locally

There's no dev server or build command. Serve the directory with any static file server, e.g.:

```
python3 -m http.server
```

Then open `index.html` (it `fetch()`es `restaurants-combined.json`, so it must be served over HTTP, not opened as a `file://` URL).

## Data architecture

Each restaurant is a single JSON file in `restaurants/`, named `<slug>-<town>.json` (e.g. `restaurants/adas-kitchen-rockland.json`), where `<town>` is one of `rockland`, `thomaston`, `spruce-head`, or `camden`. `templates/restaurant-template.json` is the blank shape for a new entry, and the VS Code snippet `.vscode/blank_poi_json.code-snippets` (prefix `poi`) inserts the same shape.

Restaurant JSON shape:
```json
{
  "id": "name-city",
  "name": "",
  "description": "",
  "address": "",
  "phone": "",
  "url": "",
  "tags": [],
  "hours": {
    "mon": [], "tue": [], "wed": [], "thr": [], "fri": [], "sat": [], "sun": []
  }
}
```
- `hours` days are keyed `mon/tue/wed/thr/fri/sat/sun` (note: Thursday is `thr`, not `thu`).
- Each day's value is an array of time-range strings (e.g. `"4 pm - 9 pm"`); empty array means closed.
- `tags` are free-form strings; `tags.json` maps known tag names to a display emoji (used for future UI, not yet wired into `script.js`).

**`restaurants-combined.json` is generated, not hand-edited.** A GitHub Actions workflow (`.github/workflows/combine-poi-json.yml`) runs on every push to `main`, concatenates all files in `restaurants/*.json` into `restaurants-combined.json`, and commits/pushes the result back to `main` if it changed. When adding or editing a restaurant, only touch the individual file under `restaurants/` — CI will regenerate the combined file on push, but **also rebuild it locally in the same change** (mirroring the workflow's own concatenation logic) so `restaurants-combined.json` stays in sync with `restaurants/*.json` for local testing and so the diff is included in the commit:

```bash
combined=()
for file in restaurants/*.json; do
  combined+=("$(cat "$file")")
done
combined=$(printf "%s," "${combined[@]}")
combined=${combined%,}
echo "[$combined]" > restaurants-combined.json
```

## Frontend

The site is styled as a print-style travel guide. There is no big masthead —
a slim sticky top bar carries the wordmark plus a permanent tag nav-bar. The
listing is one flat, alphabetised set of entries (not grouped by town): a
sortable table on wide screens (≥ 78rem, where the guide widens to
`--measure: 100rem`), a card list below that, and flowed guidebook entries on
paper. A container query on each card switches its weekly hours between a
stacked ledger and a seven-day timetable strip (≥ 30rem) — the same strip
the table's day columns reuse.

The table has no Town or Cuisine columns. Each row is just a name `<th>`
(`.board__name`) followed by the seven Mon–Sun day columns. The name cell
recreates a condensed version of the card — name + open/closed status, tags,
description, and address/phone — reusing the same `.place__tags` /
`.place__desc` / `.place__contact` classes the card template uses, built by
`boardNameCell()` in `script.js`.

- `index.html` is a static shell: a `<header class="topbar">` (wordmark +
  `<nav class="tagnav">` with an empty `#tagnav-scroll`), a `<main
  class="guide">` holding `#board` (a `<table>` whose `<thead>` has one
  sortable `th[data-sort="name"]` header then seven
  `th.board__day[data-day]` weekday headers, an empty `#board-body`, and an
  empty `#cards` div),
  a `<footer class="colophon">`, and a `<template id="tpl-card">` for one
  card. It loads Google Fonts (Fraunces + Inter), then `pylon.css`,
  `typography.css`, `stylesheet.css`.
- `pylon.css` — small vendored flexbox layout DSL (`hstack`/`vstack`/`list`/
  etc.). Currently unused by the page; treat as a fixed vendor file.
- `typography.css` — the editorial type system: font families, a fluid
  (`clamp()`) type scale `--step--1`…`--step-5`, and element/utility styles.
- `stylesheet.css` — CSS reset, design tokens (`:root`, with a
  `prefers-color-scheme: dark` block), the topbar/tagnav, the board (table +
  cards), entry components, and a full `@media print` treatment (which hides
  the table and prints the cards). Colours are warm paper/ink with a single
  buoy-red accent plus a green "open" state.
- `script.js` (vanilla, no framework, progressive enhancement) fetches
  `restaurants-combined.json` + `tags.json`, enriches each record (town name
  from the `id` suffix, an open-now/opens-later/closed status from the `hours`
  strings), builds the tag nav-bar (open-now toggle + every cuisine tag in
  use), and re-renders the table `<tbody>` and the card list on every filter
  or sort change. Sorting is by name only, via the one table header
  (`aria-sort` reflects state) — `compareBy()`/`SORT_KEYS` still support
  `town`/`cuisine` for the `?sort=` URL param, there's just no header to
  trigger them from; the seven weekday columns show each day's compact hours
  ("–" when closed) with today's column flagged `.is-today` by
  `markTodayColumn()`. Filter + sort state is mirrored to the URL query
  string (`?open=1&tag=…&sort=key.dir`). Cards clone `#tpl-card`, highlight
  the current day, and link the address to a Google Maps search and the
  phone to `tel:`.
