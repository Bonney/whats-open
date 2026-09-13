/* ==========================================================================
   Midcoast Maine — builds the guide from restaurants-combined.json.

   Progressive enhancement: the page ships as a slim top bar (the tag
   nav-bar) and an empty <main>. This script assembles the listings as a
   sortable table on wide screens and a card list on narrow ones, works out
   who's open right now, and wires up the tag filters. No framework, no
   build step.
   ========================================================================== */

// getDay() order, Sunday first. Note the data keys Thursday as "thr".
const DAY_KEYS = ["sun", "mon", "tue", "wed", "thr", "fri", "sat"];

const WEEK = [
  ["mon", "Mon", "Monday"],
  ["tue", "Tue", "Tuesday"],
  ["wed", "Wed", "Wednesday"],
  ["thr", "Thu", "Thursday"],
  ["fri", "Fri", "Friday"],
  ["sat", "Sat", "Saturday"],
  ["sun", "Sun", "Sunday"],
];

const TOWNS = [
  { key: "rockland", name: "Rockland" },
  { key: "thomaston", name: "Thomaston" },
  { key: "spruce-head", name: "Spruce Head" },
];

const ACRONYMS = { bbq: "BBQ" };

const SORT_KEYS = ["name", "town", "cuisine"];

let TAG_EMOJI = {};
let PLACES = [];
const NOW = new Date();

const state = {
  open: false,
  tags: new Set(),
  sortKey: "name",
  sortDir: "asc",
};

init();

async function init() {
  const loading = document.getElementById("loading");

  try {
    const [places, tags] = await Promise.all([
      fetchJSON("restaurants-combined.json"),
      fetchJSON("tags.json").catch(() => []),
    ]);
    TAG_EMOJI = normalizeTags(tags);
    PLACES = (Array.isArray(places) ? places : []).map(enrich);
    loading?.remove();
    setup();
  } catch (err) {
    console.error("Could not load the guide:", err);
    if (loading) {
      loading.textContent =
        "The listings could not be loaded just now — please try again in a moment.";
    }
  }
}

async function fetchJSON(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`${url} → ${res.status}`);
  return res.json();
}

function normalizeTags(raw) {
  const src = Array.isArray(raw) ? raw[0] || {} : raw || {};
  const out = {};
  for (const [name, emoji] of Object.entries(src)) {
    out[name.toLowerCase()] = emoji;
  }
  return out;
}

// Fold each raw record into the shape the renderers want.
function enrich(place) {
  const town = TOWNS.find((t) => String(place.id || "").endsWith("-" + t.key));
  const tagList = (place.tags || [])
    .filter(Boolean)
    .map((t) => String(t).toLowerCase());
  return {
    ...place,
    townKey: town ? town.key : "",
    townName: town ? town.name : "",
    tagList,
    status: statusFor(place.hours || {}, NOW),
    sortName: sortName(place.name),
  };
}

/* -------------------------------------------------------------------------- */

function setup() {
  const board = document.getElementById("board");

  buildTagNav();
  wireSorting();
  markTodayColumn();
  trackTopbar();
  readURL();

  board.hidden = false;
  applyAndRender();
}

/* --- The tag nav-bar ---------------------------------------------------- */

function buildTagNav() {
  const scroll = document.getElementById("tagnav-scroll");
  if (!scroll) return;

  const freq = new Map();
  for (const p of PLACES) {
    for (const t of p.tagList) freq.set(t, (freq.get(t) || 0) + 1);
  }
  const tags = [...freq.entries()]
    .sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]))
    .map(([t]) => t);

  const openBtn = chip("Open now", { "data-open": "" });
  openBtn.classList.add("chip--open");
  scroll.append(openBtn);

  for (const t of tags) {
    const emoji = TAG_EMOJI[t];
    scroll.append(
      chip((emoji ? emoji + " " : "") + titleCase(t), { "data-tag": t })
    );
  }

  const clearBtn = chip("Clear", { "data-clear": "" });
  clearBtn.classList.add("chip--clear");
  clearBtn.hidden = true;
  scroll.append(clearBtn);

  scroll.addEventListener("click", (e) => {
    const btn = e.target.closest("button");
    if (!btn) return;
    if (btn.hasAttribute("data-open")) {
      state.open = !state.open;
    } else if (btn.hasAttribute("data-tag")) {
      const t = btn.dataset.tag;
      if (state.tags.has(t)) state.tags.delete(t);
      else state.tags.add(t);
    } else if (btn.hasAttribute("data-clear")) {
      state.open = false;
      state.tags.clear();
    }
    applyAndRender();
  });
}

/* --- Sortable table headers ------------------------------------------------ */

function wireSorting() {
  const thead = document.querySelector(".board__table thead");
  if (!thead) return;
  thead.addEventListener("click", (e) => {
    const th = e.target.closest("th[data-sort]");
    if (!th) return;
    const key = th.dataset.sort;
    if (state.sortKey === key) {
      state.sortDir = state.sortDir === "asc" ? "desc" : "asc";
    } else {
      state.sortKey = key;
      state.sortDir = "asc";
    }
    applyAndRender();
  });
}

// Flag today's weekday column in the table header so it reads as "current".
function markTodayColumn() {
  const todayKey = DAY_KEYS[NOW.getDay()];
  document
    .querySelector(`.board__table thead th.board__day[data-day="${todayKey}"]`)
    ?.classList.add("is-today");
}

// Keep the sticky table header sitting just under the (variable-height) topbar.
function trackTopbar() {
  const bar = document.querySelector(".topbar");
  if (!bar) return;
  const set = () =>
    document.documentElement.style.setProperty(
      "--topbar-h",
      bar.offsetHeight + "px"
    );
  set();
  addEventListener("resize", set);
}

/* --- Filter, sort, render --------------------------------------------------- */

function currentList() {
  const list = PLACES.filter((p) => {
    if (state.open && p.status.state !== "open") return false;
    if (
      state.tags.size &&
      ![...state.tags].some((t) => p.tagList.includes(t))
    ) {
      return false;
    }
    return true;
  });

  const dir = state.sortDir === "asc" ? 1 : -1;
  list.sort(
    (a, b) =>
      compareBy(a, b, state.sortKey) * dir ||
      a.sortName.localeCompare(b.sortName)
  );
  return list;
}

function compareBy(a, b, key) {
  switch (key) {
    case "town":
      return a.townName.localeCompare(b.townName);
    case "cuisine":
      return (a.tagList[0] || "~").localeCompare(b.tagList[0] || "~");
    default:
      return a.sortName.localeCompare(b.sortName);
  }
}

function applyAndRender() {
  const list = currentList();

  renderTable(list);
  renderCards(list);
  document.getElementById("empty").hidden = list.length > 0;

  const filtering = state.open || state.tags.size > 0;
  for (const btn of document.querySelectorAll("#tagnav-scroll button")) {
    if (btn.hasAttribute("data-open")) {
      btn.setAttribute("aria-pressed", String(state.open));
    } else if (btn.hasAttribute("data-tag")) {
      btn.setAttribute("aria-pressed", String(state.tags.has(btn.dataset.tag)));
    } else if (btn.hasAttribute("data-clear")) {
      btn.hidden = !filtering;
    }
  }

  for (const th of document.querySelectorAll(".board__table th[data-sort]")) {
    th.setAttribute(
      "aria-sort",
      th.dataset.sort !== state.sortKey
        ? "none"
        : state.sortDir === "asc"
        ? "ascending"
        : "descending"
    );
  }

  writeColophon(list.length);
  writeURL();
}

function renderTable(list) {
  const body = document.getElementById("board-body");
  body.replaceChildren();
  const todayKey = DAY_KEYS[NOW.getDay()];

  for (const p of list) {
    const tr = document.createElement("tr");
    tr.dataset.state = p.status.state;

    // Name spans the (headers-only) Town column; the address sits beneath it.
    const name = document.createElement("th");
    name.scope = "row";
    name.className = "board__name";
    name.colSpan = 2;
    name.append(nameNode(p));
    if (p.address) {
      const addr = document.createElement("div");
      addr.className = "board__addr";
      addr.textContent = shortAddress(p.address);
      name.append(addr);
    }
    tr.append(name);

    tr.append(
      cell(p.tagList.map((t) => titleCase(t)).join(", "), "board__cuisine")
    );

    for (const [key] of WEEK) {
      const td = document.createElement("td");
      td.className = "board__day";
      if (key === todayKey) td.classList.add("is-today");

      const ranges = (p.hours && p.hours[key]) || [];
      if (!ranges.length) {
        td.textContent = "–";
        td.dataset.closed = "";
      } else {
        for (const raw of ranges) {
          const parsed = parseRange(raw);
          const span = document.createElement("span");
          span.className = "board__day-range";
          span.title = raw;
          span.textContent = parsed ? formatRange(parsed, true) : raw;
          td.append(span);
        }
      }
      tr.append(td);
    }

    body.append(tr);
  }
}

function renderCards(list) {
  const wrap = document.getElementById("cards");
  wrap.replaceChildren();
  for (const p of list) wrap.append(buildCard(p));
}

function buildCard(place) {
  const tpl = document.getElementById("tpl-card");
  const el = tpl.content.firstElementChild.cloneNode(true);

  // Name — a link when we have a URL, plain text otherwise.
  el.querySelector("[data-name]").replaceWith(nameNode(place));

  // Open / closed status
  const statusEl = el.querySelector("[data-status]");
  statusEl.textContent = place.status.text;
  statusEl.dataset.state = place.status.state;
  statusEl.hidden = false;
  el.dataset.open = String(place.status.state === "open");

  // Town
  const townEl = el.querySelector("[data-town]");
  if (place.townName) {
    townEl.textContent = place.townName;
    townEl.hidden = false;
  }

  // Tags
  const tagsEl = el.querySelector("[data-tags]");
  if (place.tagList.length) {
    for (const tag of place.tagList) {
      const span = document.createElement("span");
      span.className = "tag";
      const emoji = TAG_EMOJI[tag];
      span.textContent = (emoji ? emoji + " " : "") + titleCase(tag);
      tagsEl.append(span);
    }
    tagsEl.hidden = false;
  }

  // Description (rare, but a few have one)
  const descEl = el.querySelector("[data-desc]");
  if (place.description) {
    descEl.textContent = place.description;
    descEl.hidden = false;
  }

  // Contact
  const addrEl = el.querySelector("[data-addr]");
  if (place.address) {
    addrEl.textContent = place.address;
    addrEl.href =
      "https://www.google.com/maps/search/?api=1&query=" +
      encodeURIComponent(place.address);
    addrEl.target = "_blank";
    addrEl.hidden = false;
  }
  const phoneEl = el.querySelector("[data-phone]");
  if (place.phone) {
    phoneEl.textContent = place.phone;
    phoneEl.href = "tel:" + place.phone.replace(/[^\d+]/g, "");
    phoneEl.hidden = false;
  }
  if (!place.address && !place.phone) {
    el.querySelector(".place__contact").remove();
  }

  // Weekly schedule
  const dl = el.querySelector("[data-hours]");
  const todayKey = DAY_KEYS[NOW.getDay()];
  for (const [key, short, long] of WEEK) {
    const row = document.createElement("div");
    row.className = "hours__day";
    if (key === todayKey) row.classList.add("is-today");

    const dt = document.createElement("dt");
    const abbr = document.createElement("abbr");
    abbr.title = long;
    abbr.textContent = short;
    dt.append(abbr);

    const dd = document.createElement("dd");
    const ranges = (place.hours && place.hours[key]) || [];
    if (!ranges.length) {
      dd.textContent = "Closed";
      dd.dataset.closed = "";
    } else {
      for (const raw of ranges) {
        const parsed = parseRange(raw);
        const span = document.createElement("span");
        span.className = "hours__val";
        span.title = raw;
        if (parsed) {
          span.append(
            labelled("is-long", formatRange(parsed)),
            labelled("is-compact", formatRange(parsed, true))
          );
        } else {
          span.textContent = raw;
        }
        dd.append(span);
      }
    }
    row.append(dt, dd);
    dl.append(row);
  }
  dl.setAttribute(
    "aria-label",
    `Weekly hours for ${place.name || "this listing"}`
  );

  return el;
}

function nameNode(place) {
  const el = document.createElement(place.url ? "a" : "span");
  el.className = "place__link";
  el.textContent = place.name || "Unnamed listing";
  if (place.url) {
    el.href = place.url;
    el.target = "_blank";
    el.rel = "noopener";
  }
  return el;
}

function cell(text, cls) {
  const el = document.createElement("td");
  if (cls) el.className = cls;
  el.textContent = text;
  return el;
}

function chip(label, attrs) {
  const b = document.createElement("button");
  b.type = "button";
  b.className = "chip";
  b.setAttribute("aria-pressed", "false");
  b.textContent = label;
  for (const [k, v] of Object.entries(attrs)) b.setAttribute(k, v);
  return b;
}

function writeColophon(shown) {
  const el = document.getElementById("colophon-count");
  if (!el) return;
  const total = PLACES.length;
  el.textContent =
    (shown === total ? `${total} listings` : `${shown} of ${total} listings`) +
    " · Rockland, Thomaston & Spruce Head, Maine";
}

/* --- URL state ---------------------------------------------------------- */

function readURL() {
  const q = new URLSearchParams(location.search);
  if (q.get("open") === "1") state.open = true;
  for (const t of q.getAll("tag")) state.tags.add(t.toLowerCase());
  const sort = q.get("sort");
  if (sort) {
    const [key, dir] = sort.split(".");
    if (SORT_KEYS.includes(key)) {
      state.sortKey = key;
      state.sortDir = dir === "desc" ? "desc" : "asc";
    }
  }
}

function writeURL() {
  const q = new URLSearchParams();
  if (state.open) q.set("open", "1");
  for (const t of state.tags) q.append("tag", t);
  if (state.sortKey !== "name" || state.sortDir !== "asc") {
    q.set("sort", `${state.sortKey}.${state.sortDir}`);
  }
  const qs = q.toString();
  history.replaceState(null, "", qs ? "?" + qs : location.pathname);
}

/* --- Hours: parsing, formatting, open-now ------------------------------- */

// "4 pm", "9:30 pm", "4pm", "12 am" → minutes since midnight, or null.
function parseClock(str) {
  const m = String(str)
    .trim()
    .match(/^(\d{1,2})(?::(\d{2}))?\s*([ap])\.?\s*m\.?$/i);
  if (!m) return null;
  let h = Number(m[1]) % 12;
  if (/p/i.test(m[3])) h += 12;
  return h * 60 + (m[2] ? Number(m[2]) : 0);
}

// "4 pm - 9:30 pm" → { start, end } in minutes; end may exceed 1440 (past midnight).
function parseRange(str) {
  const parts = String(str).split(/\s*[–-]\s*/);
  if (parts.length !== 2) return null;
  const start = parseClock(parts[0]);
  let end = parseClock(parts[1]);
  if (start == null || end == null) return null;
  if (end <= start) end += 24 * 60;
  return { start, end };
}

function formatClock(min) {
  min = ((Math.round(min) % 1440) + 1440) % 1440;
  let h = Math.floor(min / 60);
  const m = min % 60;
  const mer = h >= 12 ? "pm" : "am";
  h = h % 12 || 12;
  return (m ? `${h}:${String(m).padStart(2, "0")}` : `${h}`) + mer;
}

function formatRange({ start, end }, compact = false) {
  let a = formatClock(start);
  let b = formatClock(end);
  if (compact) {
    // "11:30am" → "11:30a", and drop it entirely on the start when it matches.
    a = a.replace(/([ap])m$/, "$1");
    b = b.replace(/([ap])m$/, "$1");
  }
  // Drop the meridian on the start time when it matches the end: "4–9pm".
  const aMer = a.slice(compact ? -1 : -2);
  const bMer = b.slice(compact ? -1 : -2);
  const trimmed = aMer === bMer ? a.slice(0, compact ? -1 : -2) : a;
  return `${trimmed}–${b}`;
}

function labelled(cls, text) {
  const span = document.createElement("span");
  span.className = cls;
  span.textContent = text;
  return span;
}

function statusFor(hours, now) {
  const dow = now.getDay();
  const todayKey = DAY_KEYS[dow];
  const yesterdayKey = DAY_KEYS[(dow + 6) % 7];
  const mins = now.getHours() * 60 + now.getMinutes();

  // Still open from a range that started yesterday and crossed midnight.
  for (const raw of hours[yesterdayKey] || []) {
    const r = parseRange(raw);
    if (r && r.end > 1440 && mins < r.end - 1440) {
      return { state: "open", text: `Open · until ${formatClock(r.end - 1440)}` };
    }
  }

  const today = (hours[todayKey] || []).map(parseRange).filter(Boolean);
  let nextOpen = null;
  for (const r of today) {
    if (mins >= r.start && mins < r.end) {
      return { state: "open", text: `Open · until ${formatClock(r.end)}` };
    }
    if (mins < r.start && (nextOpen == null || r.start < nextOpen)) {
      nextOpen = r.start;
    }
  }
  if (nextOpen != null) {
    return { state: "soon", text: `Opens ${formatClock(nextOpen)}` };
  }
  if ((hours[todayKey] || []).length) {
    return { state: "closed", text: "Closed now" };
  }
  return { state: "closed", text: "Closed today" };
}

/* --- Small helpers ----------------------------------------------------- */

function sortName(name) {
  return String(name || "").replace(/^the\s+/i, "").toLowerCase();
}

// "179 Main St, Thomaston ME 04861" → "179 Main St, Thomaston" — the town
// tail is enough on the board, where there's no room for the state and ZIP.
function shortAddress(addr) {
  return String(addr).replace(/,?\s*[A-Z]{2}\s+\d{5}(?:-\d{4})?\s*$/, "");
}

function titleCase(str) {
  return String(str).replace(/[\w’']+/g, (word) => {
    const lower = word.toLowerCase();
    if (ACRONYMS[lower]) return ACRONYMS[lower];
    return word.charAt(0).toUpperCase() + word.slice(1);
  });
}
