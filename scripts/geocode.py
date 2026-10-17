#!/usr/bin/env python3
"""Fill in "lat"/"lng" for every restaurant file that has an address but no
coordinates yet, so the map view can plot it.

Free, keyless geocoders only: the US Census Bureau's address geocoder first
(good for street addresses), falling back to OpenStreetMap's Nominatim
(rate-limited to one request a second, per its usage policy).

The coordinates are written into the file as two lines just after "address",
leaving the rest of the file's hand formatting alone. Run it from the repo
root:

    python3 scripts/geocode.py           # only files missing coordinates
    python3 scripts/geocode.py --force   # re-geocode everything

A lookup that fails is reported and skipped, never fatal — that listing just
stays off the map until it gets coordinates (add them by hand if a geocoder
can't place it).
"""

import glob
import json
import re
import sys
import time
import urllib.parse
import urllib.request

USER_AGENT = "whats-open-geocoder (https://github.com/Bonney/whats-open)"

# A rough box around the Midcoast — anything outside it is a bad match.
BOUNDS = {"lat": (43.6, 44.5), "lng": (-69.6, -68.8)}


def get_json(url):
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=30) as res:
        return json.load(res)


def census(address):
    url = (
        "https://geocoding.geo.census.gov/geocoder/locations/onelineaddress?"
        + urllib.parse.urlencode(
            {"address": address, "benchmark": "Public_AR_Current", "format": "json"}
        )
    )
    matches = get_json(url)["result"]["addressMatches"]
    if matches:
        c = matches[0]["coordinates"]
        return c["y"], c["x"]
    return None


def nominatim(address):
    url = "https://nominatim.openstreetmap.org/search?" + urllib.parse.urlencode(
        {"q": address, "format": "json", "limit": 1, "countrycodes": "us"}
    )
    time.sleep(1)  # Nominatim's usage policy: at most one request a second.
    hits = get_json(url)
    if hits:
        return float(hits[0]["lat"]), float(hits[0]["lon"])
    return None


def in_bounds(lat, lng):
    return (
        BOUNDS["lat"][0] <= lat <= BOUNDS["lat"][1]
        and BOUNDS["lng"][0] <= lng <= BOUNDS["lng"][1]
    )


def geocode(address):
    for source in (census, nominatim):
        try:
            hit = source(address)
        except Exception as err:  # network trouble, odd response — try the next
            print(f"  {source.__name__}: {err}", file=sys.stderr)
            continue
        if hit and in_bounds(*hit):
            return round(hit[0], 6), round(hit[1], 6), source.__name__
    return None


def write_coords(path, text, lat, lng):
    # Drop any existing lat/lng lines, then add fresh ones after "address".
    text = re.sub(r'^[ \t]*"(?:lat|lng)":[^\n]*\n', "", text, flags=re.M)
    m = re.search(r'^([ \t]*)"address":[^\n]*\n', text, flags=re.M)
    indent = m.group(1)
    eol = "\r\n" if "\r\n" in text else "\n"  # keep the file's own line endings
    insert = f'{indent}"lat": {lat},{eol}{indent}"lng": {lng},{eol}'
    text = text[: m.end()] + insert + text[m.end() :]
    json.loads(text)  # never write a file we've broken
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write(text)


def main():
    force = "--force" in sys.argv
    added = failed = 0
    for path in sorted(glob.glob("restaurants/*/*.json")):
        with open(path, encoding="utf-8", newline="") as f:
            text = f.read()
        place = json.loads(text)
        address = (place.get("address") or "").strip()
        if not address:
            continue
        if not force and place.get("lat") is not None and place.get("lng") is not None:
            continue
        hit = geocode(address)
        if not hit:
            print(f"✗ {path}: no match for {address!r}", file=sys.stderr)
            failed += 1
            continue
        lat, lng, source = hit
        write_coords(path, text, lat, lng)
        print(f"✓ {path}: {lat}, {lng} ({source})")
        added += 1
    print(f"{added} geocoded, {failed} not found.")


if __name__ == "__main__":
    main()
