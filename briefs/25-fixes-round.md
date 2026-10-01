# Brief 25 — Fixes round (Jenna's walkthrough + Brief 23 smoke pass)

Branch `fixes-2` from master (v0.11-gis). Sources: Jenna's own pass on the live
site, 2026-09-30, and `briefs/23-triage.md` (smoke pass). Where the triage table
has a row for the same issue, cite its row number in the commit. Run without
pausing; log decisions; three sites plus West 4th at Yew and Main St 2000/2500
(the smoke-pass sites) for every VERIFY. Merge on Jenna's approval, tag
v0.12-fixes. Order matters: §1 first, because it changes what every later VERIFY
reports.

## §1 Checks: provenance drives the result (triage: C02 by construction)

Root cause: C02 compares an estimated roadway width (built from assumed 3.2 m
lanes) minus the parklet against 3.2 m, and reports a measured-style Fail. No
measurement exists anywhere in that chain.

1. Every check declares the facts it reads. Every fact already carries a source
   (measured / survey / imported / estimate / override). A check's result is
   capped by its weakest input:
   - any **estimate** → *Awaiting measurement*, never Pass/Fail; the row names
     the one thing to measure ("Measure curb-to-curb; estimate gives
     6 × 3.158 m, needs ≥ 3.2 m").
   - all inputs **imported**, unconfirmed → *Provisional* pass/fail.
   - all inputs **measured or confirmed** → Pass/Fail.
2. The verdict banner counts by those states; "does not pass" appears only when
   a measured/confirmed fact fails.
3. C02 row tidy-ups: Measured column collapses to one line ("6 lanes × 3.158 m,
   even split of estimated 25.5 m less parklet"); the "bus or truck route?"
   dropdown is pre-filled from Route type (one fact one store); the Resolution
   line reads "if the measured width confirms…" rather than instructing a
   redesign.
4. Import must not merge two one-way OSM ways into one 4+3 road (Main St). Two
   carriageways with a median or separate ways stay two; the import takes the
   way nearest the pick and says so in the report. Re-check the sidewalk
   estimate clamp (0.5 m) that followed from the 27.2 m width.
5. VERIFY: audit table in the report — one row per check C01–C19: inputs,
   their sources at the five sites, resulting state. No estimate anywhere
   yields Fail. Keep the table; it becomes README "Skill and limits".

## §2 Opening and sign-in

6. Sign-in / create-account modal: fully opaque background (black or the
   landing page). Nothing of the empty app shows through.
7. Landing page still says "invite code required"; sign-up has no code field.
   Remove the line while `invite_only` is false; show it only when the setting
   is true (read from app_settings, not hardcoded).
8. Two starting paths on the opening screen:
   - **Blank street**: generic two-way road, one travel lane each way plus
     parking, sidewalks both sides, two buildings per side of varying heights,
     no trees or objects. Every fact tagged `user`. Before it opens, a
     disclaimer with a Continue button: not a Vancouver location, all widths
     placeholders, measure on site; sheets carry "generic street — not a real
     location".
   - **Vancouver street**: current import. After the address pick, a layer
     picker (registry layers, Brief 24 defaults, Select all/none, note that
     it can be changed later under Import). Import pulls only ticked layers.
   Both land in the same sidebar (§3).
9. Intersection addresses ("Main St & 20th Ave") resolve in the address box.
10. A tree marker must not capture the side-of-street click; map data dots are
    non-interactive during the pick.

## §3 Sidebars: collapsible sections

11. Site sidebar after import: Import stays the forced first step. Then split
    "Site setup" into separate collapsed sections — Import · Street widths ·
    Road direction & lanes · Route type · Context buildings · Street objects.
    All closed; estimate badges and counts show on closed headers; parklet
    placement reachable without opening any.
12. Remove the "Street context" explanatory paragraph in the Design sidebar
    (keep any control inside it).
13. Visualize sidebar: collapsed sections — Camera · Photoreal render ·
    Output · Sun (and any below). The relay explanation becomes one line with
    a "how?" link. On the hosted copy, the photoreal Render button is greyed
    with that one line, not bright and clickable.
14. Furniture: add "Import 3D model" to the main Furniture tab beside the
    library pieces; rename the left-hand section "Furniture library".
15. Confirming 86–94 imported items one by one: add "Confirm all visible" and
    per-section confirm; keep the per-item path.
15b. Vehicles (cars, bikes, any road-context piece) can only be dropped on the
    parklet deck; they need to drop onto the road and parking lane. Each
    library item carries a drop zone (`deck` / `road` / `sidewalk` / `any`),
    vehicles default to `road`, and the Plan highlights the valid zone while
    dragging. Vehicles on the road are context only: not in the schedule, not
    in the checks, layer CONTEXT in exports.

## §4 Drawings

16. Section trees → flat silhouettes. One filled shape per tree (canopy +
    trunk), soft irregular edge, no outlines, no internal or branch lines.
    Library family of 3–4 silhouettes (round, oval, columnar, multi-stem) by
    species group where known, else round; scaled by canopy height/diameter;
    every tree an instance, no per-tree generation. Technical sheets: one pale
    grey (~12–15 % K). Schematic: same shapes in a pale desaturated green. One
    style token each. Draw order: behind everything; a sectioned building
    covers the tree. Jenna's reference image is a style target only — not in
    the repo.
17. Section view zoom/pan: scroll-wheel zoom, drag pan, "Fit street" button;
    opens fitted to the full sidewalk-to-sidewalk extent.
18. Tags button in Section does nothing; the tag key under the drawing is
    gone. Make the button work and restore the key (19b "key text centred").
19. View toggles read as switches with visible state: "Tags on/off", "Dims
    on/off", "Section box on/off" — Plan, Section and 3D alike.
20. Section box off by default.
20b. Section box orientation is locked: it always looks from one fixed side
    of the parklet (default: from the road toward the host building), and the
    box cannot be rotated or dragged to the other side. A "Flip section"
    button reverses the view direction; the section line on A-102/A-201 and the
    section marker arrows update with it.
20c. Tags collide (PR / PR / LA stacked on one leader in the Plan). Tags
    attached to pieces at the same point stack vertically on one leader with a
    gap, or merge into one tag ("PR ×2, LA"); no two tags may overlap.
21. Plan: near (imported) and far (city) buildings are drawn differently with
    no explanation. Draw the import radius faintly and add one legend line, or
    unify the style and let the radius control only sections/checks.
21b. The deck hatch is the accessible route (A-103 note 2 says so) but it is
    drawn as a band wrapped around the furniture, not as a route, and the
    in-app Plan has no key for it or for the dashed "Entry" box. Rule: a
    hatch or zone appears only if it is tied to a check or a Manual clause,
    with a key in the app and a note on the sheet. Redraw the route as a
    route: a continuous band from the entry across the deck, dimensioned
    (1.1 m clear; 1.5 m turning space where the route turns or ends), labelled
    "Accessible route" in the legend, and backed by C16 (the slot reserved for
    accessibility in Brief 20 — implement the route check now, minimal: entry
    width, route width, turning space; furniture that encroaches fails it).
    Any other furniture clearance hatch goes.
22. One label falls outside the sheet on the Main St PDFs — find and fix the
    placement rule, not the instance.
23. Console warning: 3D compass disagrees with the design's north. One north,
    one store.
22b. A-103 Deck plan splits a 19.8 m deck across two sheets at 1:50. Scale
    rule, like 19b's for A-201: choose the largest standard scale (1:50,
    1:75, 1:100) at which the whole deck fits on one landscape sheet with
    notes and title block; 1:100 is the floor. Split across sheets only if it
    still does not fit at 1:100, and then at a grid line with a proper match
    line on both. Apply the same rule to any plan-type sheet that is currently
    being split.
22d. Two sections in the package, not one:
    - **A-201 Street section** — the full width, sidewalk to far sidewalk,
      with the host building and the building opposite, at 1:100 (19b said
      never below 1:100; the current sheet is at 1:250 — find why and fix
      it). Lane labels and widths, the single overall dimension, levels.
    - **A-202 Parklet section** — the parklet and only what touches it:
      host sidewalk, deck, enclosure, buffer, the adjacent bike lane or
      parking lane and the first travel lane; at 1:50 (1:25 if it fits).
      Full detail: deck build-up, enclosure height, buffer, furniture at the
      cut, the levels and the 0.90 m, with notes and keys for this sheet only.
    Same cut line, same look direction (20b), same silhouette trees (16).
    Drawing list, section markers on A-102/A-103 and the cross-references
    update to the two sheets.
22e. Remove A-301 Details from the package entirely. The only two facts on it
    that matter — the enclosure spec (12 mm bars at 100, posts 40 at 1.0 m,
    0.90 m high, 0.30 m buffer) and the deck-edge gap (13 mm max, C14) —
    become notes on A-202 Parklet section, keyed to the enclosure and the
    deck edge in that drawing. Every "details A-301" cross-reference on other
    sheets, the drawing list, the page count and S-001 update; nothing else
    may still point at A-301. The enclosure parameters stay in the model and
    the schedule.
22f. Report sheets list only what the drawings use. The package is 17 pages,
    three of them trees. Rules:
    - S-002 and X-001 list a tree, hydrant, bus stop or building only if it
      is drawn on A-101/A-102 or feeds a check or advisory (e.g. the three
      trees beside the deck, the nearest hydrant each side, the nearest
      stop each side). Everything else in the import radius becomes one
      summary line per kind: "38 more street trees within 300 m, City
      public-trees data 2026-09-30, not listed" with the cell/data date.
    - Identical rows collapse: "Travel lanes: 6 × 3.16 m" not six rows;
      buildings: one row per side, "7 near-side buildings: name, use,
      height, storeys from OpenStreetMap; frontage estimated; addresses from
      City open data; ways listed in the design file" — not a paragraph per
      building.
    - The X-001 tree inventory table goes; its genus/height/DBH for the
      drawn trees joins the single S-002 row for each.
    - Target: the technical package ≤ 10 pages for a typical site; the
      drawing list on A-000 updates automatically. The full inventory stays
      in the design file for anyone who needs it.
22c. Replace the boxed title block (thumbnail, ruled cells) on every sheet with
    a plain drawing label in the bottom-left corner: sheet number and title on
    one line ("A-103  Deck plan"), then scale · date · status on the line
    below, in the sheet's small text, no box, no thumbnail. Left-aligned to
    the same margin as the notes, keys and any text above it, so the column
    reads as one. Project name and address move to the sheet header line that
    already exists at the top. The drawing list (A-000) and the footer
    disclaimer keep working from the same data.
23b. Cover axonometric (A-000) reads badly: camera too far out, grid lines
    visible, road rendered pink/red. Rules for the cover axo, as a fixed
    camera preset ("Cover"): framed so the parklet fills about a third of the
    image width with one bay of street either side and the host frontage
    behind; grid, section box, tags, dims and all editor overlays off;
    presentation materials — road a neutral warm grey, lane markings faint,
    sidewalk light, bike lane its usual green, parklet in full colour so it is
    the one saturated thing in the frame; soft shadows on. The same preset is
    the default 3D view when the tab opens, and it is what "Render still"
    uses unless the user has moved the camera.

## §5 3D and performance

24. 3D: full city, always. No import-radius cutoff. Building cells load around
    the camera as it moves; far cells as simple extruded blocks, near cells at
    full detail; same for streets and trees. The import radius only decides
    what gets sections and checks.
25. 3D stutter/flicker when orbiting or panning — profile first, then fix
    (likely per-frame geometry rebuild or shadow recompute).
26. Cell data batches cost 35–72 ms on the main thread (Brief 24 VERIFY 3):
    parse in a worker or spread map updates across frames, max one frame per
    batch.
27. PDF export freezes the page 1–2.5 min with "Preparing the PDF…"; "+ New"
    freezes for over a minute. Move the work off the main thread or chunk it
    with a progress bar that actually moves; "+ New" must open in under a
    second.
28. GitHub Pages does not rebuild on push (twice). Find the cause and fix it.
29. The 3 City exports during import are the last live network dependency:
    move them into the cells or a cached file; import makes zero live
    requests.

## §6 First-use clarity (small, do after §5)

30. A step strip under the top tabs: **Site → Design → Check → Export**, the
    current step highlighted, each a link to its tab. Generate, Furniture and
    Visualize are reachable from the tabs but are not steps. Hides after the
    user has exported once (per-browser).
31. Check tab default view: rows grouped by state in this order — Fails ·
    Awaiting measurement · Not entered · Provisional pass · Pass — with only
    the first two groups expanded. Each collapsed group shows its count.
    "Expand all" stays.
32. Verdict banner = one sentence plus one next action. "Does not pass:
    1 check fails on measured data" / "Can't be judged yet: measure 2 things
    on site" / "Passes provisionally: confirm 47 imported objects". The
    action is a button to the thing itself (the failing row, the survey
    sheet, the confirm list).
32b. The pass rule, said once where it's needed: a single line under the
    verdict banner and at the top of the Check tab — "A check passes only on
    measured or confirmed values; imported data gives a provisional result,
    estimates don't count." On first sign-in only, the same sentence appears
    once on the opening screen with a Got it button; never again on later
    sign-ins. The report's What to do next page (33) ends with the same
    line.
33. Report front matter: after the cover, a one-page **What to do next** —
    the three to five things to measure or confirm, each with its check and
    sheet reference, then the failing checks with their resolution line.
    Nothing else on the page. A café owner reads this page and the cover and
    knows what to do.

## README fixes (triage rows marked `readme`)
Apply the three README rows from 23-triage.md; re-run the How-to-use steps on
Pages after merge.

## VERIFY (five sites)
§1 audit table · opening paths both reach a sheet · every sidebar section
starts closed · one tree at 1:50 and the Commercial & 1st section beside the
reference · Section fits the street on open · all toggles show state · 3D pulls
back to the whole city at ≥ 30 fps on real hardware (Jenna confirms) · PDF
export under 20 s with a moving progress bar · zero live requests during
import · Pages updates within 2 minutes of a push.

## Out of scope (log in HANDOFF.md)
Hosted photoreal relay; persona 6 (accounts) and the full Brief 23 pass, which
run after this merges.
