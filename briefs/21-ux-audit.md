# Brief 21 §1 — Interface audit

Build audited: branch `ux` at `ecd9094` (drawing-style after Brief 19b). Headless Edge at 1440 × 900, signed out (`?auth=signin`, sign-in dialog closed). Site: Robson & Burrard, imported from the City of Vancouver and OpenStreetMap, with the 7-piece test design. Audited 2026-09-29.

**Method.**
- A script opened each of the eight tabs, listed every visible control and clicked each safe one.
  - Recorded per control: its label, tooltip, section, text size and font face, what changed (DOM mutations within 250 ms) and any error or browser dialog.
  - Never clicked: paid calls (renders, the Assistant's send), network imports, file pickers, sign-out, deletes and downloads. These are marked "not clicked" with the reason.
- Every control that errored or showed no visible change was then rechecked by hand in the browser pane, as were the controls the script could not reach: the Panels menu, the account menu, the Assistant, panel Float/Close and Visualize › Appearance.
- The first-time journey (§B) was scripted step by step with a screenshot at each step. Its screenshots show four defects that no click raises an error for. Those four are marked BROKEN below, together with a keyboard defect found reading the handlers (§D).

## Summary

- **465 controls** across 8 tabs. Chrome that appears on several tabs (top bar, Selection / Grid / Move panel, viewport headers) is counted once per tab it shows on.
- **Clicks:** 0 raised an error. The script's three errors were one SVG control ("Click to look the other way") that has no `.click()`; a dispatched click flips the section direction correctly.
- **BROKEN: 5**, all found from the journey and the handlers, none from a click error:

  | # | Where | What happens | Seen in |
  |---|---|---|---|
  | B1 | Section header › FIT | "Fit the whole section in the view" does nothing once a site is imported. The fit subtracted the building columns in pixels at 60 px/m; Robson's near building is set back 8 m, which alone is 504 px, so the fit had no room left and stayed at 60 px/m. | journey 5, 9, 10 |
  | B2 | Section, after Import | The Section shows empty ground. At 1:1 the imported street is 1422 px wide in a 381 px panel, and the view stays at the left end, which is the setback in front of the building. | journey 5, 6, 9, 10 |
  | B3 | 3D, after Import | The 3D view opens inside a street tree. The home camera was placed behind the scene start (now the 600 m context radius) and the imported building's back wall (42 m deep); the controls pulled it in to 60 m, 4.8 m above the sidewalk, 1.25 m from a Quercus crown. | journey 5, 6, 9, 10 |
  | B4 | Plan › scale bar | At the Plan's far zoom the values 0 / 20 / 50 / 100 m print on top of one another over a 25 px bar. The bar's lengths stopped at 100 m, and only the 0.1 value was ever dropped. | every journey screenshot |
  | B5 | Keyboard | Ctrl+Z / Ctrl+Y are the Section editor's undo and redo but are registered on the whole page: on any other tab they undo Section edits that are not on screen. | §D |

- **PARTIAL: 7 distinct controls** (24 rows counted per tab):
  - Help "?" opens a browser alert with one line citing the Manual.
  - The Move arrows (N / W / E / S) and Apply ΔXZ show with nothing selected and do nothing, without saying why.
  - Visualize › Appearance › Technical is always disabled: a one-option toggle.
  - Also PARTIAL, a layout rather than a control: the Check tab's criteria column (journey 10) wraps a long provenance note one word per line inside the 270 px left panel. §3 moves the checks to the main area.
- **Not clicked: 19 rows:** paid, network, destructive or download actions, each with its reason. The report download was exercised in the Brief 19b runs (14–16 pages, both modes); the sample report and Print were not opened.

| | Count |
|---|---|
| Controls | 465 |
| OK | 422 |
| PARTIAL | 24 (7 distinct) |
| BROKEN | 5 (found from the journey and the handlers; 0 click errors) |
| Not clicked | 19 |

The per-tab table below counts the click audit's rows. B1–B5 come from the journey and the handlers, so they sit outside those rows.

## A. Inventory

Result column: `OK (n)` = the click changed the page (n DOM mutations within 250 ms); `field` / `select (n)` = a value control, inspected, not clicked; `->` = the hand check that settles a row the script could not.

| Tab | Controls | OK | PARTIAL | BROKEN | Not clicked |
|---|---|---|---|---|---|
| site | 185 | 166 | 6 | 0 | 13 |
| design | 70 | 64 | 6 | 0 | 0 |
| visualize | 35 | 31 | 2 | 0 | 2 |
| generate | 23 | 22 | 1 | 0 | 0 |
| check | 62 | 56 | 6 | 0 | 0 |
| furniture | 23 | 22 | 1 | 0 | 0 |
| settings | 31 | 29 | 1 | 0 | 1 |
| export | 36 | 32 | 1 | 0 | 3 |
| **All** | **465** | **422** | **24** | **0** | **19** |

### site tab - 185 controls

| Control | Kind | Section | Tooltip | Result | Mark |
|---|---|---|---|---|---|
| Site | button:submit |  |  | OK (37) | OK |
| Design | button:submit |  |  | OK (36) | OK |
| Visualize | button:submit |  |  | OK (49) | OK |
| Generate | button:submit |  |  | OK (34) | OK |
| Check | button:submit |  |  | OK (79) | OK |
| Furniture | button:submit |  |  | OK (72) | OK |
| Settings | button:submit |  |  | OK (30) | OK |
| Export | button:submit |  |  | OK (32) | OK |
| Panels ▾ `#dkMenuBtn` | button:submit |  |  | OK (27) | OK |
| Project name... `#projectName` | input:text |  |  | field | OK |
| ? | button:submit |  | Help | OK (1); browser alert -> Help opens a browser alert with one line citing the Manual; no help content, no shortcuts | PARTIAL |
| Sign In `#pkAccBtn` | button:submit |  |  | OK (1) | OK |
| — `#cadPosX` | input:number | #ctxPanel |  | field | OK |
| — `#cadPosZ` | input:number | #ctxPanel | World Z (exact, no snap) | field | OK |
| — `#cadRot` | input:number | #ctxPanel |  | field | OK |
| Grid `#cadGridBtn` | button:submit | #ctxPanel | Toggle grid (all views) | OK (20) | OK |
| Snap `#cadSnapBtn` | button:submit | #ctxPanel | Toggle snap | OK (3) | OK |
| cadGridSel `#cadGridSel` | select:select-one | #ctxPanel |  | select (4) | OK |
| ↑ N | button:submit | #ctxPanel | North -Z | no visible change -> shown with nothing selected and does nothing, without saying why | PARTIAL |
| ← W | button:submit | #ctxPanel | West -X | no visible change -> shown with nothing selected and does nothing, without saying why | PARTIAL |
| cadMoveDist `#cadMoveDist` | input:number | #ctxPanel | Step (m) | field | OK |
| E → | button:submit | #ctxPanel | East +X | no visible change -> shown with nothing selected and does nothing, without saying why | PARTIAL |
| ↓ S | button:submit | #ctxPanel | South +Z | no visible change -> shown with nothing selected and does nothing, without saying why | PARTIAL |
| cadDX `#cadDX` | input:number | #ctxPanel |  | field | OK |
| cadDZ `#cadDZ` | input:number | #ctxPanel |  | field | OK |
| Apply ΔXZ | button:submit | #ctxPanel |  | no visible change -> shown with nothing selected and does nothing, without saying why | PARTIAL |
| OpenStreetMap way 74366383, fetched 2026-09-29 - the way's s | button:button | Site Setup | OpenStreetMap way 74366383, fetched 2026-09-29 - the way's segment at the point. Click to  | OK (880) | OK |
| N-S | button:button | Site Setup |  | OK (89) | OK |
| E-W | button:button | Site Setup |  | OK (88) | OK |
| NE-SW | button:button | Site Setup |  | OK (88) | OK |
| NW-SE | button:button | Site Setup |  | OK (88) | OK |
| Custom | button:button | Site Setup |  | OK (7) | OK |
| Street bearing in degrees `#siteBearingDeg` | input:number | Site Setup |  | field | OK |
| Parklet is on the south-westnorth-east side of the streetOSM `#siteSideSel` | select:select-one | Site Setup |  | select (2) | OK |
| OpenStreetMap way 74366383, fetched 2026-09-29 - your second | button:button | Site Setup | OpenStreetMap way 74366383, fetched 2026-09-29 - your second click. Click to confirm it. | OK (874) | OK |
| OpenStreetMap way 74366383, fetched 2026-09-29 - snapped to  | button:button | Site Setup | OpenStreetMap way 74366383, fetched 2026-09-29 - snapped to the way. Click to confirm it. | OK (874) | OK |
| Latitude °you `#siteLat` | input:number | Site Setup |  | field | OK |
| Longitude °OSM `#siteLon` | input:number | Site Setup |  | field | OK |
| Paste coordinates `#sitePaste` | input:text | Site Setup |  | field | OK |
| estimate way 74366383, fetched 2026-09-29 - 2 lanes x 3.2 m  | button:button | Site Setup | estimate way 74366383, fetched 2026-09-29 - 2 lanes x 3.2 m + 2 parking lanes x 2.4 m (far | OK (874) | OK |
| roadWidth `#roadWidth` | input:number | Site Setup |  | field | OK |
| estimate way 143683959, fetched 2026-09-29 - nearest buildin | button:button | Site Setup | estimate way 143683959, fetched 2026-09-29 - nearest building face, way 143683959; curb po | OK (874) | OK |
| sidewalkWidth `#sidewalkWidth` | input:number | Site Setup |  | field | OK |
| OpenStreetMap way 74366383, fetched 2026-09-29 - oneway=no.  | button:button | Site Setup | OpenStreetMap way 74366383, fetched 2026-09-29 - oneway=no. Click to confirm it. | OK (874) | OK |
| One-way | button:submit | Site Setup |  | OK (93) | OK |
| Two-way | button:submit | Site Setup |  | OK (92) | OK |
| OpenStreetMap way 74366383, fetched 2026-09-29 - lanes=2. Cl | button:button | Site Setup | OpenStreetMap way 74366383, fetched 2026-09-29 - lanes=2. Click to confirm it. | OK (874) | OK |
| lanesA `#lanesA` | input:number | Site Setup |  | field | OK |
| lanesB `#lanesB` | input:number | Site Setup |  | field | OK |
| OpenStreetMap way 74366383, fetched 2026-09-29 - suggested:  | button:button | Site Setup | OpenStreetMap way 74366383, fetched 2026-09-29 - suggested: highway=secondary; bus routes  | OK (874) | OK |
| Standard ≥ 3.0 m | button:submit | Site Setup |  | OK (233) | OK |
| Bus / Truck ≥ 3.2 m | button:submit | Site Setup |  | OK (233) | OK |
| Context each way mthe import radius and the street scene pas `#siteContextZ` | input:number | Site Setup |  | field | OK |
| Context buildings↗× | div | #ctxSite |  | OK (1) | OK |
| ↗ | button:submit | #ctxSite | Float | OK (6) | OK |
| × | button:submit |  | Close | OK (22) | OK |
| Remove | button:submit | #contextSection | Remove building 1 | not clicked -> destructive on the imported building; not clicked | - |
| OpenStreetMap way 69701736, fetched 2026-09-29 - height=13.  | button:button | #contextSection | OpenStreetMap way 69701736, fetched 2026-09-29 - height=13. Click to confirm it. | OK (326) | OK |
| bldgL0_height `#bldgL0_height` | input:number | #contextSection | Height (m) | field | OK |
| OpenStreetMap way 69701736, fetched 2026-09-29 - footprint.  | button:button | #contextSection | OpenStreetMap way 69701736, fetched 2026-09-29 - footprint. Click to confirm it. | not clicked -> verified in the Brief 19b runs (RPT.make, 14-16 pages); print dialog not opened | - |
| bldgL0_depth `#bldgL0_depth` | input:number | #contextSection | Depth (m) | field | OK |
| OpenStreetMap way 69701736, fetched 2026-09-29 - footprint a | button:button | #contextSection | OpenStreetMap way 69701736, fetched 2026-09-29 - footprint along the street. Click to conf | not clicked -> verified in the Brief 19b runs (RPT.make, 14-16 pages); print dialog not opened | - |
| bldgL0_length `#bldgL0_length` | input:number | #contextSection | Length along street (m) | field | OK |
| bldgL0_zOffset `#bldgL0_zOffset` | input:number | #contextSection | Start position, m from the parklet start (negative = before it) | field | OK |
| OpenStreetMap way 69701736, fetched 2026-09-29 - face 18.0 m | button:button | #contextSection | OpenStreetMap way 69701736, fetched 2026-09-29 - face 18.0 m from the curb. Click to confi | OK (326) | OK |
| bldgL0_setback `#bldgL0_setback` | input:number | #contextSection | Setback from sidewalk (m) | field | OK |
| OpenStreetMap way 69701736, fetched 2026-09-29 - building=pu | button:button | #contextSection | OpenStreetMap way 69701736, fetched 2026-09-29 - building=public. Click to confirm it. | OK (326) | OK |
| bldgL0_use `#bldgL0_use` | select:select-one | #contextSection |  | select (8) | OK |
| estimate way 69701736, fetched 2026-09-29 - OSM has no front | button:button | #contextSection | estimate way 69701736, fetched 2026-09-29 - OSM has no frontage type. Click to confirm it. | OK (326) | OK |
| bldgL0_frontage `#bldgL0_frontage` | select:select-one | #contextSection |  | select (4) | OK |
| OpenStreetMap way 69701736, fetched 2026-09-29. Click to con | button:button | #contextSection | OpenStreetMap way 69701736, fetched 2026-09-29. Click to confirm it. | OK (326) | OK |
| e.g. Elysian Coffee `#bldgL0_name` | input:text | #contextSection | Shown on the sign in renders; named in the photoreal prompt | field | OK |
| OpenStreetMap way 69701736, fetched 2026-09-29 - building:le | button:button | #contextSection | OpenStreetMap way 69701736, fetched 2026-09-29 - building:levels=1. Click to confirm it. | OK (326) | OK |
| bldgL0_storeys `#bldgL0_storeys` | input:number | #contextSection | Storeys (the height was typed, so it stays) | field | OK |
| OpenStreetMap way 139571595, fetched 2026-09-29 - height=14. | button:button | #contextSection | OpenStreetMap way 139571595, fetched 2026-09-29 - height=14. Click to confirm it. | OK (326) | OK |
| bldgL1_height `#bldgL1_height` | input:number | #contextSection | Height (m) | field | OK |
| OpenStreetMap way 139571595, fetched 2026-09-29 - footprint. | button:button | #contextSection | OpenStreetMap way 139571595, fetched 2026-09-29 - footprint. Click to confirm it. | not clicked -> verified in the Brief 19b runs (RPT.make, 14-16 pages); print dialog not opened | - |
| bldgL1_depth `#bldgL1_depth` | input:number | #contextSection | Depth (m) | field | OK |
| OpenStreetMap way 139571595, fetched 2026-09-29 - footprint  | button:button | #contextSection | OpenStreetMap way 139571595, fetched 2026-09-29 - footprint along the street. Click to con | not clicked -> verified in the Brief 19b runs (RPT.make, 14-16 pages); print dialog not opened | - |
| bldgL1_length `#bldgL1_length` | input:number | #contextSection | Length along street (m) | field | OK |
| bldgL1_zOffset `#bldgL1_zOffset` | input:number | #contextSection | Start position, m from the parklet start (negative = before it) | field | OK |
| OpenStreetMap way 139571595, fetched 2026-09-29 - face 7.0 m | button:button | #contextSection | OpenStreetMap way 139571595, fetched 2026-09-29 - face 7.0 m from the curb. Click to confi | OK (326) | OK |
| bldgL1_setback `#bldgL1_setback` | input:number | #contextSection | Setback from sidewalk (m) | field | OK |
| OpenStreetMap node 4548006178, fetched 2026-09-29 - office=c | button:button | #contextSection | OpenStreetMap node 4548006178, fetched 2026-09-29 - office=company. Click to confirm it. | OK (326) | OK |
| bldgL1_use `#bldgL1_use` | select:select-one | #contextSection |  | select (8) | OK |
| estimate way 139571595, fetched 2026-09-29 - OSM has no fron | button:button | #contextSection | estimate way 139571595, fetched 2026-09-29 - OSM has no frontage type. Click to confirm it | OK (326) | OK |
| bldgL1_frontage `#bldgL1_frontage` | select:select-one | #contextSection |  | select (4) | OK |
| OpenStreetMap node 4548006178, fetched 2026-09-29. Click to  | button:button | #contextSection | OpenStreetMap node 4548006178, fetched 2026-09-29. Click to confirm it. | OK (326) | OK |
| e.g. Elysian Coffee `#bldgL1_name` | input:text | #contextSection | Shown on the sign in renders; named in the photoreal prompt | field | OK |
| OpenStreetMap way 139571595, fetched 2026-09-29 - building:l | button:button | #contextSection | OpenStreetMap way 139571595, fetched 2026-09-29 - building:levels=20. Click to confirm it. | OK (326) | OK |
| bldgL1_storeys `#bldgL1_storeys` | input:number | #contextSection | Storeys (the height was typed, so it stays) | field | OK |
| OpenStreetMap way 114505108, fetched 2026-09-29 - building:l | button:button | #contextSection | OpenStreetMap way 114505108, fetched 2026-09-29 - building:levels=6. Click to confirm it. | OK (326) | OK |
| bldgL2_height `#bldgL2_height` | input:number | #contextSection | Height (m) | field | OK |
| OpenStreetMap way 114505108, fetched 2026-09-29 - footprint. | button:button | #contextSection | OpenStreetMap way 114505108, fetched 2026-09-29 - footprint. Click to confirm it. | not clicked -> verified in the Brief 19b runs (RPT.make, 14-16 pages); print dialog not opened | - |
| bldgL2_depth `#bldgL2_depth` | input:number | #contextSection | Depth (m) | field | OK |
| OpenStreetMap way 114505108, fetched 2026-09-29 - footprint  | button:button | #contextSection | OpenStreetMap way 114505108, fetched 2026-09-29 - footprint along the street. Click to con | not clicked -> verified in the Brief 19b runs (RPT.make, 14-16 pages); print dialog not opened | - |
| bldgL2_length `#bldgL2_length` | input:number | #contextSection | Length along street (m) | field | OK |
| bldgL2_zOffset `#bldgL2_zOffset` | input:number | #contextSection | Start position, m from the parklet start (negative = before it) | field | OK |
| OpenStreetMap way 114505108, fetched 2026-09-29 - face 5.9 m | button:button | #contextSection | OpenStreetMap way 114505108, fetched 2026-09-29 - face 5.9 m from the curb. Click to confi | OK (326) | OK |
| bldgL2_setback `#bldgL2_setback` | input:number | #contextSection | Setback from sidewalk (m) | field | OK |
| OpenStreetMap node 3744771325, fetched 2026-09-29 - amenity= | button:button | #contextSection | OpenStreetMap node 3744771325, fetched 2026-09-29 - amenity=pharmacy. Click to confirm it. | OK (326) | OK |
| bldgL2_use `#bldgL2_use` | select:select-one | #contextSection |  | select (8) | OK |
| estimate way 114505108, fetched 2026-09-29 - OSM has no fron | button:button | #contextSection | estimate way 114505108, fetched 2026-09-29 - OSM has no frontage type. Click to confirm it | OK (326) | OK |
| bldgL2_frontage `#bldgL2_frontage` | select:select-one | #contextSection |  | select (4) | OK |
| OpenStreetMap node 3744771325, fetched 2026-09-29. Click to  | button:button | #contextSection | OpenStreetMap node 3744771325, fetched 2026-09-29. Click to confirm it. | OK (326) | OK |
| e.g. Elysian Coffee `#bldgL2_name` | input:text | #contextSection | Shown on the sign in renders; named in the photoreal prompt | field | OK |
| bldgL2_storeys `#bldgL2_storeys` | input:number | #contextSection | Storeys: sets the height (4.2 m ground floor + 3.5 m each above) until a height is typed | field | OK |
| OpenStreetMap way 143683959, fetched 2026-09-29 - building:l | button:button | #contextSection | OpenStreetMap way 143683959, fetched 2026-09-29 - building:levels=1. Click to confirm it. | OK (326) | OK |
| bldgL3_height `#bldgL3_height` | input:number | #contextSection | Height (m) | field | OK |
| OpenStreetMap way 143683959, fetched 2026-09-29 - footprint. | button:button | #contextSection | OpenStreetMap way 143683959, fetched 2026-09-29 - footprint. Click to confirm it. | not clicked -> verified in the Brief 19b runs (RPT.make, 14-16 pages); print dialog not opened | - |
| bldgL3_depth `#bldgL3_depth` | input:number | #contextSection | Depth (m) | field | OK |
| OpenStreetMap way 143683959, fetched 2026-09-29 - footprint  | button:button | #contextSection | OpenStreetMap way 143683959, fetched 2026-09-29 - footprint along the street. Click to con | not clicked -> verified in the Brief 19b runs (RPT.make, 14-16 pages); print dialog not opened | - |
| bldgL3_length `#bldgL3_length` | input:number | #contextSection | Length along street (m) | field | OK |
| bldgL3_zOffset `#bldgL3_zOffset` | input:number | #contextSection | Start position, m from the parklet start (negative = before it) | field | OK |
| OpenStreetMap way 143683959, fetched 2026-09-29 - face 4.1 m | button:button | #contextSection | OpenStreetMap way 143683959, fetched 2026-09-29 - face 4.1 m from the curb. Click to confi | OK (326) | OK |
| bldgL3_setback `#bldgL3_setback` | input:number | #contextSection | Setback from sidewalk (m) | field | OK |
| OpenStreetMap node 3281327361, fetched 2026-09-29 - shop=clo | button:button | #contextSection | OpenStreetMap node 3281327361, fetched 2026-09-29 - shop=clothes. Click to confirm it. | OK (326) | OK |
| bldgL3_use `#bldgL3_use` | select:select-one | #contextSection |  | select (8) | OK |
| estimate way 143683959, fetched 2026-09-29 - OSM has no fron | button:button | #contextSection | estimate way 143683959, fetched 2026-09-29 - OSM has no frontage type. Click to confirm it | OK (326) | OK |
| bldgL3_frontage `#bldgL3_frontage` | select:select-one | #contextSection |  | select (4) | OK |
| OpenStreetMap node 3281327361, fetched 2026-09-29. Click to  | button:button | #contextSection | OpenStreetMap node 3281327361, fetched 2026-09-29. Click to confirm it. | OK (326) | OK |
| e.g. Elysian Coffee `#bldgL3_name` | input:text | #contextSection | Shown on the sign in renders; named in the photoreal prompt | field | OK |
| bldgL3_storeys `#bldgL3_storeys` | input:number | #contextSection | Storeys: sets the height (4.2 m ground floor + 3.5 m each above) until a height is typed | field | OK |
| OpenStreetMap way 361655791, fetched 2026-09-29 - building:l | button:button | #contextSection | OpenStreetMap way 361655791, fetched 2026-09-29 - building:levels=2. Click to confirm it. | OK (326) | OK |
| bldgL4_height `#bldgL4_height` | input:number | #contextSection | Height (m) | field | OK |
| OpenStreetMap way 361655791, fetched 2026-09-29 - footprint. | button:button | #contextSection | OpenStreetMap way 361655791, fetched 2026-09-29 - footprint. Click to confirm it. | not clicked -> verified in the Brief 19b runs (RPT.make, 14-16 pages); print dialog not opened | - |
| bldgL4_depth `#bldgL4_depth` | input:number | #contextSection | Depth (m) | field | OK |
| OpenStreetMap way 361655791, fetched 2026-09-29 - footprint  | button:button | #contextSection | OpenStreetMap way 361655791, fetched 2026-09-29 - footprint along the street. Click to con | not clicked -> verified in the Brief 19b runs (RPT.make, 14-16 pages); print dialog not opened | - |
| bldgL4_length `#bldgL4_length` | input:number | #contextSection | Length along street (m) | field | OK |
| bldgL4_zOffset `#bldgL4_zOffset` | input:number | #contextSection | Start position, m from the parklet start (negative = before it) | field | OK |
| OpenStreetMap way 361655791, fetched 2026-09-29 - face 6.4 m | button:button | #contextSection | OpenStreetMap way 361655791, fetched 2026-09-29 - face 6.4 m from the curb. Click to confi | OK (326) | OK |
| bldgL4_setback `#bldgL4_setback` | input:number | #contextSection | Setback from sidewalk (m) | field | OK |
| OpenStreetMap node 6877185871, fetched 2026-09-29 - shop=cos | button:button | #contextSection | OpenStreetMap node 6877185871, fetched 2026-09-29 - shop=cosmetics. Click to confirm it. | OK (326) | OK |
| bldgL4_use `#bldgL4_use` | select:select-one | #contextSection |  | select (8) | OK |
| estimate way 361655791, fetched 2026-09-29 - OSM has no fron | button:button | #contextSection | estimate way 361655791, fetched 2026-09-29 - OSM has no frontage type. Click to confirm it | OK (326) | OK |
| bldgL4_frontage `#bldgL4_frontage` | select:select-one | #contextSection |  | select (4) | OK |
| OpenStreetMap node 6877185871, fetched 2026-09-29. Click to  | button:button | #contextSection | OpenStreetMap node 6877185871, fetched 2026-09-29. Click to confirm it. | OK (326) | OK |
| e.g. Elysian Coffee `#bldgL4_name` | input:text | #contextSection | Shown on the sign in renders; named in the photoreal prompt | field | OK |
| bldgL4_storeys `#bldgL4_storeys` | input:number | #contextSection | Storeys: sets the height (4.2 m ground floor + 3.5 m each above) until a height is typed | field | OK |
| OpenStreetMap way 361655790, fetched 2026-09-29 - building:l | button:button | #contextSection | OpenStreetMap way 361655790, fetched 2026-09-29 - building:levels=2. Click to confirm it. | OK (326) | OK |
| bldgL5_height `#bldgL5_height` | input:number | #contextSection | Height (m) | field | OK |
| OpenStreetMap way 361655790, fetched 2026-09-29 - footprint. | button:button | #contextSection | OpenStreetMap way 361655790, fetched 2026-09-29 - footprint. Click to confirm it. | not clicked -> verified in the Brief 19b runs (RPT.make, 14-16 pages); print dialog not opened | - |
| bldgL5_depth `#bldgL5_depth` | input:number | #contextSection | Depth (m) | field | OK |
| OpenStreetMap way 361655790, fetched 2026-09-29 - footprint  | button:button | #contextSection | OpenStreetMap way 361655790, fetched 2026-09-29 - footprint along the street. Click to con | not clicked -> verified in the Brief 19b runs (RPT.make, 14-16 pages); print dialog not opened | - |
| bldgL5_length `#bldgL5_length` | input:number | #contextSection | Length along street (m) | field | OK |
| bldgL5_zOffset `#bldgL5_zOffset` | input:number | #contextSection | Start position, m from the parklet start (negative = before it) | field | OK |
| OpenStreetMap way 361655790, fetched 2026-09-29 - face 7.9 m | button:button | #contextSection | OpenStreetMap way 361655790, fetched 2026-09-29 - face 7.9 m from the curb. Click to confi | OK (326) | OK |
| bldgL5_setback `#bldgL5_setback` | input:number | #contextSection | Setback from sidewalk (m) | field | OK |
| OpenStreetMap node 6877185870, fetched 2026-09-29 - shop=gif | button:button | #contextSection | OpenStreetMap node 6877185870, fetched 2026-09-29 - shop=gift. Click to confirm it. | OK (326) | OK |
| bldgL5_use `#bldgL5_use` | select:select-one | #contextSection |  | select (8) | OK |
| estimate way 361655790, fetched 2026-09-29 - OSM has no fron | button:button | #contextSection | estimate way 361655790, fetched 2026-09-29 - OSM has no frontage type. Click to confirm it | OK (326) | OK |
| bldgL5_frontage `#bldgL5_frontage` | select:select-one | #contextSection |  | select (4) | OK |
| All | button:submit |  |  | OK (37) | OK |
| Plan | button:submit |  |  | OK (40) | OK |
| Section | button:submit |  |  | OK (51) | OK |
| 3D | button:submit |  |  | OK (32) | OK |
| Schematic ▾ `#appearanceBtn` | button:submit |  | Drawing style | OK (12) | OK |
| DIM `#cadDimBtn` | button:submit |  | Show dimensions in Plan and Section | OK (21) | OK |
| Solve width | button:submit |  | Set parklet to the maximum width that keeps the adjacent lane compliant (C02) | OK (23) | OK |
| Fit all `#vpFitAllBtn` | button:submit |  | Fit each visible viewport to its drawing (Plan, Section, 3D) | OK (25) | OK |
| ✦ Assistant `#axToggleBtn` | button:submit |  | Change the design by describing it | not clicked -> opens and closes the Assistant panel (no message sent) | OK |
| Undo `#seUndoBtn` | button:submit | Section A–A |  | no visible change -> disabled with no history | OK |
| Redo `#seRedoBtn` | button:submit | Section A–A |  | no visible change -> disabled with no history | OK |
| Fit `#seFitBtn` | button:submit | Section A–A | Showing the whole section - click for 1:1 scale (scrolls) | OK (14) | OK |
| Maximize | button:submit | Section A–A | Maximize | OK (40) | OK |
| Travel Lane | button:button | Section A–A | Drag into the section, or click to append | OK (11) | OK |
| Transit | button:button | Section A–A | Drag into the section, or click to append | no visible change -> adds on pointer down/up (a real click); with the road full it refuses with a toast naming the remaining width | OK |
| Parking | button:button | Section A–A | Drag into the section, or click to append | no visible change -> adds on pointer down/up (a real click); with the road full it refuses with a toast naming the remaining width | OK |
| Turn Lane | button:button | Section A–A | Drag into the section, or click to append | no visible change -> adds on pointer down/up (a real click); with the road full it refuses with a toast naming the remaining width | OK |
| Bike Lane | button:button | Section A–A | Drag into the section, or click to append | no visible change -> adds on pointer down/up (a real click); with the road full it refuses with a toast naming the remaining width | OK |
| Planting | button:button | Section A–A | Drag into the section, or click to append | no visible change -> adds on pointer down/up (a real click); with the road full it refuses with a toast naming the remaining width | OK |
| Curb | button:button | Section A–A | Drag into the section, or click to append | no visible change -> adds on pointer down/up (a real click); with the road full it refuses with a toast naming the remaining width | OK |
| 4.10 | button:submit |  | Sidewalk width, m - click to edit | no visible change -> opens an inline width field (the audit clicked a re-rendered copy) | OK |
| 2.65 | button:submit |  | Parklet width, m - click to edit | no visible change -> opens an inline width field (the audit clicked a re-rendered copy) | OK |
| 3.08 | button:submit |  | Travel Lane width, m - click to edit | no visible change -> opens an inline width field (the audit clicked a re-rendered copy) | OK |
| 2.40 | button:submit |  | Parking width, m - click to edit | no visible change -> opens an inline width field (the audit clicked a re-rendered copy) | OK |
| Notes (7) | summary |  |  | no visible change -> opens and closes the notes strip | OK |
| − | button:submit | Plan | Zoom out | OK (14) | OK |
| + | button:submit | Plan | Zoom in | OK (13) | OK |
| FIT | button:submit | Plan | Fit the plan to its drawing | OK (12) | OK |
| A–A `#secTogglePV` | button:submit | Plan | Show the Section A-A cut line | not clicked -> toggles the section cut line on the Plan | OK |
| Measure `#pvMeasureBtn` | button:submit | Plan | Measure distance | OK (14) | OK |
| Extents `#pvExtentsBtn` | button:submit | Plan | Sheet extents: drag a sheet label to move its crop, its corner square to resize it (0.5 m  | OK (12) | OK |
| Click to look the other way | g |  |  | BROKEN: click: el.click is not a function -> SVG group; verified with a dispatched click: the section direction flips | OK |
| BOX `#secToggle3D` | button:submit | 3D | Show the section box, cut plane and fill in 3D | OK (2) | OK |

### design tab - 70 controls

| Control | Kind | Section | Tooltip | Result | Mark |
|---|---|---|---|---|---|
| Site | button:submit |  |  | OK (36) | OK |
| Design | button:submit |  |  | OK (36) | OK |
| Visualize | button:submit |  |  | OK (37) | OK |
| Generate | button:submit |  |  | OK (34) | OK |
| Check | button:submit |  |  | OK (79) | OK |
| Furniture | button:submit |  |  | OK (16) | OK |
| Settings | button:submit |  |  | OK (27) | OK |
| Export | button:submit |  |  | OK (32) | OK |
| Panels ▾ `#dkMenuBtn` | button:submit |  |  | OK (27) | OK |
| Project name... `#projectName` | input:text |  |  | field | OK |
| ? | button:submit |  | Help | OK (1); browser alert -> Help opens a browser alert with one line citing the Manual; no help content, no shortcuts | PARTIAL |
| Sign In `#pkAccBtn` | button:submit |  |  | OK (1) | OK |
| — `#cadPosX` | input:number | #ctxPanel |  | field | OK |
| — `#cadPosZ` | input:number | #ctxPanel | World Z (exact, no snap) | field | OK |
| — `#cadRot` | input:number | #ctxPanel |  | field | OK |
| Grid `#cadGridBtn` | button:submit | #ctxPanel | Toggle grid (all views) | OK (20) | OK |
| Snap `#cadSnapBtn` | button:submit | #ctxPanel | Toggle snap | OK (3) | OK |
| cadGridSel `#cadGridSel` | select:select-one | #ctxPanel |  | select (4) | OK |
| ↑ N | button:submit | #ctxPanel | North -Z | no visible change -> shown with nothing selected and does nothing, without saying why | PARTIAL |
| ← W | button:submit | #ctxPanel | West -X | no visible change -> shown with nothing selected and does nothing, without saying why | PARTIAL |
| cadMoveDist `#cadMoveDist` | input:number | #ctxPanel | Step (m) | field | OK |
| E → | button:submit | #ctxPanel | East +X | no visible change -> shown with nothing selected and does nothing, without saying why | PARTIAL |
| ↓ S | button:submit | #ctxPanel | South +Z | no visible change -> shown with nothing selected and does nothing, without saying why | PARTIAL |
| cadDX `#cadDX` | input:number | #ctxPanel |  | field | OK |
| cadDZ `#cadDZ` | input:number | #ctxPanel |  | field | OK |
| Apply ΔXZ | button:submit | #ctxPanel |  | no visible change -> shown with nothing selected and does nothing, without saying why | PARTIAL |
| Parklet↗× | div | #ctxDesign |  | OK (2) | OK |
| ↗ | button:submit | #ctxDesign | Float | OK (6) | OK |
| × | button:submit |  | Close | OK (22) | OK |
| Street context↗× | div | #ctxDesign |  | OK (1) | OK |
| OpenStreetMap way 74366383, fetched 2026-09-29 - cycleway:bo | button:button | Street Context | OpenStreetMap way 74366383, fetched 2026-09-29 - cycleway:both=no. Click to confirm it. | OK (885) | OK |
| None | button:submit | Street Context |  | OK (99) | OK |
| Painted | button:submit | Street Context |  | OK (107) | OK |
| Protected | button:submit | Street Context |  | OK (104) | OK |
| Vegetated buffer↗× | div | #ctxDesign |  | OK (2) | OK |
| Footprint↗× | div | #ctxDesign |  | not clicked -> panel header: Float pops it out and back; Close hides it and the Panels menu brings it back | OK |
| Library↗× | div | #ctxDesign |  | OK (4) | OK |
| All | button:submit |  |  | OK (38) | OK |
| Plan | button:submit |  |  | OK (42) | OK |
| Section | button:submit |  |  | OK (52) | OK |
| 3D | button:submit |  |  | OK (33) | OK |
| Schematic ▾ `#appearanceBtn` | button:submit |  | Drawing style | OK (13) | OK |
| DIM `#cadDimBtn` | button:submit |  | Show dimensions in Plan and Section | OK (24) | OK |
| Solve width | button:submit |  | Set parklet to the maximum width that keeps the adjacent lane compliant (C02) | OK (25) | OK |
| Fit all `#vpFitAllBtn` | button:submit |  | Fit each visible viewport to its drawing (Plan, Section, 3D) | OK (26) | OK |
| ✦ Assistant `#axToggleBtn` | button:submit |  | Change the design by describing it | not clicked -> opens and closes the Assistant panel (no message sent) | OK |
| Undo `#seUndoBtn` | button:submit | Section A–A |  | no visible change -> disabled with no history | OK |
| Redo `#seRedoBtn` | button:submit | Section A–A |  | no visible change -> disabled with no history | OK |
| Fit `#seFitBtn` | button:submit | Section A–A | Showing the whole section - click for 1:1 scale (scrolls) | OK (14) | OK |
| Maximize | button:submit | Section A–A | Maximize | OK (40) | OK |
| Travel Lane | button:button | Section A–A | Drag into the section, or click to append | OK (12) | OK |
| Transit | button:button | Section A–A | Drag into the section, or click to append | no visible change -> adds on pointer down/up (a real click); with the road full it refuses with a toast naming the remaining width | OK |
| Parking | button:button | Section A–A | Drag into the section, or click to append | no visible change -> adds on pointer down/up (a real click); with the road full it refuses with a toast naming the remaining width | OK |
| Turn Lane | button:button | Section A–A | Drag into the section, or click to append | no visible change -> adds on pointer down/up (a real click); with the road full it refuses with a toast naming the remaining width | OK |
| Bike Lane | button:button | Section A–A | Drag into the section, or click to append | no visible change -> adds on pointer down/up (a real click); with the road full it refuses with a toast naming the remaining width | OK |
| Planting | button:button | Section A–A | Drag into the section, or click to append | no visible change -> adds on pointer down/up (a real click); with the road full it refuses with a toast naming the remaining width | OK |
| Curb | button:button | Section A–A | Drag into the section, or click to append | no visible change -> adds on pointer down/up (a real click); with the road full it refuses with a toast naming the remaining width | OK |
| 4.10 | button:submit |  | Sidewalk width, m - click to edit | no visible change -> opens an inline width field (the audit clicked a re-rendered copy) | OK |
| 2.65 | button:submit |  | Parklet width, m - click to edit | no visible change -> opens an inline width field (the audit clicked a re-rendered copy) | OK |
| 3.08 | button:submit |  | Travel Lane width, m - click to edit | no visible change -> opens an inline width field (the audit clicked a re-rendered copy) | OK |
| 2.40 | button:submit |  | Parking width, m - click to edit | no visible change -> opens an inline width field (the audit clicked a re-rendered copy) | OK |
| Notes (7) | summary |  |  | no visible change -> opens and closes the notes strip | OK |
| − | button:submit | Plan | Zoom out | OK (15) | OK |
| + | button:submit | Plan | Zoom in | OK (14) | OK |
| FIT | button:submit | Plan | Fit the plan to its drawing | OK (13) | OK |
| A–A `#secTogglePV` | button:submit | Plan | Show the Section A-A cut line | not clicked -> toggles the section cut line on the Plan | OK |
| Measure `#pvMeasureBtn` | button:submit | Plan | Measure distance | OK (15) | OK |
| Extents `#pvExtentsBtn` | button:submit | Plan | Sheet extents: drag a sheet label to move its crop, its corner square to resize it (0.5 m  | OK (13) | OK |
| Click to look the other way | g |  |  | BROKEN: click: el.click is not a function -> SVG group; verified with a dispatched click: the section direction flips | OK |
| BOX `#secToggle3D` | button:submit | 3D | Show the section box, cut plane and fill in 3D | OK (2) | OK |

### visualize tab - 35 controls

| Control | Kind | Section | Tooltip | Result | Mark |
|---|---|---|---|---|---|
| Site | button:submit |  |  | OK (56) | OK |
| Design | button:submit |  |  | OK (56) | OK |
| Visualize | button:submit |  |  | OK (31) | OK |
| Generate | button:submit |  |  | OK (23) | OK |
| Check | button:submit |  |  | OK (99) | OK |
| Furniture | button:submit |  |  | OK (16) | OK |
| Settings | button:submit |  |  | OK (16) | OK |
| Export | button:submit |  |  | OK (21) | OK |
| Panels ▾ `#dkMenuBtn` | button:submit |  |  | OK (16) | OK |
| Project name... `#projectName` | input:text |  |  | field | OK |
| ? | button:submit |  | Help | OK (1); browser alert -> Help opens a browser alert with one line citing the Manual; no help content, no shortcuts | PARTIAL |
| Sign In `#pkAccBtn` | button:submit |  |  | OK (1) | OK |
| Street `#rvzPre_street` | button:button | Camera |  | OK (6) | OK |
| Sidewalk `#rvzPre_sidewalk` | button:button | Camera |  | OK (6) | OK |
| Corner `#rvzPre_corner` | button:button | Camera |  | OK (6) | OK |
| Aerial `#rvzPre_aerial` | button:button | Camera |  | OK (6) | OK |
| Date `#rvzDoy` | input:range | Sun |  | field | OK |
| 21 Jun | button:button | Sun |  | OK (17) | OK |
| 20 Mar | button:button | Sun |  | OK (37) | OK |
| 21 Dec | button:button | Sun |  | OK (37) | OK |
| Time `#rvzMin` | input:range | Sun |  | field | OK |
| Schematic | button:button | Appearance |  | OK (17) | OK |
| Rendered | button:button | Appearance |  | not clicked -> the only option | OK |
| Technical | button:button | Appearance | Technical is a drawing mode (Plan, Section, 3D), not a render mode | not clicked -> always disabled (tooltip: a drawing mode, not a render mode): a one-option toggle | PARTIAL |
| People and traffic `#rvzPeople` | input:checkbox | Appearance |  | OK (17) | OK |
| Resolution `#rvzRes` | select:select-one | Output |  | select (3) | OK |
| 2× | button:button | Output |  | OK (17) | OK |
| 4× | button:button | Output |  | OK (17) | OK |
| Render still `#rvzStill` | button:button | Output |  | not clicked -> paid provider call: not triggered (renders are manual only) | - |
| Render all presets `#rvzAll` | button:button | Output |  | not clicked -> paid provider call: not triggered (renders are manual only) | - |
| Photoreal (AI-assisted) `#rvzpOn` | input:checkbox | Photoreal |  | OK (11) | OK |
| Plan | button:submit |  |  | OK (30) | OK |
| Section | button:submit |  |  | OK (17) | OK |
| 3D | button:submit |  |  | OK (17) | OK |
| All | button:submit |  |  | OK (13) | OK |

### generate tab - 23 controls

| Control | Kind | Section | Tooltip | Result | Mark |
|---|---|---|---|---|---|
| Site | button:submit |  |  | OK (54) | OK |
| Design | button:submit |  |  | OK (54) | OK |
| Visualize | button:submit |  |  | OK (35) | OK |
| Generate | button:submit |  |  | OK (19) | OK |
| Check | button:submit |  |  | OK (97) | OK |
| Furniture | button:submit |  |  | OK (14) | OK |
| Settings | button:submit |  |  | OK (14) | OK |
| Export | button:submit |  |  | OK (19) | OK |
| Panels ▾ `#dkMenuBtn` | button:submit |  |  | OK (16) | OK |
| Project name... `#projectName` | input:text |  |  | field | OK |
| ? | button:submit |  | Help | OK (1); browser alert -> Help opens a browser alert with one line citing the Manual; no help content, no shortcuts | PARTIAL |
| Sign In `#pkAccBtn` | button:submit |  |  | OK (1) | OK |
| Site constraints↗× | div | #ctxGenerate |  | OK (2) | OK |
| ↗ | button:submit | #ctxGenerate | Float | OK (6) | OK |
| × | button:submit |  | Close | OK (22) | OK |
| Site facts↗× | div | #ctxGenerate |  | OK (2) | OK |
| Programme↗× | div | #ctxGenerate |  | OK (2) | OK |
| Character and materials↗× | div | #ctxGenerate |  | OK (2) | OK |
| Output↗× | div | #ctxGenerate |  | OK (2) | OK |
| Plan | button:submit |  |  | OK (30) | OK |
| Section | button:submit |  |  | OK (17) | OK |
| 3D | button:submit |  |  | OK (17) | OK |
| All | button:submit |  |  | OK (13) | OK |

### check tab - 62 controls

| Control | Kind | Section | Tooltip | Result | Mark |
|---|---|---|---|---|---|
| Site | button:submit |  |  | OK (37) | OK |
| Design | button:submit |  |  | OK (37) | OK |
| Visualize | button:submit |  |  | OK (37) | OK |
| Generate | button:submit |  |  | OK (35) | OK |
| Check | button:submit |  |  | OK (80) | OK |
| Furniture | button:submit |  |  | OK (16) | OK |
| Settings | button:submit |  |  | OK (28) | OK |
| Export | button:submit |  |  | OK (33) | OK |
| Panels ▾ `#dkMenuBtn` | button:submit |  |  | OK (28) | OK |
| Project name... `#projectName` | input:text |  |  | field | OK |
| ? | button:submit |  | Help | OK (1); browser alert -> Help opens a browser alert with one line citing the Manual; no help content, no shortcuts | PARTIAL |
| Sign In `#pkAccBtn` | button:submit |  |  | OK (1) | OK |
| — `#cadPosX` | input:number | #ctxPanel |  | field | OK |
| — `#cadPosZ` | input:number | #ctxPanel | World Z (exact, no snap) | field | OK |
| — `#cadRot` | input:number | #ctxPanel |  | field | OK |
| Grid `#cadGridBtn` | button:submit | #ctxPanel | Toggle grid (all views) | OK (22) | OK |
| Snap `#cadSnapBtn` | button:submit | #ctxPanel | Toggle snap | OK (3) | OK |
| cadGridSel `#cadGridSel` | select:select-one | #ctxPanel |  | select (4) | OK |
| ↑ N | button:submit | #ctxPanel | North -Z | no visible change -> shown with nothing selected and does nothing, without saying why | PARTIAL |
| ← W | button:submit | #ctxPanel | West -X | no visible change -> shown with nothing selected and does nothing, without saying why | PARTIAL |
| cadMoveDist `#cadMoveDist` | input:number | #ctxPanel | Step (m) | field | OK |
| E → | button:submit | #ctxPanel | East +X | no visible change -> shown with nothing selected and does nothing, without saying why | PARTIAL |
| ↓ S | button:submit | #ctxPanel | South +Z | no visible change -> shown with nothing selected and does nothing, without saying why | PARTIAL |
| cadDX `#cadDX` | input:number | #ctxPanel |  | field | OK |
| cadDZ `#cadDZ` | input:number | #ctxPanel |  | field | OK |
| Apply ΔXZ | button:submit | #ctxPanel |  | no visible change -> shown with nothing selected and does nothing, without saying why | PARTIAL |
| Expand all `#toggleAllBtn` | button:submit | #ctxCheck |  | OK (16) | OK |
| Confirm | button:button |  |  | OK (887) | OK |
| All | button:submit |  |  | OK (38) | OK |
| Plan | button:submit |  |  | OK (42) | OK |
| Section | button:submit |  |  | OK (52) | OK |
| 3D | button:submit |  |  | OK (33) | OK |
| Schematic ▾ `#appearanceBtn` | button:submit |  | Drawing style | OK (13) | OK |
| DIM `#cadDimBtn` | button:submit |  | Show dimensions in Plan and Section | OK (24) | OK |
| Solve width | button:submit |  | Set parklet to the maximum width that keeps the adjacent lane compliant (C02) | OK (25) | OK |
| Fit all `#vpFitAllBtn` | button:submit |  | Fit each visible viewport to its drawing (Plan, Section, 3D) | OK (26) | OK |
| ✦ Assistant `#axToggleBtn` | button:submit |  | Change the design by describing it | not clicked -> opens and closes the Assistant panel (no message sent) | OK |
| Undo `#seUndoBtn` | button:submit | Section A–A |  | no visible change -> disabled with no history | OK |
| Redo `#seRedoBtn` | button:submit | Section A–A |  | no visible change -> disabled with no history | OK |
| Fit `#seFitBtn` | button:submit | Section A–A | Showing the whole section - click for 1:1 scale (scrolls) | OK (14) | OK |
| Maximize | button:submit | Section A–A | Maximize | OK (40) | OK |
| Travel Lane | button:button | Section A–A | Drag into the section, or click to append | OK (12) | OK |
| Transit | button:button | Section A–A | Drag into the section, or click to append | no visible change -> adds on pointer down/up (a real click); with the road full it refuses with a toast naming the remaining width | OK |
| Parking | button:button | Section A–A | Drag into the section, or click to append | no visible change -> adds on pointer down/up (a real click); with the road full it refuses with a toast naming the remaining width | OK |
| Turn Lane | button:button | Section A–A | Drag into the section, or click to append | no visible change -> adds on pointer down/up (a real click); with the road full it refuses with a toast naming the remaining width | OK |
| Bike Lane | button:button | Section A–A | Drag into the section, or click to append | no visible change -> adds on pointer down/up (a real click); with the road full it refuses with a toast naming the remaining width | OK |
| Planting | button:button | Section A–A | Drag into the section, or click to append | no visible change -> adds on pointer down/up (a real click); with the road full it refuses with a toast naming the remaining width | OK |
| Curb | button:button | Section A–A | Drag into the section, or click to append | no visible change -> adds on pointer down/up (a real click); with the road full it refuses with a toast naming the remaining width | OK |
| 4.10 | button:submit |  | Sidewalk width, m - click to edit | no visible change -> opens an inline width field (the audit clicked a re-rendered copy) | OK |
| 4.80 | button:submit |  | Parklet width, m - click to edit | no visible change -> opens an inline width field (the audit clicked a re-rendered copy) | OK |
| 2.00 | button:submit |  | Bike Lane width, m - click to edit | no visible change -> opens an inline width field (the audit clicked a re-rendered copy) | OK |
| 3.00 | button:submit |  | Travel Lane width, m - click to edit | no visible change -> opens an inline width field (the audit clicked a re-rendered copy) | OK |
| 2.40 | button:submit |  | Parking width, m - click to edit | no visible change -> opens an inline width field (the audit clicked a re-rendered copy) | OK |
| Notes (7) | summary |  |  | no visible change -> opens and closes the notes strip | OK |
| − | button:submit | Plan | Zoom out | OK (15) | OK |
| + | button:submit | Plan | Zoom in | OK (14) | OK |
| FIT | button:submit | Plan | Fit the plan to its drawing | OK (13) | OK |
| A–A `#secTogglePV` | button:submit | Plan | Show the Section A-A cut line | not clicked -> toggles the section cut line on the Plan | OK |
| Measure `#pvMeasureBtn` | button:submit | Plan | Measure distance | OK (15) | OK |
| Extents `#pvExtentsBtn` | button:submit | Plan | Sheet extents: drag a sheet label to move its crop, its corner square to resize it (0.5 m  | OK (13) | OK |
| Click to look the other way | g |  |  | BROKEN: click: el.click is not a function -> SVG group; verified with a dispatched click: the section direction flips | OK |
| BOX `#secToggle3D` | button:submit | 3D | Show the section box, cut plane and fill in 3D | OK (2) | OK |

### furniture tab - 23 controls

| Control | Kind | Section | Tooltip | Result | Mark |
|---|---|---|---|---|---|
| Site | button:submit |  |  | OK (54) | OK |
| Design | button:submit |  |  | OK (54) | OK |
| Visualize | button:submit |  |  | OK (35) | OK |
| Generate | button:submit |  |  | OK (21) | OK |
| Check | button:submit |  |  | OK (97) | OK |
| Furniture | button:submit |  |  | OK (12) | OK |
| Settings | button:submit |  |  | OK (14) | OK |
| Export | button:submit |  |  | OK (19) | OK |
| Panels ▾ `#dkMenuBtn` | button:submit |  |  | OK (16) | OK |
| Project name... `#projectName` | input:text |  |  | field | OK |
| ? | button:submit |  | Help | OK (1); browser alert -> Help opens a browser alert with one line citing the Manual; no help content, no shortcuts | PARTIAL |
| Sign In `#pkAccBtn` | button:submit |  |  | OK (1) | OK |
| 〈 Design — place furniture | button:submit | #ctxFurniture |  | OK (54) | OK |
| Furniture `#flLibTab7Furn` | button:submit |  |  | OK (2) | OK |
| Street Components `#flLibTab7Str` | button:submit |  |  | OK (4) | OK |
| Search furniture... `#flSrch` | input:search |  |  | field | OK |
| Manufacturer presets `#flPresetsToggle` | input:checkbox |  |  | OK (44) | OK |
| Place | button:submit |  |  | OK (126) | OK |
| Info | button:submit |  |  | OK (3) | OK |
| Plan | button:submit |  |  | OK (30) | OK |
| Section | button:submit |  |  | OK (17) | OK |
| 3D | button:submit |  |  | OK (17) | OK |
| All | button:submit |  |  | OK (13) | OK |

### settings tab - 31 controls

| Control | Kind | Section | Tooltip | Result | Mark |
|---|---|---|---|---|---|
| Site | button:submit |  |  | OK (54) | OK |
| Design | button:submit |  |  | OK (54) | OK |
| Visualize | button:submit |  |  | OK (35) | OK |
| Generate | button:submit |  |  | OK (21) | OK |
| Check | button:submit |  |  | OK (97) | OK |
| Furniture | button:submit |  |  | OK (14) | OK |
| Settings | button:submit |  |  | OK (12) | OK |
| Export | button:submit |  |  | OK (19) | OK |
| Panels ▾ `#dkMenuBtn` | button:submit |  |  | OK (16) | OK |
| Project name... `#projectName` | input:text |  |  | field | OK |
| ? | button:submit |  | Help | OK (1); browser alert -> Help opens a browser alert with one line citing the Manual; no help content, no shortcuts | PARTIAL |
| Sign In `#pkAccBtn` | button:submit |  |  | OK (1) | OK |
| General | button:submit | #ctxSettings |  | no visible change -> scrolls the Settings page to the section | OK |
| Units | button:submit | #ctxSettings |  | no visible change -> scrolls the Settings page to the section | OK |
| Grid & Snap | button:submit | #ctxSettings |  | no visible change -> scrolls the Settings page to the section | OK |
| Project North | button:submit | #ctxSettings |  | no visible change -> scrolls the Settings page to the section | OK |
| Data | button:submit | #ctxSettings |  | no visible change -> scrolls the Settings page to the section | OK |
| Your name `#settName` | input:text |  |  | field | OK |
| your@email.com `#settEmail` | input:text |  |  | field | OK |
| Organization `#settOrg` | input:text |  |  | field | OK |
| Metric `#unitsMetricBtn` | button:submit |  |  | no visible change -> already the selected option | OK |
| Imperial `#unitsImperialBtn` | button:submit |  |  | OK (6) | OK |
| (no label) | select:select-one |  |  | select (4) | OK |
| Set in Site | button:submit |  |  | OK (54) | OK |
| Clear all saved data | button:submit |  |  | not clicked -> destructive; not clicked | - |
| × | button:submit | #rightPanel |  | OK (1) | OK |
| Place in Design | button:submit | OBJECT |  | OK (47) | OK |
| Plan | button:submit |  |  | OK (30) | OK |
| Section | button:submit |  |  | OK (17) | OK |
| 3D | button:submit |  |  | OK (17) | OK |
| All | button:submit |  |  | OK (13) | OK |

### export tab - 36 controls

| Control | Kind | Section | Tooltip | Result | Mark |
|---|---|---|---|---|---|
| Site | button:submit |  |  | OK (54) | OK |
| Design | button:submit |  |  | OK (54) | OK |
| Visualize | button:submit |  |  | OK (35) | OK |
| Generate | button:submit |  |  | OK (21) | OK |
| Check | button:submit |  |  | OK (97) | OK |
| Furniture | button:submit |  |  | OK (14) | OK |
| Settings | button:submit |  |  | OK (14) | OK |
| Export | button:submit |  |  | OK (17) | OK |
| Panels ▾ `#dkMenuBtn` | button:submit |  |  | OK (16) | OK |
| Project name... `#projectName` | input:text |  |  | field | OK |
| ? | button:submit |  | Help | OK (1); browser alert -> Help opens a browser alert with one line citing the Manual; no help content, no shortcuts | PARTIAL |
| Sign In `#pkAccBtn` | button:submit |  |  | OK (1) | OK |
| Schematic `#rptModeSch` | input:radio | #ctxExport |  | no visible change -> already the selected option | OK |
| Technical `#rptModeTech` | input:radio | #ctxExport |  | OK (2) | OK |
| ↓ Download report (PDF) `#pdfExportBtn` | button:submit | #ctxExport | 17 x 11 in landscape sheets, drawings at true scale, as a PDF file. | not clicked -> verified in the Brief 19b runs (RPT.make, 14-16 pages); print dialog not opened | - |
| See a sample report `#rptSampleBtn` | button:submit | #ctxExport | A finished report of a bundled reference design, in the selected type. Opens in a new tab; | not clicked -> verified in the Brief 19b runs (RPT.make, 14-16 pages); print dialog not opened | - |
| 🖶 Print (browser dialog) | button:submit | #ctxExport |  | not clicked -> verified in the Brief 19b runs (RPT.make, 14-16 pages); print dialog not opened | - |
| Parklet `#px3dLParklet` | input:checkbox | #ctxExport |  | no visible change -> export options, read when the export runs | OK |
| Furniture `#px3dLFurniture` | input:checkbox | #ctxExport |  | no visible change -> export options, read when the export runs | OK |
| Street context `#px3dLContext` | input:checkbox | #ctxExport |  | no visible change -> export options, read when the export runs | OK |
| px3dFmt `#px3dFmt` | select:select-one | #ctxExport |  | select (6) | OK |
| ↓ Export 3D Model `#px3dBtn` | button:submit | #ctxExport |  | OK (2) | OK |
| axeDur `#axeDur` | input:range | #ctxExport |  | field | OK |
| axeVeh `#axeVeh` | input:range | #ctxExport |  | field | OK |
| axePed `#axePed` | input:range | #ctxExport |  | field | OK |
| axeRes `#axeRes` | select:select-one | #ctxExport |  | select (3) | OK |
| axeCam `#axeCam` | select:select-one | #ctxExport |  | select (2) | OK |
| axeFmt `#axeFmt` | select:select-one | #ctxExport |  | select (2) | OK |
| Seamless loop `#axeLoop` | input:checkbox | #ctxExport |  | no visible change -> export options, read when the export runs | OK |
| ▶ Preview `#axePrevBtn` | button:submit | #ctxExport |  | OK (13) | OK |
| ↓ Export `#axeExpBtn` | button:submit | #ctxExport |  | OK (5) | OK |
| Axonometric preview (click to enlarge) `#axePreviewCanvas` | canvas | #ctxExport | Click to enlarge | OK (5) | OK |
| Plan | button:submit |  |  | OK (31) | OK |
| Section | button:submit |  |  | OK (17) | OK |
| 3D | button:submit |  |  | OK (17) | OK |
| All | button:submit |  |  | OK (15) | OK |


## B. First-time journey

The screenshots are in `briefs/21-ux-audit/`, at 1440 × 900 and taken before any fix. Sign-in itself was not performed: accounts and passwords are Jenna's to test. The sign-in dialog is shown with its fields empty: in the headless browser the password manager had filled them, and they were cleared before the screenshot. That screenshot was retaken after the fixes, so its background already shows the fixed scale bar and 3D view.

| Step | Screenshot | What the user sees | Is the next action obvious? |
|---|---|---|---|
| 1 Sign in | [journey-01-signin.jpg](21-ux-audit/journey-01-signin.jpg) | The Curbside dialog over the tool, with Sign In and Create Account tabs. | Yes. |
| 2 New design | [journey-02-new-design.jpg](21-ux-audit/journey-02-new-design.jpg) | New Design dialog: name prefilled "Untitled Parklet", optional address. | Yes. But the top bar keeps reading "New Parklet", a third default name ("My First Parklet" is the first-login default). |
| 3 Site tab | [journey-03-site.jpg](21-ux-audit/journey-03-site.jpg) | Three views and a Move block (N / W / E / S, ΔX / ΔZ) with nothing selected. The left panel's Site setup, Context buildings and Street objects are all collapsed. | No. Nothing says "Locate the site first"; the Locate button is inside the collapsed Site setup. The Move block and the Section palette come first. |
| 4 Locate | [journey-04-locate.jpg](21-ux-audit/journey-04-locate.jpg) | The map dialog: "Search an address or pan the map, then click the street where the parklet goes." | Yes, the dialog says it. |
| 5 Import | [journey-05-import.jpg](21-ux-audit/journey-05-import.jpg) | The Plan at far zoom with the city context. **The Section shows empty ground (B2). The 3D view is a green wall, a street tree's crown (B3).** The scale-bar values overprint (B4). The left panel has scrolled to the road-width fields. | No. The two views that should confirm the import show nothing. |
| 6 Place | [journey-06-place.jpg](21-ux-audit/journey-06-place.jpg) | "Find corners" and "Add corner" in the Site panel, with a note that the deck can be dragged in the Plan or moved with the arrow keys. | Partly. Placing happens in the Plan, which at this zoom shows the parklet as a few pixels. |
| 7 Generate | [journey-07-generate.jpg](21-ux-audit/journey-07-generate.jpg) | "Set the preferences in the dock, then Generate. Every scheme passes all 15 checks or is not shown." | Partly. "The dock" is the left panel; its five sections are collapsed and the Generate button is not visible. |
| 8 Generated | [journey-08-generated.jpg](21-ux-audit/journey-08-generated.jpg) | "This site cannot pass whatever the design: 01 Parking restrictions = bus_zone." | Yes, the reason is given. There is no link to where C01 is set (Site › Site setup), and `bus_zone` is an internal value. |
| 9 Design | [journey-09-design.jpg](21-ux-audit/journey-09-design.jpg) | The same three views. The Design panel lists Parklet, Street context (bike lane None / Painted / Protected), Vegetated buffer, Footprint and Library. | Partly. The bike-lane choice here repeats the Section palette's Bike Lane (§3 removes it). B2 and B3 still show. |
| 10 Check | [journey-10-check.jpg](21-ux-audit/journey-10-check.jpg) | The verdict "FAILS, 3 failing · 12 pending" and the criteria in the 270 px left panel, one word per line. The main area keeps the three views. | Partly. The checks are the least visible thing on the Check tab (§3 moves them to the main area). |
| 11 Visualize | [journey-11-visualize.jpg](21-ux-audit/journey-11-visualize.jpg) | A street-level preview, camera presets, sun, Appearance, Output. Photoreal starts at the bottom edge, below Render still / Render all presets. | Partly. Photoreal, the step the journey names ("Render"), is below the fold. |
| 12 Export | [journey-12-export.jpg](21-ux-audit/journey-12-export.jpg) | Report mode, Download report (PDF), See a sample report, Print, 3D model, animated axonometric. The main area: "Use the Export PDF Report button…"; the right third is empty. | Yes. But the preview names a button that does not exist ("Export PDF Report" versus "Download report (PDF)"). |

## C. Duplicates, dead space, terms, type

**Duplicates (one concept, more than one control):**
- **Layout:** the toolbar's All / Plan / Section / 3D and the status bar's Plan / Section / 3D / All.
- **Fit:** Plan FIT, Section FIT and the toolbar's "Fit all" (three names for fitting a view). The brief renames them to Fit view and Fit design.
- **Drawing mode:** the toolbar's "Schematic ▾", Visualize › Appearance (Schematic / Rendered / Technical) and Export › Report (Schematic / Technical).
- **Bike lane:** Design › Street context (None / Painted / Protected) and the Section palette's Bike Lane. Buffers: Design › Vegetated buffer and the Section's buffer segments. §3 keeps only the Section.
- **Parklet size:** Design › Parklet length / width and the Footprint editor.
- **Site data:** Generate › Site constraints and Site facts repeat values set on the Site tab.
- **Units:** the status bar's "m · mm" and Settings › Units.

**Dead space:**
- **Export:** the right third of the main area (about 420 px) is empty paper.
- **Generate before a run:** one line of text in a full-width empty area.
- **Visualize › Appearance:** a three-way switch with one live option (Technical always disabled).
- **Site tab, nothing selected:** Selection (X, Z, rotation, all "–"), Grid & Snap, Move and Delta take the top 340 px of the left panel before the tab's own content.
- **Section panel:** the palette, the Notes and the stats row leave about 100 px for the drawing at 1440 × 900.

**Inconsistent terms:**

| Concept | Variants in the interface | Count in `parklet-checker.html` |
|---|---|---|
| The platform | parklet, deck, platform | "platform" 49 times |
| Wheel stop | wheel stop, wheel-stop | 26 / 17 |
| Railing | railing, rail, barrier | "barrier" 7 |
| A new design's name | New Parklet (top bar), Untitled Parklet (dialog), My First Parklet (first login) | 3 / 8 / 5 |
| The PDF | Download report (PDF), Export PDF Report | 1 each |
| Fit | FIT, Fit all | |
| The section | Section A–A, Section A-A, A–A, Section | "Section A-A" 16 |
| Jargon | Solve width, Apply ΔXZ, BOX, DIM, EXTENTS | |

- **Header labels in capitals:** PLAN, SECTION A–A, 3D, MEASURE, EXTENTS, DIM, BOX, UNDO, REDO, FIT and the left-panel section headers. §2 asks for mixed case, with capitals only for rule IDs.

**Text under 12 px** (visible text nodes, per tab, as rendered):

| Site | Design | Visualize | Generate | Check | Furniture | Settings | Export |
|---|---|---|---|---|---|---|---|
| 137 | 159 | 62 | 88 | 127 | 292 | 49 | 59 |

- The stylesheet sets `font-size: 11px` 293 times and `10px` once; `12px` 21 times.
- The Furniture tab is the worst (292 nodes): its cards' names, sizes and tags are 10–11 px.

**Faces on one screen:**
- DM Sans everywhere.
- The UI monospace stack (`--font-mono`: ui-monospace, Cascadia Mono, Consolas) on Site (25 nodes), Design (62), Generate (56) and Check (39). It is used for the Selection / Move fields, the Section's numbers, Generate's status line and the criteria values.
- Courier New on the Furniture tab (38 nodes).
- Helvetica Neue: 1 node on Site, Design and Check.
- So up to three faces on one screen (Furniture: DM Sans + Courier New; Site / Design / Check: DM Sans + the mono stack + Helvetica Neue).


## D. Keyboard shortcuts

Read from every `keydown` handler in `parklet-checker.html`. "Discoverable" means the key is named somewhere the user can see (a tooltip, hint line or label) without reading the code.

| Key | Where | What it does | Handler | Discoverable |
|---|---|---|---|---|
| Esc | anywhere | Restores the three-view layout from a maximised view; cancels manhole, curb-object (H/P/S), driveway and furniture placement; clears the Plan furniture selection, the snap overlay and the site-coordinate popover | `document` keydown, line 3448 | No |
| Esc | Plan / 3D | Cancels a furniture drag or placement; else deselects the selected piece | lines 12713, 14014, 14226 | No |
| Esc | Section editor | Deselects the selected segment | `_onKey`, line 4450 | No |
| Esc | Locate modal | Closes it | line 23724 | No (there is a visible close button) |
| Esc | Assistant (enlarged) | Shrinks it back | `AXE._bigKey` | No |
| ← → ↑ ↓ | selected furniture | Nudges along world X (←/→) and Z (↑/↓) by the grid step when snapping is on (else 0.05 m); Shift × 4 | line 3473 | Partly (the Move arrows in the Selection panel do the same; the keys are not named) |
| ← → | parklet selected | Moves the parklet along the curb by the same step | line 3473 | No |
| ← → | Section editor, segment selected | Narrows / widens the segment by 0.05 m (Shift 0.10 m) | `_onKey` | No |
| Delete / Backspace | Section editor, segment selected | Removes the segment | `_onKey` | No |
| Delete / Backspace | Shape editor, vertex selected | Deletes the vertex | line 8957 | No |
| Ctrl+Z / Cmd+Z | anywhere outside a text field | Section editor undo. It is registered on `document`, so it undoes Section edits from any tab | `_onKey` | No |
| Ctrl+Y, Ctrl+Shift+Z | anywhere outside a text field | Section editor redo (same scope) | `_onKey` | No |
| Shift+D | anywhere outside a text field | Toggles the world-model debug HUD | line 3505 | No (developer aid) |
| Enter | Sign-in, sign-up, new-design and rename dialogs | Submits the dialog | inline `onkeydown` | Conventional |
| Enter / Space | Check rows, collapsible panel headers, Section palette | Opens the row or panel, or adds the segment | inline / lines 1197, 13307, 4437 | Conventional (focusable, role=button) |
| Enter (Shift+Enter: new line) | Assistant input | Sends the message | line 17213 | Conventional |
| Mouse wheel | Plan, Section, 3D | Zooms about the cursor | `_svgWheelZoom` | Conventional |

Findings:
- No shortcut is listed anywhere in the interface; §3 adds the "?" panel.
- Ctrl+Z is the Section editor's undo but is global: pressing it on another tab silently undoes the last Section edit. It is filed under PARTIAL in §A and handled in the §3 shortcuts work (scoped to the Section editor and the shape editor, which gets its own undo in §5b).
- Arrow keys nudge furniture by `_gridSpacing` only while snapping is on; with snapping off they move 0.05 m, which the interface does not say.
