# Brief 24 (v2) — GIS cells and the Layers tab

Branch `gis`, from `master` after Brief 22 has merged (v0.10-fixes). Supersedes the
earlier 24-gis-cells.md: same goal (pre-built cells replace Overpass at runtime), now
with the Layers tab and the site/plan split decided. Run without pausing; log
decisions in HANDOFF.md; three sites for every VERIFY. Merge on Jenna's approval,
tag v0.11-gis.

## Root cause

`SMP.importContext` runs one large Overpass query plus six `cov()` calls at import
time. Overpass has failed three times in real use (timeouts, server rotation),
COV field names are read raw in the browser, and there is no way to see what the
data around a site says before importing it. Every failure surfaces in the UI as
a failed import, and every schema change on a source is a bug in the app.

## Change, in one line

Data is normalised once, offline, into 1 km cells in a separate repo; the app
reads cells (cached in IndexedDB) for both the site map's Layers tab and the
facts derivation; Overpass survives only as a manual per-layer refresh.

## Part A — `curbside-data` repo (create it)

### A1. Layout
```
index.json                     cell list + per-layer updatedAt, bytes, schemaVersion
cells/{cellId}/{layerId}.json  one GeoJSON FeatureCollection per cell per layer
fixtures/                      copies of the cells for the three VERIFY sites (also
                               vendored into the app repo, see B7)
build/                         Node scripts, one per source
.github/workflows/refresh.yml  weekly (Mon 06:00 PT) + manual dispatch
```
Cell id: `{x}_{y}` on a 1 km grid in UTM 10N, origin at the SW corner of
`SM.VAN.bbox`. Features are clipped to the cell; a feature crossing cells appears
in each, with the same `id`, so the app dedupes by `id` on merge.

### A2. Schema (schemaVersion 1)
Every feature: `id` (stable: `cov:{dataset}:{recordid}`, `osm:{type}:{id}`,
`gtfs:stop:{stop_id}`), `layer`, `source` (`cov` | `osm` | `gtfs`), `fetchedAt`,
and a `props` object with **normalised names only**. Raw source fields never
reach the app. Geometry simplified at 0.5 m (Douglas–Peucker) for lines and
polygons; points untouched. Each cell-layer file ≤ 200 kB gzipped; if a layer
exceeds it, split the layer, do not raise the limit.

### A3. Layers to build

| layerId | source (dataset) | geometry | props |
|---|---|---|---|
| `bikeways` | cov `bikeways` | line | `type, subtype, name, side` (side = `approx`, centreline-based) |
| `truck-routes` | cov truck routes dataset | line | `name` |
| `one-way` | cov one-way streets | line | `name, direction` (bearing) |
| `bus-routes` | TransLink GTFS `routes`+`shapes` | line | `route, name` |
| `bus-stops` | GTFS `stops` (+ osm `highway=bus_stop` for cross-check) | point | `stopId, name, routes[]` |
| `row-width` | cov `right-of-way-widths` | line | `width` (m; NOT curb-to-curb) |
| `streets` | osm ways matching `SM.HIGHWAY` | line | `wayId, name, oneway, lanes, width?, cyclewaySide?` |
| `buildings` | osm `building` + cov `property-addresses` | polygon | `address, use` |
| `hydrants` | cov `water-hydrants` | point | `hydrantId` |
| `trees` | cov `public-trees` | point | `species, dbh, height?` |
| `transit-stations` | cov `rapid-transit-stations` | point | `name` |
| `pois` | osm `amenity/shop/office` nodes | point | `name, kind` |

Point layers `bus-stops`, `hydrants`, `trees` are the ones the Plan also draws
(B5); their `id` is the join key, so a map dot and a Plan symbol are provably
the same feature.

### A4. Build rules
- Each source script is independent; one failing source leaves that layer's
  previous files in place and marks it `stale: true` in `index.json` with the
  last good `updatedAt`. The workflow never publishes a partial cell set.
- Normalise inside the build script with a per-source mapping table at the top
  of the file, so a COV rename is a one-line fix there.
- Log a count per layer per run; a layer dropping > 30 % from the previous run
  fails that source (guards against an empty API response being published).
- Published via GitHub Pages (raw CORS-safe URLs). Document the base URL in the
  README; the app reads it from one constant `GIS.BASE`.

## Part B — the app

### B1. Registry (one source of truth)
`GIS.LAYERS`: one entry per layerId above, with `label, group ('City' | 'OSM' |
'TransLink'), geometry, style {colour, width | radius}, defaultOn, legend, feeds`
where `feeds` lists the site facts the layer derives (`roadDir`, `routeType`,
`bikeLane`, `row`, `laneCount`, or none). The Layers tab, legend, cache keys,
provenance text and `SMP.importContext` all read this table. Nothing else in the
app names a layerId.

Defaults on: `streets, bikeways, bus-stops, hydrants, trees, buildings`.
Defaults off: `truck-routes, one-way, bus-routes, row-width, transit-stations, pois`.

### B2. Loading (`GIS.load`)
- `index.json` fetched once per session (stale-while-revalidate, 24 h in IDB).
- A cell-layer file is fetched only when that layer is on **and** its cell is in
  the map viewport ±1 neighbour. Layers that are off are never downloaded.
- IndexedDB store `pkt-gis`, key `cellId|layerId|schemaVersion`, value = file +
  `storedAt`. Show cached data immediately; refresh in the background when
  `index.json` says the layer is newer; swap silently.
- Per cell-layer state machine: `idle → loading → ready | error`. Every request
  carries a viewport generation number; a response whose generation is older
  than the current one is discarded, never applied. `AbortController` on pan.
- Resident cap: 12 cells; evict least-recently-in-view. `schemaVersion`
  mismatch: drop that layer's cache entirely and refetch.
- Failure text (per layer, in the tab, never a modal): no network + no cache →
  "not cached here"; cell absent from index → "no data for this location";
  corrupt entry → drop + refetch silently; `stale: true` → "City data from
  {date}, refresh failed upstream".

### B3. Map rendering (`SM`)
- At map init add one empty GeoJSON source and one MapLibre layer per registry
  entry, in registry order, with fixed `beforeId`s (polygons < lines < points <
  picked street). Sources are **never** added or removed after init.
- Toggle = `setLayoutProperty(id, 'visibility', …)` only.
- Loaded cells merge into the source with one `setData` per layer per
  `requestAnimationFrame` (coalesce all changes of a frame). Dedupe by
  feature `id` across cells.
- Hover via `feature-state`, click opens a small popup from `props` (address,
  stop routes, tree species). No DOM per feature.

### B4. Layers tab (site map panel)
A `Layers` tab beside the existing site-map controls: layers grouped City / OSM /
TransLink, each row = checkbox, swatch, label, feature count in view, source
date from `index.json`, and a `↻ live` button on OSM layers only (B6). Toggle set
persists in localStorage `pkt_gis_layers` (per-viewer convenience, not part of
the design). Keyboard: space toggles, arrows move. `Reset to defaults` link.

### B5. Plan: Context toggle group (no new data path)
Add a small `Context` control to the Plan toolbar with four visibility toggles:
Trees · Street objects · Buildings · Stops & hydrants. Each toggles an existing
`data-layer` group's `display`; nothing is re-rendered. Bikeway, route, one-way
and ROW geometry are **not** drawn on the Plan (the Section owns lane geometry;
COV polygon accuracy is worse than the parklet at 1:100). Same toggles on 3D
where the group exists.

### B6. Overpass demoted
`SM.OVERPASS_LIST` stays, used only by the `↻ live` button on an OSM layer. The
result is written to the same `pkt-gis` store with `source: 'osm-live'` and a
timestamp, replaces that layer's cell in memory, and shows "live OSM {time}" in
the row. Import never calls Overpass.

### B7. `SMP.importContext` reads cells
Same output, same report shape, same `SITEF` provenance. Replace the Overpass
query and the six `cov()` calls with reads from the loaded cells (loading any
layer with `feeds` that is off, without turning it on in the tab). Add
`cell: 'City of Vancouver Open Data (cell)'`, `gtfs: 'TransLink GTFS'` and
`'osm-live': 'OpenStreetMap (live)'` to `SMP.SRC`; provenance lines read
"City of Vancouver Open Data, bikeways, data 2026-09-28". `curb-to-curb` stays a
field measurement; `laneCount` prefilled from `streets.lanes`, still user-
confirmed. Vendor `fixtures/` into the app repo under `test/gis-fixtures/`; when
`location.hostname` is a dev host and `?gis=fixtures` is set, `GIS.BASE` points
there so every VERIFY runs offline.

### B8. Layers never change facts
The toggle set affects the map only. A fact changes only through import or an
override, and both are logged as today.

## VERIFY (three sites, Playwright where measurable)
1. Cold load, empty IndexedDB, all defaults: map shows six layers within 2 s on
   fixtures; no console errors.
2. Toggle every layer 20× rapidly: no duplicate sources/layers
   (`map.getStyle().sources` count constant), no errors, final state matches
   the checkboxes.
3. Pan across four cells with all 12 layers on: frame time ≤ 16 ms median
   (Playwright `page.evaluate` with rAF timestamps), no feature ever drawn twice.
4. Pan, then pan back before the first response returns: the late response is
   discarded (assert the generation log).
5. Offline reload (`context.setOffline(true)`): cached layers draw, uncached rows
   say "not cached here", import still completes from cache.
6. Corrupt one IDB entry by hand: layer refetches, no error surfaces.
7. `schemaVersion` bumped in a test index: that layer's cache drops and refetches.
8. Import at each site from cells: every `SITEF` value equals the Brief 22
   baseline; provenance lines carry the cell date.
9. Plan Context toggles: each hides/shows only its group; compliance results
   and A-sheets unchanged.
10. `↻ live` on `streets`: row shows "live OSM", fact unchanged until re-import.
11. Address outside the cell index (e.g. Burnaby): "no data for this location",
    import runs on estimates, no throw.

## Commits
One per part: A (repo + workflow), B1–B2, B3–B4, B5, B6–B7, VERIFY report. Text
report in chat, not screenshots.

## Out of scope (note in HANDOFF.md)
Parking regulations, zoning, existing-parklet layers; imagery underlay on the
Plan; 3D context from cells. Candidate Brief 26.
