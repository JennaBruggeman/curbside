# Brief 30 — Friday round: site picker, site-facts gate, simpler shape editor, materials, Parklets 101, assistant, carry-overs, UI pass
(branch `friday-round` from master after the code freeze lifts; v0.17.2 is the base)

Run to completion without pausing. Where a decision is not made below, make the plainer
choice, log it under "Decisions I made" in the report, and continue. One commit per
distinct change. Do not merge. Sections are ordered by what users meet first; the
structural sections (§9 onward) come last so the rest can merge if they overrun.

Read first: `docs/process/HANDOFF.md`, `docs/process/HANDOFF_SESSION_7.md`,
`docs/process/HANDOFF_SESSION_7b.md`, `docs/process/23-triage.md` (three tables), and the
peer-review issues on the repo ("Review: <name>").

Conventions that still govern: one fact one store (`DESIGN_MODEL`); one mapping per view;
checks are the only compliance logic; the LLM never writes geometry; nothing measures
through a hidden panel; verify with numbers; `checkLandmarkConsistency()` silent after
every sync.

Pre-decided:
- Basemap: CARTO Positron style JSON via MapLibre, keyless, attribution kept. If its
  terms do not suit a public tool, OpenFreeMap "positron". One `CONFIG.MAP_STYLE`.
- Picker dots: one grey for every point layer, trees one muted green; type on hover only.
- Site facts gate is HARD (like the Vancouver-street / blank-street opening choice):
  nothing past Site facts opens until every card has an answer. "Estimate" and
  "Don't know yet" are always available, so no one is ever stuck.
- Provenance set after this brief: `imported` (unconfirmed), `estimate`, `measured`,
  `unknown`. `survey` loads as `measured`. Typed values are measured only when the user
  says so (supersedes 29c-2).
- Shape editor: rectangle + optional 45° corner chamfers. Nothing else.
- Cost rates: two shipped rate sets. "City of Vancouver — Parklet Manual 2016, CAD"
  (fees p. 37/41, construction range p. 18; every row dated 2016 and flagged "confirm
  with the City") and "Placeholder — Parkade guide, USD, 2024 retail" (every row tagged
  `placeholder`). CAD conversion rate user-set, default 1.35, shown. No other City
  numbers invented. Furniture never priced silently.
- Assistant: direct browser calls with the user's Anthropic key (Brief 21 §7 posture);
  the Supabase edge function stays optional. Default model string stays the current
  Sonnet. Agents never use Jenna's key; Playwright runs against a mocked endpoint.
- Impeccable (§12): `DRAW_STYLE`, `DRAW_SYMBOLS`, the three renderers and the report
  engine are out of its scope. Any diff touching them in §12 is reverted.
- Anything else ambiguous: plainer choice, log it, continue.

## Removed from scope (commit 0: docs only)
Delete these from the Brief 30 lists in `HANDOFF.md` and `HANDOFF_SESSION_7.md`, with a
one-line reason each:
- Full-city 3D (25-24): not needed.
- Survey CSV validation: the survey import itself is removed (§10).
- Any remaining "notch" or free-polygon work on the shape editor (§3 replaces it).

---

## 1. Site picker: monochrome basemap, crisp linework, quieter dots (commits 1–3)
Root cause: the picker uses the default OSM raster tiles (general-purpose, every POI and
land-use fill, blurry at fractional zooms and on high-DPI) and draws every layer point at
full size and saturation at every zoom, so the street the user must click is buried.

- Basemap (commit 1): MapLibre vector style from `CONFIG.MAP_STYLE` (pre-decided).
  Building footprints light grey, roads thin grey casings, parks palest green/grey,
  labels only, no POI icons or shields. Attribution "© OpenStreetMap contributors
  © CARTO" (or OpenFreeMap's) always visible.
- Layer dots (commit 2): one marker style derived from `DRAW_STYLE`. Radius 4 px at zoom
  ≤ 15, 6 px at 16–17, 8 px above; grey with a 1 px white halo, trees muted green; hover
  enlarges and labels; selected is the only saturated colour. Below zoom 15 point layers
  are hidden and the panel reads "Zoom in to see site features". Line layers (bikeways,
  bus routes) draw as thin dashed grey overlays.
- Street pick (commit 3): while a street pick is awaited, the hovered street segment
  highlights (one accent, 3 px) so the click target is visible; dots are
  non-interactive during the pick (closes triage row "side-of-street click opens a tree
  popup"); popups return after the pick.
VERIFY: picker at Robson & Burrard at zoom 15, 16, 17, before/after, 1× and 2× DPR;
visible marker count per zoom; the pick works at the five sites; blank street
unaffected; attribution present; console shows no tile errors; a design saved before
the change opens on the same site.

## 2. "Where could a parklet go?" overlay on the picker (commits 4–5)
Root cause: the user picks a block and only then learns it is a bus zone or has no
parking lane (both Main St and Denman runs). The City publishes no eligibility layer, but
every hard exclusion is computable from the curbside-data cells before the click.
- Step 0 (report, then continue): query the City catalogue for parklet, patio and
  street-use permit datasets. If one exists, draw existing parklets as a separate point
  layer with its own symbol. Never invent dataset ids.
- Data (commit 4, in `curbside-data`): for every block face with a parking segment, run
  the cell-only exclusions — C01 bus stop within the deck zone, bike lane in the parking
  position, C03 corner setback 6 m, C05 hydrant 5 m, lane-width envelope from lane
  count and route type — and write `eligibility: eligible-estimate | excluded |
  needs-measurement` with `reasons: [bus_zone, no_parking_lane, bike_lane, corner,
  hydrant, lane_width_estimate]` into a new `blockfaces` layer in the cell. Weekly
  Action builds it.
- App (commit 5): a thin band along the curb line in three tones from the §1 palette
  (muted green, grey, hatched grey); Layers-panel toggle, on by default at zoom ≥ 15;
  legend line "Estimate from City and OSM data — confirm on site". Hover shows the
  reasons in plain words ("Bus stop 4 m along this face"). Clicking an excluded face is
  allowed; the reason shows on the pick card. No eligibility logic lives in the app; the
  checks remain the only compliance code once a site is chosen.
VERIFY: Robson & Burrard, Main 2000/2500, Denman at Davie, W 4th at Yew, Dunsmuir at
Richards — each face's band and reasons against the Check tab after import at the same
face, no contradictions; a face with a bus stop reads excluded and names the stop;
eligible/excluded/needs-measurement counts per cell logged; toggle off cleanly; the
weekly Action completes without timeout.

## 3. Shape editor: rectangle with optional 45° corners (commit 6)
Root cause: the Brief 21 §5b editor (rectangle, free polygon, vertex edit, notch) solves a
problem parklets rarely have. Real parklets are rectangles in a parking lane; the one
non-rectangular move worth supporting is a 45° cut at a corner.
- Keep Rectangle (drag, or type l × w). Add a corner handle at each of the four corners
  that drags inward along the diagonal to make a 45° chamfer, leg length shown and
  typeable, snap to the grid step.
- Remove Polygon, Notch and free-vertex Edit from the toolbar, the `?` shortcuts panel
  and Help. Any edge that is not at 0°, 45°, 90° or 135° to the curb is impossible to
  draw; the validation list includes the reason text anyway for old shapes.
- Length and width remain the rectangle's envelope; the applied outline is still a
  polygon (4–8 vertices) in `DESIGN_MODEL.parklet.shape`, so nothing downstream changes
  shape.
- Older designs with a free polygon or a notch load and draw unchanged; the editor shows
  "This shape was drawn with an older tool" and offers "Convert to rectangle" (bounding
  rectangle). The user decides.
VERIFY: 12 × 2.4 rectangle, chamfer both traffic-side corners by 0.6 m → area 27.99;
Plan/Section/3D/schedule/Rhino agree; a 2026-09 notched design loads unchanged with the
notice; Polygon and Notch absent from UI and `?`; Brief 21's rectangle VERIFY passes.

## 4. Placing furniture in the 3D view: drag, Place, touch (commit 7)
Root cause (confirm and report): dropping a library card on the 3D canvas does nothing;
"Place" arms a placement only the Plan's click handler completes. Plan and 3D have
separate placement paths and only one works.
- One function `placeFurnitureAtWorld(key, x, z)` used by every entry point: card dropped
  on the Plan (`planToWorld`); card dropped on the 3D canvas (raycast from the drop point
  onto the deck plane at deck height; a miss lands at the nearest deck point and says
  so); Place button (arms placement; a click on the deck in Plan OR 3D completes it;
  cursor changes; hint under the card "Click the deck in the Plan or 3D view to place
  it"; Esc cancels); touch (tap the card, tap the deck).
- The function snaps to the grid step, keeps the piece inside the applied polygon, calls
  `_dmSyncObject` + `syncDesignModel('furniture')`, and triggers a save (closes persona
  6's "placing alone does not save"). The piece is selected afterwards.
- Dragging a placed piece in 3D: OrbitControls disabled while grabbed, raycast onto the
  deck plane, same `moveFurnitureWorld` path as the Plan drag.
VERIFY: drop a bench onto the 3D deck at the five sites → same world position in
Plan/Section/3D (numbers logged), consistency check silent, piece survives a reload with
no tab switch; Place → click in 3D places; Place → Esc cancels; a drop beside the deck
lands on the nearest edge with the message; touch mode (Playwright `hasTouch`,
1024 × 768) tap-card then tap-deck places; 3D drag moves the Plan piece and the camera
does not orbit.

## 5. Parklet materials: real, and in Design (commit 8)
Root cause (confirm): the Generate tab's material choice writes a generator option that
only touches card text or the photoreal prompt; the deck, enclosure, planter meshes and
2D fills read fixed `FL_MATERIALS` entries. Same fact in two places, one decorative.
- `DESIGN_MODEL.parklet.materials` is the single store, one role per part: deck surface,
  deck edge/fascia, enclosure posts, enclosure infill (pickets / glass / planter wall),
  planter boxes, screens. Each role is an `FL_MATERIALS` entry (one palette with
  furniture).
- Design tab left panel gains "Materials": swatch rows identical to the furniture
  Selection panel's, plus presets at the top (Cedar + galvanised steel; Composite + black
  steel; Painted timber; one more of your choice) that set all roles.
- Generate's control becomes the same preset picker over the same store. Generated
  schemes carry a preset but never override a user's Design choice unless the scheme is
  opened.
- Readers: 3D (`flMat`), Plan and Section fills/hatch via `DRAW_STYLE` (schematic tint
  from the material; technical hatch only at material boundaries), A-103 schedule,
  Rhino/glTF layer colours and names, photoreal material sentence. Delete the old
  generator option and every hard-coded parklet colour.
- Designs without a materials block load today's defaults; nothing changes visually
  until touched.
VERIFY: deck → composite grey in Design: 3D, Plan tint, Section, A-103 row, Rhino layer
colour and the prompt sentence change in one sync (log each); change in Generate →
Design shows it; open a generated scheme → its preset applies; a 2026-09 design loads
with today's look; consistency check silent at the five sites.

## 6. Parklets 101 tab: build-up, quantities, cost estimate, materials (commits 9–12)
Root cause: the tool checks a design and says nothing about how it is built or what it
costs — the first question a café owner asks and the first gap a reviewer sees.
A new top-level tab after Export (reference, not a step in the strip). Sources are
paraphrased with a Sources list in the tab; no third-party PDFs or images in the repo;
the Vancouver Parklet Manual is the authority wherever it speaks, the others are "how
other cities do it". Sources: Vancouver Parklet Manual; San Francisco Parklet Manual
v2.2 (2015); NACTO Urban Street Design Guide, Parklets; Parkade "Complete guide to
parklets" (2024); Cincinnati Parklet Program Guidelines (Feb 2025); Toronto CaféTO
council report (2023).

A. Build-up (commit 9): an annotated exploded section of the generic parklet, one SVG in
`DRAW_STYLE`, drawn from the design's own deck width and curb height (never a stock
picture): road crown, levelling pedestals or tapered sleepers, joists, deck, fascia,
enclosure, planter, City wheel stop and bollard, drainage gap at the curb with end
screens. Per layer: what it does, the Manual's rule (page), what SF and NACTO add, usual
materials and trade-offs. Facts to carry (paraphrased, cited): SF — platform flush with
the sidewalk, gap ≤ ½ in, no component over 200 lb/sq ft, no structural rebar in a
concrete base, drainage not impeded, end openings screened, railings 36–42 in with
openings ≤ 4 in; NACTO — design load 100 lb/sq ft, slip-resistant surface, flush
transition, pedestal or steel substructure for the crown, drainage channels between base
and platform, winter removal where plows run; Parkade — level base on adjustable
pedestals or tapered beams, framing, decking, barrier, delineators, wheel stops, check
drains first. Levelling height at each end reads the model (flush-with-curb assumption
stated until grade data exists).

B. Quantities (commit 10): a take-off from `DESIGN_MODEL` only: deck area and perimeter;
joist/sleeper run from the deck polygon at a stated spacing (400 mm default, editable);
decking area with a waste factor (10 % default, editable); enclosure run and post count
per type from §9's edge runs; planter count and volume; screens; furniture from the
schedule (one row per schedule tag, grouped by identical archetype + dimensions +
materials, count × unit); City-supplied items listed "supplied by the City, no cost to
applicant" (Manual p. 48/59). Every line shows its formula on hover.

C. Cost estimate (commit 11): quantities × a unit-rate table. Rate sets: ships with
"Placeholder — US retail, Parkade guide 2024, USD" (its itemised rows: 2×4 lumber,
OSB, rubber parking blocks, delineators, railing lumber), every row tagged
`placeholder`; CAD at a user-set rate (default 1.35, shown). The user adds rate sets
("My quote — <supplier>, <date>") and edits any rate; low/high per rate, so the total
is a range. Banner: "Estimate from placeholder rates" until every rate used is
user-entered, then "Estimate from your rates". Permit and inspection fees: one line
"City of Vancouver fees — enter from the current fee schedule" with a link, no number.
Furniture rows: presets ship with no number and a "Price on request — <manufacturer>
product page" link from the catalogue entry; generic archetypes no number and the hint
"Enter a quote, or compare a similar catalogue product"; user-imported furniture carries
its spec-card value; the assistant (§7) may prefill from a pasted cut sheet, shown
"suggested" until confirmed. Unpriced rows show "—" and the banner adds "Furniture not
priced (n pieces)"; they never count as zero. A rate entered for an archetype persists
in the rate set, so the next identical piece inherits it. New report sheet G-002
"Construction and budget" prints quantities, the rate set's name and provenance, the
range, the unpriced count; the Sources sheet names the rate set. Nothing in Generate or
the checks reads costs. A-103 does not change.

D. Materials (commit 12): one table joining `FL_MATERIALS` to the primer: durability,
maintenance, SF's prohibitions as advisory ("SF does not allow visible pressure-treated
lumber; tropical hardwood and virgin redwood not allowed; plastics strongly
discouraged"), a Vancouver column left blank where the Manual is silent; each row links
to Design › Materials (§5).

VERIFY: 7-piece test design → deck area equals the shape's area; railing run equals §9's
schedule figure; post count equals the 3D post count; seven furniture rows all "—",
banner "Furniture not priced (7 pieces)"; enter a bench quote → its row prices, count
drops to 6, G-002 shows the row with its source; duplicate the bench → count and
subtotal double; delete → row leaves; change deck width → every quantity and the exploded
section update in one sync; placeholder USD total equals the hand sum of the Parkade
rows for the same quantities (log it); switching to a user rate set changes the banner;
G-002 appears in both report modes; the tab renders on the blank street with quantities
at zero and the primer readable; a design export contains the rate set and no key.

## 7. Design assistant in the Generate panel (commit 13)
Root cause: the R10 assistant (`AX`) is hidden behind a canvas-toolbar toggle outside
any tab, its no-key state is the generic prompt, its ops predate enclosure types,
materials, the new shape editor, the site-facts gate and the generator patterns, and it
has not been run against a real key since the Connections refactor.
- Becomes the last block of the Generate tab's left panel, "Design assistant". No key:
  "The assistant uses your own Anthropic account. Add a key in Connections →", one
  button, nothing greyed. With a key: chat box, three starter prompts ("Lay out seating
  for 8 with a planter edge", "Why does C02 fail here?", "Make it feel more like a
  garden"), the conversation. "Test" in Connections makes one cheap call.
- Tools rebuilt from the model: `run_generator(pattern, constraints)` (rules make the
  geometry; the model picks pattern and constraints and writes the rationale),
  `set_materials(roles)`, `set_enclosure(side, type)`, `set_deck(l, w, chamfers)`, the
  existing furniture and site-object ops, `explain_check(id)` (restates the measured
  values and rule text only), `read_design()`. It cannot write provenance, cannot
  bypass the gate (§9), never writes geometry beyond furniture positions clamped inside
  the deck.
- Every applied change is a diff card (before → after, which checks changed) with Undo;
  undo stack of 10. System prompt: Manual rule summaries, coordinate conventions, a
  trimmed `DESIGN_MODEL` snapshot (no cell data). Nothing from the assistant appears in
  the report; no usage logged anywhere but the user's console. Delete the old toolbar
  toggle.
VERIFY (Jenna's key, her browser, once; agents use a mocked endpoint): fresh profile →
Connections prompt; add key → Test passes → "Lay out seating for 6 and a planter on the
traffic side" runs `run_generator`, diff card lists changes, checks re-run, Undo
restores exactly (pkSerialize hash equal); "Why does C02 fail?" answers with numbers and
page and changes nothing; "mark the hydrant distance as measured" is refused with the
sentence pointing to Site facts; a bad key gives one clear error; a design export holds
no key and no chat; mocked run at the five sites.

## 8. Carry-overs from the review period (one commit per group)
A. Peer-review issues on the repo: each fixed-and-retested or answered in its thread,
   then closed (never deleted). List them with outcomes in the report.
B. Already logged for Brief 30 (`HANDOFF_SESSION_7.md`): persona 7 touch re-run (after
   §4); hosted photoreal relay; C03 not reading the map corner; two-tab last-save-wins
   (last writer warns, offers reload or overwrite); the five access gaps (no signed-out
   entry, no keyboard site pick, no touch drags, left panel won't scroll at 200 %,
   forced-colours states); Duplicate makes an empty copy; Section Undo after import
   rolls back the import; README step 7 wording; sample renders show the old 2.5 m
   umbrella and the sample report's reference design fails C19 — re-render the sample
   with the 2.60 m umbrella and regenerate the bundled PDFs so the sample passes again;
   in-app report viewer clips the notes column (`#view=Fit`); render-to-account test
   (needs one real render by Jenna, second browser).
C. `docs/process/23-triage.md`: every row in the three tables not yet marked done,
   including at least: PDF export and "+ New" freezing the page (build in yielding steps
   or a worker, sheet-by-sheet progress line); keystroke loss when a Check row regroups
   (moot for values once §9 lands — cards replace in-row fields — but the regrouping
   jump must still go); "Near lanes = 0" accepted and ignored; "NaN m" in a compliance
   message; Check values typed for one site surviving a move to another site (clear on
   site change, with a notice); "Add segment" doing nothing when the roadway is fully
   allocated (say why, offer to shrink a lane); opening a generated scheme wiping the
   imported context and flipping C02 to Pass; C01 not following a shortened deck and one
   stop listed at two positions; static "Unknown …" site-condition text above a set
   dropdown (C01, C05); "Nothing imported to confirm" above a count; bearing shown with
   float noise; "Over 0.002 m" rounding flagged red; UTC import dates; header overflow
   below 1360 px (with §12); sign-in dialog focus trap and no close; dead A-101 note 3
   genus reference; dimension strings that do not close (3.164 rounded per segment);
   deck 2.65 m wider than the Manual's 2.3–2.5 m guidance with nothing flagging it
   (advisory line on C02's row, Manual p. 20); file name carries no address when two
   designs are both "Untitled parklet".
VERIFY: per item, the triage row's reproduction steps re-run at its site and the result
logged; the page's longest unresponsive stretch during export at Robson ≤ 1 s between
progress updates; sample report banner shows every check passing.

---

## 9. Site facts as a hard-gated card sequence (commits 14–16) — structural
Root cause: after import the user lands in a CAD workspace with the site facts scattered
across Check rows and the Site panel; facts get typed mid-design, Generate refuses in
code words, "confirm 88 items one by one", and nothing records whether a number was
measured or guessed, so a guess produces a Pass (29c-2).
- A new step between Import and Design, "Site facts", in the step strip (Site → Site
  facts → Design → Access → Check → Export). Opens automatically when the import
  finishes, and from "Review site facts" on the Site panel at any time. On the blank
  street the same cards run with no prefills and "Don't know yet" preselected.
- One card per site fact in rule order, one at a time, progress line ("4 of 14"), Back /
  Next. Each card: the question in plain words (rule ID small), the prefilled value with
  its source named ("From the City's hydrant layer: nearest hydrant 21.5 m from the
  deck"), an input to confirm or change it, a "why this matters" line, the relevant map
  or Plan crop beside it, and one required provenance choice: "Measured on site",
  "Estimate", "Don't know yet". Groups of imported objects (trees, poles) get one card
  per group with "confirm all" and per-item exceptions — this replaces the 88-item list.
- Provenance drives every result, no exceptions: measured → Pass/Fail; estimate →
  Provisional pass/fail, shown as estimate; unknown → Awaiting measurement. X-001, S-002,
  the cover line ("N of M inputs measured") and the Check tab read one field; nothing
  stored twice. Existing designs: imported values stay `imported`; values typed before
  this change load as `estimate` (the safer reading) and the user is told once.
- Hard gate: Design, Generate, Access, Check and Export stay locked, step strip greyed
  past Site facts, until every card has an answer. Reload mid-sequence returns to the
  same card. Editing a value from Check later reopens its card inline (no in-row field,
  so the regrouping keystroke bug cannot recur).
- A "I've measured on site" button on the Site panel reopens the cards with "Measured
  on site" preselected (the print-measure-enter loop with S-002).
VERIFY: five sites + blank street: import → cards open with the right prefills and
sources; C05 as measured 7.0 → Pass; as estimate → Provisional; unknown → Awaiting; the
cover and X-001 reflect each; a 2026-09 design with typed facts loads them as estimate
with one notice; with one card unanswered every tab past Site facts is locked and says
why; reload returns to the same card; Generate refuses only while a card is unanswered
and names it in plain words; "confirm all" confirms 31 trees in one click; typing "17"
in any card gives 17.

## 10. Remove the survey file import (commit 17) — depends on §9
Root cause: Brief 21 §11 A–B (CSV/TXT/DXF points, DXF linework, code maps, two-point
placement, matching) is a lot of code for a path almost nobody takes, and its one real
test produced a wrong pass. §9 gives "measured" directly.
- Delete: the Site › Survey upload controls, code map, DXF layer mapping, point preview
  layer, matching/apply rules, the Check › Survey panel, and their help text. `survey`
  provenance loads as `measured`, logged once.
- Keep: S-002 "Site survey" as a print-and-measure checklist (every site fact, current
  value, source, blank measured column); the §9 "I've measured on site" button; the
  Sources sheet line "Measured on site by the applicant, <date>" when any fact is
  measured. README loses step 7's survey sentence.
VERIFY: controls gone from UI, `?` and HTML (grep function names, 0 live references);
S-002 prints at the five sites; the Site button reopens the cards with Measured
preselected and values flow to Pass/Fail; a design with `survey` provenance loads as
measured with one console line; `parklet-checker.html` size before/after.

## 11. Enclosure follows the applied shape (commit 18) — structural
Root cause: the enclosure (railing, planter wall, screens; Brief 21b §12) is generated
from the rectangle's l × w, not the applied polygon, so after a chamfer the railing runs
along the old outline. The outline is stored once and recomputed separately.
- Build the enclosure from the applied polygon's edges, one run per edge, classified by
  the side each edge faces: traffic side (along the lane edge), ends (perpendicular to
  the curb at the extremes), curb side (open unless a planter is chosen), chamfers
  (inherit the type of the side they join; a post at each vertex, rails mitred).
- Posts set out from each run's own length (spacing from the archetype, end posts at
  vertices). C18 openings stay on the curb side; C17 height and C19 overhead read the
  same runs. The edge list feeds the Plan silhouette, the Section cut (a railing cut
  wherever the section line crosses a run), 3D, the schedule's railing length, §6's
  quantities, and the Rhino/glTF exports. Delete the rectangle-based enclosure code.
- Wheel stops and City bollards position from the polygon's traffic-side extent.
VERIFY: 12 × 2.4 with both traffic-side corners chamfered 0.6 m → mitred rails, a post
at each chamfer vertex, schedule railing length equals the sum of enclosed edges (report
the number), Plan/Section/3D agree, consistency check silent; a design saved before this
change loads with the same enclosure; Rhino railing block count equals the schedule.

## 12. UI pass with Impeccable (commits 19–27) — last
Install `pbakaus/impeccable` in Claude Code (`/plugin marketplace add pbakaus/impeccable`,
then install from `/plugin`). Local server `tools/start.cmd` serves 8766 for live mode.
- Commit 19: `docs/PRODUCT.md` from `init`. Pre-decided answers: audience café/shop
  owners, BIA staff, students, City reviewers; voice plain and brief; constraints
  single-file app, no build step, drawings governed by `DRAW_STYLE` and out of scope.
- Commit 20: `docs/DESIGN.md` from `document`, reconciled with the existing UI tokens
  (one face, 12 px minimum, mixed-case labels, rule IDs the only caps), with an "Out of
  scope" section naming the canvases and sheets.
- Commit 21: `audit` and `critique` on every tab at 1280 × 800, 1440 × 900 and
  1024 × 768 touch → `briefs/30-ui-audit.md`, findings with severity, no code.
- Commits 22–26: `adapt`, `layout`, `typeset`, `clarify`, `onboard`, one each, limited
  to the audit's findings; copy changes follow Brief 21 §2's one-term-per-concept list.
- Commit 27: `polish`; detectors run clean (exit 0) as a step in the pre-push hook.
- Skip `bolder`, `delight`, `overdrive`, `animate`.
VERIFY: detector exit 0; header fits at 1280 × 800 with "+ New", "?" and the account
menu reachable; sign-in dialog takes focus, Escape closes it, Tab stays inside;
before/after screenshots of every tab at the three widths; text < 12 px count = 0; the
five sites + blank street render identically in Plan/Section/3D before and after §12
(pixel diff of the canvases = 0).

---

## VERIFY sites (every section)
Robson & Burrard · Commercial & 1st · W 41st & Dunbar · W 4th at Yew · Main 2000/2500
block · blank street. Demo address Main St & E 26th Ave for anything touching import.

## Report
Per section: VERIFY results as numbers; "Decisions I made"; screenshots named by
section; file size of `parklet-checker.html` at start and end; the step-0 catalogue
result (§2); peer-review issue list with outcomes (§8A); the triage rows closed (§8C);
§7 and §8B items that need Jenna (her key, a real render) listed under "Needs Jenna".
Update `docs/process/HANDOFF.md` and write `docs/process/HANDOFF_SESSION_8.md`.
Do not merge.
