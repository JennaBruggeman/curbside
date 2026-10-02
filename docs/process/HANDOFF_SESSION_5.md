# Curbside — Handoff for New Chat (Session 5)

**Read this first, then the repo's own `HANDOFF.md` (kept current by Claude Code) and `git log --oneline -30`.**
Written by the chat-side Claude for the next chat-side Claude, 29 Sep 2026 evening. Jenna works in two
places: Claude chat (diagnosis, briefs, review) and Claude Code (Opus 5.5, implements the briefs). Her
workflow: she pastes screenshots of Claude Code's reports here; chat writes the next brief; she saves it as
`briefs/NN-name.md` and tells Claude Code to read it (pasting long prompts truncates them).

**Two briefs are ready to send and are reproduced verbatim at the end of this file: Brief 21 (big
overnight interface brief) and Brief 23 (stranger test). Offer them as soon as Brief 19 is reported done
and merged. Brief 20 (GIS layers) is written but deliberately deferred until after 21 and 23.**

---

## What the tool is

**Curbside** — schematic parklet design for Vancouver streets, compliant by construction. Single-file
HTML app (`parklet-checker.html`, ~22k lines) + `index.html` landing page + `tools/serve.ps1` local
relay + Supabase auth/storage. Tabs: Site / Design / Visualize / Generate / Check / Furniture / Settings /
Export (Brief 21 reorders these). Plan, Section and 3D are three viewports over ONE design model.
Compliance runs the City of Vancouver Parklet Manual (C01–C15) and EDM 2026 continuously.

Repo: `C:\Users\bangp\Desktop\UBC\Fall_2026\ARCH 540 AI\New folder` (git, `master`, tagged releases).
Local: `tools/start.cmd` → `http://localhost:8766/` (landing page) → sign in → `parklet-checker.html`.
Never `file://`. **The server serves whichever branch is checked out** — this caused the "landing page
disappeared" confusion; keep one long-lived branch at a time and merge promptly.

**Her teacher wants it published publicly on GitHub.** Brief 21 §7 makes it safe to publish (per-user
API keys in localStorage only, own-backend config, invite-only sign-up on her hosted instance, MIT).
**She must rotate her Replicate, Anthropic and Mapillary keys the day it goes public.** Never ask her to
paste keys in chat; if one appears, tell her to revoke it immediately.

---

## Conventions that govern the code (do not relitigate)

- **One model.** `DESIGN_MODEL` (from `buildDesignModel()`) is the only source of truth. World: +X across
  street toward road, +Z along street, +Y up, right-handed; N = −Z (`CAD_CARDINAL`).
- **One mapping per view**; one palette; one drawing style (`DRAW_STYLE` + `DRAW_SYMBOLS`, Brief 17);
  one lane envelope; one materials table; one furniture archetype set (`FL_ARCHETYPES`); one tree
  archetype table (`TREE_ARCHETYPES`, keyed by genus); one generator ruleset.
- **Checks are the only compliance logic.** Don't let the LLM generate geometry; rules generate.
- **Nothing measures or renders through the live viewports except the viewports.** Report, axon
  preview/export, renders all use offscreen targets. Hidden-panel measurement has caused five bugs
  (latest: the report paginator cloning 40 blank pages).
- **Almost every bug has been one fact computed or stored in two places.** First question for any bug:
  "is this value coming from DESIGN_MODEL through the one mapping, or recomputed/stored locally?"
  Second: "is a hidden panel being measured?" This diagnosed: import "offline" message (no classifier),
  sidewalk width vs building faces, imported trees not in 3D, axon preview locking the viewport, plan
  annotation overlaps, sample report page count.
- **Verify with numbers, not screenshots.** Every brief ends with VERIFY; Claude Code reports numbers.
  VERIFY now runs at three sites: Robson & Burrard, Commercial & 1st, W 41st & Dunbar.
- **Briefs: root cause → change → VERIFY → commit, do not merge.** Jenna approves merges after looking.
  When Claude Code offers options, chat picks and explains briefly.
- Report engine is jsPDF + svg2pdf, 17 × 11 in landscape (Tabloid — NOT A3), DM Sans TTF embedded,
  vendored in `tools/vendor/`. Every drawing is SVG in mm at true scale.
- City open data: every layer is queried by the located site; datasets confirmed via the catalogue API in a
  step 0 before coding (never invent dataset ids). Data stops at the city boundary — UBC/UEL and Burnaby
  get OSM only.

---

## Branch / merge state at handoff (verify with git)

Merged on master (in order): site-map (v0.5-site), rename to Curbside, veg-3d + landing (v0.6-trees),
report-v2 with 12b amendments (v0.7-report). Briefs done and merged: 13b/13c/13d (import errors, sidewalk
from frontage, section-box toggle + context extent), 14 step 0 only (cov-objects — check whether phases
were built), 15 (landing page; index.html at `/`, `?auth=signin|signup`), 16 (trees/stops in model, A2
species archetypes, axon preview off-viewport, winter, lane badge), 12b (report makeover, sample report).

**In flight: branch `drawing-style`** — Brief 17 (engine + DRAW_STYLE, 6 commits, done), 3b + 4b
(dimensions, extents), Brief 18 (overlaps, tree/object symbols, hidden-line section, poché, placement +
move, no floating parklet window), Brief 19 (annotation LOD, 1 km city context in two rings, addresses,
procedural line-art trees, schematic layered-tree section — NO people/entourage). At handoff Brief 19 was
on step E. **Next action: Jenna reviews 19 (Fit-all of the 1 km context, line-art tree vs her references,
schematic section), approves merge → tag (v0.8-drawing), then sends Brief 21 on branch `ux` from master.**

Deferred: Brief 20 (GIS layers, revised/trimmed version below) — after 21 and 23. Brief 14 phases if not
built. GTFS, permits, ortho, LiDAR, amenities beyond bike racks: cut.

---

## Open decisions waiting on Jenna

- Railing height: model says 0.9 m, briefs said 1.1 m — must be settled before A-301 details are trusted.
- Deck level differs between Section and 3D (flagged by Claude Code in 12b report) — one number.
- `GEN.ROUTE_W` 0.92 m (BCBC) vs Parklet Manual — cite.
- C16 (disability parking space) rule text from the Manual — advisory until cited.
- Section `depthBack` (hidden-line behind the cut) — keep or drop after she sees it.
- Cover panel opacity 85% vs 92% (Brief 21 produces both).
- Schematic tree: flat fill with no outline (my choice) — hairline outline if she wants it for print.
- Whether ARCH 540 has rules about publishing coursework / instructor credit.
- A real surveyor's file to calibrate the survey code map (Brief 21 §11).

---

## Working-style notes

- Jenna judges by looking; her eye is right. When she says "warped", "weird", "AI-looking", find the
  geometric or hierarchical cause (it was FOV/blur; single lineweight; two stores).
- She wants professional drawing quality: real lineweights, hatch only at material boundaries,
  dimensions legible, warm muted schematic palette (Parklet Manual language), line-art trees (technical),
  soft translucent layered trees (schematic), no people.
- She asks "how long will this take?" — my estimates have run about double Claude Code's real pace.
  Briefs of 5–6 commits take an afternoon; the 12-commit Brief 21 is probably 6–8 h.
- She appends items to a brief over hours; keep re-issuing the whole file so she pastes one thing.
- Claude Code pauses with "1/2" questions (fonts, branch base); pre-decide likely questions in the brief.
- Her chat runs out of image budget; that is why this handoff exists.

---

# Brief 21 — Interface makeover, shape editor, user furniture, public repo, report front, Rhino export, site survey
(branch `ux` from master after 19 merge) — READY TO SEND; save as `briefs/21-ux.md`

```markdown
# Brief 21 — Interface makeover, shape editor, user furniture, public repo, report front,
Rhino export, site survey
(branch `ux` from master after 19 merge)
Run to completion without pausing. Where a decision is not made below, make the plainer
choice, log it under "Decisions I made" in the report, and continue.

Pre-decided:
- Furniture units: if the file declares units, use them. If not: bbox longest edge
  > 100 → assume mm; 10–100 → cm; ≤ 10 → m. Apply, and show the detected unit with a
  one-click switch on the import card (mm / cm / in / m) that rescales live. Never
  block on it.
- Supabase RLS: if any table has RLS off, do NOT change it. List the table and the
  policies it needs in the report; Jenna enables it in the dashboard. Same for storage
  buckets.
- Code licence: MIT.
- Report status is always PROVISIONAL; nothing in this brief introduces another status.
- Anything else ambiguous: plainer choice, log it, continue.

## 1. Audit first, as a file (commit 1: briefs/21-ux-audit.md — no code)
A. Inventory every tab, panel, button, dropdown, toggle, shortcut, context menu: label,
   tooltip, what it does, whether it works (clicked, observed), console errors.
   Mark BROKEN / PARTIAL / OK. Include Assistant, Panels menu, Settings, Print, every
   Plan/Section/3D header control, Furniture library, Generate cards, Check rows, Export.
B. First-time journey screenshots: sign in → new design → Locate → Import → Place →
   Generate → adjust → Check → Render → Export; at each step, is the next action obvious?
C. Duplicates, dead space, inconsistent terms, text < 12 px, mixed faces on one screen.
D. Shortcut table and whether each is discoverable.
Then FIX everything marked BROKEN in §A as commit 2 before any of the below.

## 2. Names and tooltips (commit 3)
Every control gets a plain label and a one-sentence tooltip (hover, 300 ms).
Rename: BOX → Section box; A–A → Section cut; DIM → Dimensions; EXTENTS → Sheet
extents; Solve width → Fit lanes to minimum; header FIT → Fit view; toolbar Fit all →
Fit design. One term per concept everywhere (UI, checks, report): "parklet" for the
whole, "deck" for the platform, "railing", "wheel stop", "planter". No abbreviations in
labels except rule IDs. Header text ≥ 12 px, mixed case; caps only for rule IDs.

## 3. Structure (commit 4)
- Tabs in use order: Site · Generate · Design · Furniture · Check · Visualize · Export.
  Settings moves under the account menu.
- Top bar: the project-name field shows the design's real name, styled as a name with a
  pencil affordance — never the placeholder "New Parklet". A "+ New" button beside it
  opens the new-design dialog (account menu keeps its entry).
- Left panel shows only what applies: with nothing selected, Selection/Grid/Move/Delta
  are hidden and the tab's own panel starts at the top. Move arrows, Δ fields and Apply
  become one "Move" block (arrows nudge by the grid step; Δ + Apply for typed moves).
- Design tab left panel: remove the bike-buffer and vegetated-buffer controls (they are
  segments in the Section editor — one place) and the Parklet length/width dropdown
  (set by the footprint). Rename the footprint section "Parklet shape editor". Buffer
  segments in the Section editor become the only way to set buffers; anything the
  removed controls wrote to (bufPKType, bufBLType, legacy globals) reads from the
  segment variants instead, so nothing is stored twice. Length/width shown read-only
  under the shape editor.
  VERIFY: set a bike buffer in Section → Plan, 3D and C-checks read it; no buffer
  control on the Design panel; changing the shape updates the read-only l × w; an old
  design with legacy buffer globals loads with the same buffers as before.
- Visualize tab: the Photoreal panel moves to the left toolbar, at the top, as its own
  block: preset buttons (Street / Sidewalk / Corner / Aerial), Render, the cached
  renders as thumbnails with tick boxes, and the Connections prompt when no key is
  set. Nothing about rendering below the fold. The sun/date controls follow it; the
  scene stays in the main area.
- Check tab: the checks are the main content. The main area shows the full compliance
  table (rule ID, title, requirement, measured, result, source, "not entered" where
  defaults apply), failures first, each row expandable to the rule text with a "show
  me" link that jumps to the relevant view with the zone highlighted. The verdict
  banner sits at the top of this area. Plan/Section/3D hidden on this tab; the left
  panel shows only filters (all / failing / provisional / passing) and the
  confirm-on-site list. Export the same: main area = Report card + Renders list,
  viewports hidden.
- The verdict banner appears only on Check and Export, never on Furniture or Design.
- Empty states: every tab with nothing to show says what to do next in one sentence
  with a button (Furniture with no design: "Place furniture from the library — go to
  Design"; Export with no site: "Locate a site first").
- Site tab as a guided sequence, not a wizard: three numbered steps — 1 Locate,
  2 Import context, 3 Place parklet — each with its status (done / next / waiting on
  the previous), all fields still editable, nothing modal.
- A "?" shortcuts panel listing every shortcut from §1D.

## 4. New design must be blank (commit 5)
pkNewDesign lands on a fully standard state built from one DEFAULT_STATE object (the
single definition of "empty"): every key reset — furniture, pkShape, site objects,
imports and caches, section box, crops, layer visibility, render selection, generator
seed; keys absent from DEFAULT_STATE are deleted, not kept.
VERIFY: with a full design open, + New → furniture 0, no imports, default section,
name = dialog name, checks all "not entered", pkSerialize hash equals a fresh sign-in's.

## 5. Section extents (commit 6)
DESIGN_MODEL.section = { z, dir, depthFwd, depthBack, x0, x1, yTop }. In Plan with the
section tool active the dashed box has four edge handles: long edges set x0/x1 (how far
into the near and far buildings the section reaches), the forward edge sets depthFwd,
the back edge depthBack (objects behind the cut draw as `fine` dashed hidden-line).
Snap 0.5 m; values shown on the handles. Section view draws exactly x0–x1 and
depthBack…depthFwd; the 18-C3 vertical auto-fit applies unless yTop is set. Report
A-201 uses the same rectangle and steps to the next scale if it doesn't fit; the plan's
section marker shows the box extent. Defaults: 5 m into each building, depthBack 0.
VERIFY: drag x1 to the far building → far façade appears cut; depthBack 6 → a tree 4 m
behind the cut appears dashed; A-201 matches the screen.

## 5b. Parklet shape editor — redesign (commit 6b)
Today the footprint editor is locked to a 19.8 × 3.8 grid and its drawing tools are
hard to control. Rebuild it as a small, obvious editor:
- Canvas: the whole parking segment between the curb and the lane edge, as long as the
  available frontage (or the full block if no frontage is set), at a zoom that fits.
  Grid = the app's grid step (0.25 m default, changeable in the editor header); the
  canvas shows metres along both edges, the curb line, the lane edge, the wheel-stop
  zones, and the host-frontage extent as a light band. The deck may not extend past
  the curb line or into the lane; it may be shorter than the frontage.
- Tools, one row, each with an icon, a name and a tooltip:
    Rectangle — drag; live l × w readout; typing numbers sets it exactly.
    Polygon — click vertices, click the first point or Enter to close; snap to grid
      and to 90°/45° with Shift; Esc cancels.
    Edit — drag vertices; drag an edge to move it parallel; double-click an edge to
      add a vertex; Delete removes a vertex; each edge shows its length while hovered
      and can be typed.
    Notch — click a corner, drag out a rectangular notch (room for a tree, hydrant or
      driveway).
    Reset to rectangle — full parking width × chosen length.
  Undo/redo (Ctrl-Z/Y) inside the editor; the shape writes to the model only on Apply.
- Constraints shown, not enforced silently: an edge outside the parking segment or a
  self-intersecting outline turns red with a one-line reason; Apply disabled until
  fixed. Minimum edge 0.25 m. The accessible route width is drawn as a dashed lane
  through the shape so the user sees when a notch pinches it.
- Everything the shape feeds — deck area, l × w readouts, railing run, wheel-stop
  positions, generator, C-checks — reads the applied polygon from DESIGN_MODEL; no
  second copy in the editor after Apply.
VERIFY: draw a 12 × 2.4 rectangle, notch 1.5 × 1.0 at one corner → area 27.3; edge
lengths readable on hover and typeable; an edge dragged past the curb turns red and
Apply disables; Ctrl-Z restores; after Apply, Plan/3D/schedule/checks all show the
notched deck with no drift; an old design's stored shape opens in the editor unchanged.

## 6. User furniture (commits 7–8)
A. Import 3D: GLB/glTF/OBJ ≤ 20 MB. Normalise to metres (pre-decided heuristic, user
   can switch), Y-up, origin bottom-centre, ≤ 50k triangles (decimate). Archetype
   fields from the bbox; plan silhouette = top projection, section silhouette = side
   projection, ≤ 300 points, drawn in DRAW_STYLE. Materials from the file if named,
   else chosen per mesh group from FL_MATERIALS. Stored in the user's Supabase bucket;
   listed under "My furniture" with source and date; schedule row "user model —
   <filename>".
B. Define from 2D: "New furniture" editor — type (seat/table/planter/screen/other,
   drives check semantics), plan outline drawn on a 50 mm grid or traced over an
   uploaded PDF/PNG/SVG/DXF underlay, then a height per region; extruded to a massing.
   No geometry is inferred from the image; the underlay is a tracing aid. A cut sheet
   may pre-fill l/d/h/material via the Assistant, each shown "suggested" until
   confirmed.
C. Both behave as full archetypes: placement, snapping, collision, C-checks, schedule,
   3D, silhouettes in report drawings; photoreal prompt describes them from type +
   dimensions + material only.
D. Library: rename, delete, duplicate, export GLB; private to the account.
VERIFY: 1.8 m bench GLB in mm → detected, l=1.80, plan silhouette matches, counts 3
seats, schedule correct. Traced chair with seat 0.45 / back 0.85 → massing at those
heights; A-103 shows the silhouette.

## 7. Public repository — per-user keys, own backend, invite-only (commit 9)
Posture: the code is public; nothing in the repo or the deployed site holds any key.
Every paid service is the user's own account, entered by them, stored only in their
browser. Jenna's hosted instance is invite-only.
- Settings (account menu) › "Connections": three rows — Replicate (photoreal renders),
  Anthropic (Assistant), Mapillary (context photos). Each: a masked key field, "Test"
  button that makes one cheap call and reports OK / invalid, "Remove", a link to where
  to get a key, and the sentence "Stored only in this browser; never sent to
  Curbside's servers or saved with your design." Keys live in localStorage under one
  namespaced object; never in Supabase, never in design state, never in exports.
- Relay: tools/serve.ps1 (and any hosted relay) stops reading .render-key. The client
  sends its key in a request header per call; the relay forwards it and never logs
  headers or bodies. The model allow-list stays. Delete .render-key handling and docs.
- Assistant: same pattern with the Anthropic key; if the request can be made directly
  from the browser with the user's key, prefer that and drop the relay hop.
- Interface when a key is missing: the Photoreal panel and the Assistant show, in
  place of their controls, "Photoreal renders use your own Replicate account. Add a
  key in Connections →" with the button; nothing greyed out silently. Site tab's
  Mapillary control the same.
- Sample report and demo renders: the sample's render sheets carry "Rendered with the
  author's Replicate account for this sample; your own renders use the key you add in
  Connections." The Export card's Renders list says the same when no key is set.
- Own-backend config: the Supabase URL and anon key move to one CONFIG block at the top
  of the file with a comment; README explains how to create a free Supabase project,
  run the schema (export it to supabase/schema.sql with the RLS policies), and paste
  the two values — so anyone can run their own copy without touching Jenna's.
- Hosted instance: sign-up requires an invite code (one code, set in a settings table
  in the Supabase project, checked server-side by the sign-up function, never in the
  client). The landing page's "Create account" says "Invite code required — contact
  <Jenna's course email>". Existing accounts unaffected. A one-line toggle turns
  invite-only off later.
- Repo hygiene before publish: scan ALL git history for key patterns (r8_, sk-ant-,
  MLY|) and report hits; README with setup (clone, run, add your keys, where to get
  them, provider pricing pages linked — no numbers invented; own-backend steps);
  LICENSE = MIT; THIRD_PARTY licences (jsPDF, svg2pdf, DM Sans OFL, MapLibre, three,
  rhino3dm); confirm Supabase RLS is on for every table and a signed-out request reads
  nothing (report only — see pre-decided); Nominatim user-agent names the repo URL.
VERIFY: fresh browser profile, no keys → every AI feature shows the Connections
prompt, nothing errors; add a Replicate key → Test passes → Render 4 works; Remove →
prompt returns; a saved design export contains no key; git history scan → 0 hits or a
list for Jenna to rotate; RLS check output; fresh clone with a different Supabase
project → sign-up, save, reload works; hosted sign-up without a code → rejected with
the message, with the code → account created.

## 8. Report: renders first, in both modes (commit 10)
Supersedes 12b's "technical = no photoreal": both reports carry the render sheets;
the modes differ only in drawing style.
- Cover: full-bleed hero image (first ticked Street or Corner render; axon if none)
  across the whole 17 × 11 sheet, with the title block as a translucent paper panel
  (about 200 × 120 mm) bottom-left: CURBSIDE wordmark, project name (large), address,
  neighbourhood, date, status stamp, checks summary. Nothing else on the cover. The
  "AI-assisted visualisation — indicative" line sits inside the panel.
- Sheet order: cover → one sheet per remaining ticked render, full-bleed (image scaled
  to cover, centre-cropped, never stretched) with a caption strip at the bottom
  (preset, camera, provider, date, Mapillary credit) and the sheet ID → drawing sheets
  → schedules → compliance → survey sheet (§11C) → sources.
- Images embedded at cached resolution, JPEG q85; four renders keep the PDF under
  15 MB. Renders must match the current design hash; the sample uses its bundled four.
- Technical mode: same render sheets; drawings stay monochrome.
- Cover panel: produce the cover twice, at 85% and 92% panel opacity, as two PNGs in
  the report for Jenna to choose from; ship with 92% until she says otherwise.
VERIFY: both PDFs open with the hero cover; pages 2–5 are the four renders edge to
edge; pdfimages lists 5 JPEGs ≥ 1500 px wide; file size reported; title-block text
extracts cleanly.

## 9. Punch list (one commit "ux: punch list")
- Furniture search input: autocomplete="off", type="search" (browser autofills the
  account email into it, leaving the library empty).
- Render cache: "Clear renders" button in Visualize › Photoreal with a count.
- Sample report has no way back: open it in an in-app overlay (or a new tab — your
  choice, logged) with a visible "← Back to Curbside" control top-right and Esc to
  close; if it stays a same-tab navigation, browser Back must return to the tool with
  the design intact. Same for the user's own report preview.
- Measure tool: snaps. While measuring, the cursor snaps (priority order, 8 px radius)
  to object vertices → object edges (perpendicular foot) → segment lines (curb, lane
  edges, frontage) → grid. The snapped point shows a marker naming what it hit ("deck
  corner", "curb", "railing post 3"). Readout: distance, Δx/Δz, the two snapped names;
  Shift locks horizontal/vertical; Esc clears; Alt disables snapping. A measurement
  stays until the next click or Esc, and can be pinned (click the readout) as a
  temporary dimension that is never saved or printed.
  VERIFY: deck corner → curb reads the model's parklet offset exactly; railing post 1
  → post 2 reads the post spacing; Alt-held measures the raw point.

## 10. Rhino export — .3dm with polysurfaces and layers (commit 11)
Add "Export to Rhino (.3dm)" beside the glTF export (glTF stays for Twinmotion/Blender).
Use rhino3dm.js (pinned, in tools/vendor/ with its licence). File units metres; the
app's world frame (+X across street, +Z along, +Y up) mapped to Rhino's Z-up on export,
right-handed, N as CAD_CARDINAL, stated in the file notes.
Geometry is built from the model's parameters, not from the three.js meshes:
- Deck: the applied shape polygon extruded to deck thickness → closed polysurface.
- Railing: posts and rails as capped cylinders / boxes from the railing archetype;
  wheel stops as boxes; planters as boxes with an inner void; glass screens as thin
  boxes.
- Furniture archetypes: each part from its primitive (box, cylinder, extruded profile)
  as a separate closed polysurface, grouped per piece; repeated pieces (same archetype
  and dimensions) as block instances (InstanceDefinition + InstanceReference) so a
  count in Rhino matches the schedule.
- Buildings: footprint extruded to height → polysurface; sidewalk, road, parking, bike
  lane segments as thin extrusions or planar surfaces with boundary curves (your
  choice, logged).
- Trees: trunk cylinder + canopy as the A2 form solid (revolved surface), one per
  tree, genus in the object name.
- Site objects (hydrants, poles, stops): simple primitives from their archetypes.
- Curves layer set: the Plan linework (curb, lane edges, frontage, section box, sheet
  crops, dimensions as curves and text dots) so the 2D drawing comes with the model.
- User-imported furniture (§6A): meshes stay meshes, on a Meshes sub-layer, named.
Layers (colours from the schematic palette):
  Parklet › Deck, Railing, Wheel stops, Planters, Furniture › <archetype name>
  Street › Sidewalk, Curb, Bike lane, Travel lanes, Parking, Opposite sidewalk
  Context › Buildings, Trees, Site objects › Hydrants, Poles, Signals, Stops, Manholes
  Drawing › Plan curves, Section box, Sheet crops, Dimensions
  Meshes › User furniture
Object names carry the schedule tag (F1, F2 …) and provenance where imported. File
notes: design name, address, date, Curbside version, axis-mapping sentence.
VERIFY: open in Rhino 8 → layer tree as above; deck is one closed polysurface with
volume = area × thickness (report both); a bench is a block with instances equal to
its schedule count; units = metres; a 1.1 m railing measures 1.1; no meshes outside
the Meshes layer; file size for the test design.

## 11. Site survey import and auto-check (commit 12)
The design's site data has three provenance levels: estimate (OSM/CoV), user-entered,
and surveyed. A survey import raises values to 'survey', re-runs every check, and
reports what changed. Three input routes, one import path:
A. Survey point file (CSV / TXT / DXF points): rows of code, x, y, z (local or lat/lon
   — user picks the frame; local frames get placed by two known points, e.g. the two
   deck corners or two hydrants). A code map with editable defaults: CURB, EOP, HYD,
   POLE, SIG, MH, CB, TREE (with DBH/species columns if present), BS, DW, BLDG, LANE,
   BL, TOC (top of curb elevation). Unknown codes are listed, not dropped. Import
   previews every point on the Plan in a distinct colour before applying.
B. Survey DXF linework: polylines on named layers; the same code map keyed by layer
   name; curb and lane lines replace the segment edges within the surveyed extent.
C. The tool's own survey sheet: the report gains an S-002 "Site survey" sheet listing
   every confirm-on-site item with its current value and a blank measured column; a
   matching form in the Site tab (or a CSV template download) lets the user type
   measured values back in. Same import path, provenance 'survey'.
Apply rules:
- Each surveyed feature is matched to an existing imported feature within a tolerance
  (0.5 m objects, 0.3 m lines); matched → value updated, provenance 'survey', estimate
  kept in history; unmatched → added as new, flagged; imported features with no survey
  counterpart inside the surveyed extent → flagged "not found on site" (not deleted).
- Segment widths recomputed from surveyed curb and lane lines; curb-to-curb becomes
  measured; grade from TOC points when present.
- Nothing outside the surveyed extent changes.
Auto-check:
- Every C-check re-runs; a "Survey" panel on the Check tab shows, per check: before
  (estimate) → after (survey), result change, and which surveyed points drove it.
  Confirm-on-site items whose value came from the survey are cleared. Status stays
  PROVISIONAL in all cases; the cover's checks line adds "N of M inputs surveyed" and
  the Sources sheet carries the survey facts (date, surveyor free text, file, frame,
  point count, placement points).
VERIFY: on the test design, import a CSV with 20 coded points (curb ×4, HYD, POLE ×2,
TREE ×3 with DBH, LANE ×6, BS, TOC ×3) in a local frame placed by two deck corners →
preview matches; apply → sidewalk width becomes the surveyed value, provenance
'survey'; C05 changes to the measured distance; one imported tree not in the file is
flagged; status reads PROVISIONAL with "12 of 14 inputs surveyed"; Sources lists the
file; undo restores the estimates.

## Report
Audit counts (controls, BROKEN, PARTIAL); before/after screenshots of every tab at
1440 px; the two cover PNGs; a Rhino screenshot of the layer tree; "Decisions I made";
all VERIFY results; git history scan result; RLS findings; the invite code location.
Do not merge.
```

**In the morning after Brief 21:** rotate the three keys; check the invite code is where the report says;
look at the two covers; review the audit's "Decisions I made"; approve merge → tag v0.9-ux.

---

# Brief 23 — Stranger test (after 21 merge) — READY TO SEND; save as `briefs/23-stranger-test.md`

Run only after any RLS findings from Brief 21 are fixed in the Supabase dashboard (persona 6 probes the
live project).

```markdown
# Brief 23 — Stranger test (after 21 merge; branch `stranger-test`, findings only)

Spawn six independent subagents. Each gets ONLY: the hosted URL, one invite code, one
fresh test account (stranger1@… etc., created by the parent), a fresh browser profile
(Playwright, 1440 × 900, one on 390 × 844), and its persona paragraph below. No access
to the repository, HANDOFF, briefs, or any other agent's output. They may not read
source; only what the site shows. Each has 45 minutes and must produce
briefs/23-findings/<persona>.md: every problem as {steps to reproduce, expected,
actual, screenshot, severity: blocker / major / minor / cosmetic}, plus "three things
that were confusing" and "three things that worked well". They must attempt the whole
journey (sign in → new design → site → import → place → generate → design → furniture →
check → report), and try to break each step (empty fields, huge values, back button,
reload mid-task, two tabs open, sign out mid-edit).

Personas:
1. Café owner, no design background, wants a parklet outside their shop on Main St.
   Has never seen a section drawing.
2. City of Vancouver reviewer checking whether the report would be acceptable as a
   pre-application; reads every number and every source line.
3. Landscape architect who will take the Rhino export into their own drawings; cares
   about layers, units, dimensions, drawing conventions.
4. Mobile user (390 × 844) trying to do everything on a phone.
5. Accessibility tester: keyboard only, no mouse; then screen reader (report what
   the accessibility tree exposes); colour-contrast check on every screen.
6. Adversarial: tries to see other users' designs, put scripts in the project name,
   upload a 200 MB "furniture" file, spam the import, paste a fake API key, open the
   sample report and edit the URL, exhaust the invite code.

Parent, after all six finish: merge findings, de-duplicate, rank by severity × how many
agents hit it, and write briefs/23-triage.md as a proposed fix list — no code. Delete
the six test accounts and their data; report the Supabase storage used during the test.
```

Chat then turns `23-triage.md` into Brief 24 (fixes) with Jenna choosing what to fix.

---

# Brief 20 — GIS layers (DEFERRED until after 21 and 23) — save as `briefs/20-gis-layers.md`

Trimmed version (traffic counts, collisions, fountains/washrooms, orthophoto, GTFS, permits, extra 3D
all cut). Branch `gis-layers` from master.

```markdown
# Brief 20 — GIS layers: registry, Layers panel, regulatory + frontage + terrain

## 0. Step 0 — catalogue check (report, then continue without waiting)
For each layer in §3–§5 confirm on the City catalogue: dataset id, geometry field, key
fields, row count, update cadence. Also record, without building them, whether datasets
exist for street-use permits, patio permits, and GTFS-derived stops — deferred; note in
HANDOFF. Mark each built layer FETCHABLE or NOT-FEASIBLE with one line why.

## 1. One layer registry (commit 1)
GIS_LAYERS = [ { id, title, group, source: {provider, dataset, fields, radius, cadence},
  store: 'DESIGN_MODEL.<path>', tier: 'inner'|'outer', lod: far|mid|near,
  plan: symbolId | fill, section: symbolId | null, three: geometryFn | null,
  label: fieldFn | null, checks: [ruleIds], report: rowFn | null, default: on|off } ]
A layer is fetched by SMP as one runStep with its own cache key and 13b failure
reporting; stored under its model path with {source, dataset, id, fetchedAt} per
feature; drawn by Plan/Section/3D from the registry entry; listed in the Layers panel
from the registry; written to the Sources sheet from the registry. Adding a layer = one
entry + at most one symbol function. Migrate existing layers INTO the registry first
(trees, hydrants, stops, buildings, bikeways, poles, signals, manholes, catch basins,
footprints, streets, addresses, parks, shoreline); behaviour must not change.
VERIFY: per-layer counts and Plan/Section/3D screenshots identical before/after at
all three sites; no drift.

## 2. Layers panel (commit 2)
"LAYERS" button beside Sheet extents in the Plan/Section/3D header opens a docked
panel: groups Context, Street furniture, Utilities, Transit, Regulatory, Terrain. Per
layer: eye toggle (all three views), count within the model extent, source + fetched
date, "confirm on site" mark, refetch. Group toggles. Visibility per design (saved),
never affects checks or the Sources sheet; a hidden layer feeding a check shows "used
by C0x". Drawing sheets include only visible layers; Sources names hidden ones.
VERIFY: toggle hides in all views within one frame; checks unchanged; reload restores;
report lists hidden layers.

## 3. Phase A — regulatory (commit 3)
- parking-meters (block level): plan meter symbol per block face at near tier, label
  rate + time limit; site form "metered parking" auto-set with provenance; report row.
- disability-parking: plan symbol; new check C16 "parklet does not displace a
  designated disability space" — distance and overlap, wording "advisory — rule not
  yet cited from the Manual" until Jenna supplies it.
- zoning-districts: label per inner-ring building at mid tier; site table + report.
- local-area-boundary: neighbourhood on the cover; sites outside the city boundary get
  every City layer marked "not available here" and a one-line Site tab notice.
- bike racks: plan symbol at near tier; report count within 50 m.

## 4. Phase B — host frontage (commit 4)
- business-licences: licence type + business name by civic address, matched to the
  host frontage building (shown for other inner-ring buildings at near tier under the
  address). Site table: host business, licence status, year; report row "1234 Robson
  St — <business>, <type>, licence <status>". Query by street + civic range only.

## 5. Phase C — terrain (commit 5)
- elevation contours: sample grade along the parklet and across the section;
  DESIGN_MODEL.site.grade {along %, cross %} with provenance. Section ground follows
  the grade; deck stays level with levelling height dimensioned at each end. 3D ground
  tilts within the inner ring. Plan contours `fine` dashed at mid/near, labelled at near.
- building heights: if a City dataset carries a height field, use it (provenance
  'cov'); otherwise NOT-FEASIBLE, logged.

## 6. Labels
Plan labels obey the 19-A tiers and the collision pass. 3D labels only for addresses
and business names within 60 m. No new 3D geometry in this brief.

## VERIFY (each phase, three sites)
Per layer: fetch time, count, provenance date; panel round-trip; Sources row.
A: C16 shows a distance near a disability space; a block's meter label matches the
portal. B: host business on the cover matches the dataset. C: section slope equals
the sampled grade; levelling heights dimensioned; a downtown building's height cites
the City source when available. A pre-brief design loads unchanged.
Commits 1–2, pause for review. Commits 3–5, pause. Do not merge.
```

---

## Numbers still waiting on Jenna (chat must not invent)

- `GEN.ROUTE_W` (Parklet Manual accessible route width) — currently 0.92 m (BCBC 3.8).
- Street-tree clearance — advisory until a Manual page gives a number.
- `SE_TYPES` non-lane segment min/max sources — cite or mark "UI envelope".
- Nano Banana Pro per-image price (her Replicate dashboard).
- C16 disability-space rule text.
- Railing height 0.9 vs 1.1 m; deck level.
