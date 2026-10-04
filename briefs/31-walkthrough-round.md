# Brief 31 — Walkthrough round: navigation, picker, drawings, cost estimate, Check cards, blank street
(branch `walkthrough-round` from `friday-round`; nothing has been merged or pushed, master
is still v0.17.2 and stays so until Jenna says otherwise)

Run to completion without pausing. Where a decision is not made below, make the plainer
choice, log it under "Decisions I made" in the report, and continue. One commit per
distinct change. Do not merge. Sections are ordered by what users meet first; the
structural sections (§12 onward) come last so the rest can merge if they overrun.

Read first: `docs/process/HANDOFF.md`, `docs/process/HANDOFF_SESSION_8.md`,
`briefs/30-friday-round.md`, and the peer-review issues on the repo ("Review: <name>").
Items marked **regression** were specified in Brief 30 and reported done; find out why
they are not visible on the live site before fixing, and say so in the report.

Conventions that still govern: one fact one store (`DESIGN_MODEL`); one mapping per view;
checks are the only compliance logic; the LLM never writes geometry; nothing measures
through a hidden panel; verify with numbers; `checkLandmarkConsistency()` silent after
every sync; every result word comes from `CHK.label` / `CHK.msgFor` / `CHK.tally`.

Pre-decided:
- Navigation: seven numbered steps, 1 Site · 2 Site facts · 3 Design · 4 Access ·
  5 Check · 6 Visualize · 7 Export. Generate and Furniture are sub-tabs of Design.
  Parklets 101 is deleted; Cost estimate lives on Export.
- 3D ground grid: off by default everywhere in 3D (live, axon, animation); Plan keeps it.
- Trees: one tree language in Plan, Section, 3D and axon, from `TREE_ARCHETYPES`.
- Keys in Connections: never cleared by sign-out, new design, or any reset.
- Rates: a third shipped set "Vancouver indicative 2026, CAD" is the default. Every rate
  in it has a stated basis; a line with no credible source ships as "—", never a guess.
- Impeccable: `critique`, `layout`, `clarify` run on §9 and §12 after they are built,
  with the Brief 30 §12 out-of-scope rules (`DRAW_STYLE`, `DRAW_SYMBOLS`, the three
  renderers and the report engine are never edited by it).
- Sheet scales: each drawing sheet picks the largest standard scale that fits
  (1:20, 1:25, 1:50, 1:75, 1:100, 1:200, 1:250); title block and scale bar follow.
- Anything else ambiguous: plainer choice, log it, continue.

---

## 1. One navigation, in working order (commits 1–2)
Root cause: two navigations disagree: the tab row (Site · Generate · Design · Furniture ·
Accessibility · Check · Visualize · Export · Park) and the step strip (Site · Site facts ·
Design · Access · Check · Export), plus a grey hint sentence explaining the difference.
- The tab row becomes the step strip: 1 Site · 2 Site facts · 3 Design · 4 Access ·
  5 Check · 6 Visualize · 7 Export, numbered, with the gate marks (locked past Site
  facts until every card is answered). Keys 1–7 jump to steps.
- Generate and Furniture become sub-tabs inside Design's left panel (Generate first as
  the quick start; Furniture library below; shape editor and Materials as now).
- Delete the grey hint sentence, the "Steps" label, and the "Park" / "Parklets 101" tab.
- G-001 "What to do next" and README's How to use it are rewritten to the seven steps.
- Left-panel sections reset: on step change (or Design sub-tab change) every collapsible
  section closes except the step's default first section; new design, open design and
  sign-out reset all to default. Within a step, open sections stay open. The floating
  Plan key and the Layers panel close on step change. The Selection block keeps its own
  open/close with selection. Remove the panel-state persistence (localStorage keys),
  not just bypass it.
VERIFY: one nav element in the DOM (grep for the second bar = 0); five sites + blank
street walk 1–7 with the gate behaving; Generate and Furniture reachable in two clicks
from anywhere; no "Park", "Parklets 101" or "Accessibility" tab names anywhere; open
three Design sections → Check → back: only the default is open; "+ New" resets every
panel; grep for the panel-state key = 0; README steps match the strip; screenshots at
1280 and 1440.

## 2. Dialogs readable and keyboard-safe (commit 3)
Root cause: the blank-street confirm dialog renders its title and body at the backdrop's
dimmed opacity; only the buttons are at full strength. Probably the "dim the shell behind
the auth dialog" rule applied to the modal's contents.
- Dialog text at full contrast (≥ 4.5:1, both themes); only the backdrop dims. Fix the
  shared component, then check every dialog that uses it: sign-in, new design, blank
  street, clear values, delete, unsaved changes.
- Every dialog takes focus on open, Escape cancels, Tab stays inside (Brief 30 §12 did
  this for sign-in; apply to all).
- Blank-street text to two sentences: "A generic two-way street, not a real place. Every
  width is a placeholder until you measure it; the sheets will say so."
VERIFY: measured contrast of each dialog's text ≥ 4.5:1 in both themes; screenshot of
each; keyboard round trip on each.

## 3. Site picker (commits 4–6)
A. **Regression** — layer dots. The basemap is now OpenFreeMap as specified, but trees
   draw at full size and saturation at every zoom. Brief 30 §1 commit 2 specified: 4 px
   at zoom ≤ 15, 6 px at 16–17, 8 px above; grey with a 1 px white halo, trees muted
   green; hidden below 15 with "Zoom in to see site features"; type on hover only.
   Find out whether the commit regressed or the thresholds never bite at picking zoom.
B. **Regression** — eligibility band. Brief 30 §2's `blockfaces` layer is not visible.
   Check in this order: is the layer in the Layers menu and off by default; does it
   only show above a zoom; did the `curbside-data` branch with the layer merge and
   publish. Make it visible by default at zoom ≥ 15 with its legend line.
C. Change the pick. After a pick, a click on a different street starts a new pick there;
   a click on the same street flips the side (as now). The footer says both. Closing the
   dialog is never the only way to change streets.
VERIFY: Barclay at Jervis at zoom 15, 16, 17 → marker radius and count logged, trees
muted, no dot larger than 8 px; the band shows along the curb with reasons on hover at
Robson, Main 2500 and Denman at Davie; click Barclay then Jervis → the pin moves and the
footer names Jervis; click Barclay again → side flips.

## 4. Connections keys survive sign-out (commit 7)
Root cause (confirm): keys stored in localStorage under the Connections namespace are
cleared by sign-out or by the new-design reset.
- Sign-out, "+ New", open design, and any state reset leave the Connections key store
  untouched. If the keys were lost in a different browser or a private window, that is
  by design; add one line in Connections saying keys live only in this browser.
VERIFY: add a key, sign out, sign in → key present and Test passes; "+ New" → key present;
a private window → Connections empty with the explanatory line.

## 5. Plan context at Far and Mid zoom: a site plan, not a diagram (commits 8–9)
Root cause: at Fit sheet the context draws every street as a thick filled ribbon with
rounded ends, footprints in a grey one step lighter than the streets, everything at one
weight across the 1 km ring. No figure-ground, no hierarchy, no names; it reads as
generated. The design street is a striped bar.
- Jenna supplies one or two reference site plans in `briefs/refs/` (if none are present
  when you start, use a 1:2500 figure-ground convention: paper ground, buildings as the
  only filled shapes, streets as paper between hairline curb lines). Match the reference.
- Two tones plus ink: paper, one grey, ink. Buildings poché (technical) or light grey
  with hairline (schematic); streets as paper between curb lines at `fine`; no rounded
  caps; curb lines break at intersections; lanes at half the street weight; parks palest
  green, no outline. Three weights by ring: design block in ink with its trees and the
  parklet; inner 100 m ring medium; outer ring hairline, footprint fill only.
- Street names along the lines at Mid in one face at two sizes; none at Far. The design
  street drawn like every other street at Far, with only the parklet marker and the C03
  corner circles; the striped bar only at Near. Sheet-extent dashed box stays.
- All in `DRAW_STYLE`, both styles, so A-101/A-102 and the live Plan agree.
VERIFY: Fit sheet at Robson, Commercial & 1st, W 4th at Yew in both styles, before and
after beside the reference; curb lines 1 px at 100 % with no overlaps at intersections;
footprint/street contrast logged; A-102 matches the live Plan; 1 km render time not worse.

## 6. 3D: grid, trees, ground surfaces (commits 10–12)
A. Ground grid off in 3D by default: live view, axon preview, animation export. Plan
   keeps it. A Layers toggle (off) turns it on in 3D; when on it covers the context
   extent and fades with distance (alpha falloff, pitch 1 m near → 5 m far), never a
   visible edge.
B. Trees: replace the grey/green spheres in 3D and the axon with the A2 species
   archetypes' form solids: schematic = translucent pale green layered lobes with
   trunk; technical = grey line-art canopy. One canopy mesh per genus, instanced. The
   same archetype drives Plan, Section, 3D and axon.
C. Ground surfaces read like the Plan: sidewalk, bike lane, parking, travel lane and
   buffer each in `DS.segColor`, curb as a 150 mm step with a hairline edge between
   segments, both styles. Lane structure must be legible without the yellow line.
VERIFY: Street preset at Robson and W 4th at Yew, before/after, no grid edge at any
camera, frame rate logged; axon export frame shows no grid; the 3D tree for a Tilia
matches the Plan symbol for Tilia; grey-scale screenshot still shows the lane boundaries.

## 7. Materials: show the material, render the material (commits 13–14)
Root cause: `FL_MATERIALS` holds names, roughness and metalness, but the Materials panel
shows 34 unlabelled colour squares per role and the 3D scene has no environment map or
texture, so a material is a flat colour.
A. Panel: each swatch drawn as a small material tile (grain for timber, sheen for powder
   coat, speckle for terrazzo, hatch for composite — the `DRAW_STYLE` hatches), name on
   hover, name under the selected one; grouped by family with headings (timber, metal
   and powder coats, mineral, composite, glass); roles only list materials that make
   sense for them (no powder-coat reds on a deck surface).
B. 3D: one neutral environment map so roughness/metalness read; procedural textures per
   family (plank grain with seams at the real board width on the deck, powder-coat
   sheen, terrazzo speckle, concrete, composite); normal maps for timber and concrete
   if cheap; generated at load, no image files in the repo. Photoreal prompt unchanged.
VERIFY: Ipe planters and Terrazzo screens → swatches labelled, 3D planter shows grain
and the screen speckle, Corner preset before/after; schedule and Rhino names unchanged;
blank street frame rate ≥ 30 fps.

## 8. Access overlay as a dimensioned diagram (commit 15)
Root cause: four translucent fills overlap on the deck (route, turning zones, pinch,
deck); the one number that matters is a small label on top.
- No filled bands. Route = dashed hairline outline of the 1.5 m corridor from each
  entry to its seat, light dotted hatch inside; turning spaces = dashed 1.5 m circles.
  Deck keeps its normal fill. A pinch is drawn as a dimension across the narrow point
  with extension lines, "0.80 m · min 1.50 m", and the obstruction outlined in the one
  accent colour with a leader naming it. Entries labelled outside the deck.
- Pass state: same dashed route in a muted tone, narrowest clear width dimensioned once
  ("1.62 m clear").
- Shown only on the Access step and the C16 "show me" from Check; not on sheets (see §11).
  Both styles via `DRAW_STYLE`.
VERIFY: Robson with F1 at 12.5 m → pinch dimension across the gap, F1 outlined with
leader, no filled band; drag F1 → dimension and route follow in the same drag; pass
state shows the narrowest width; A-102/A-103 unchanged; before/after both styles.

## 9. Cost estimate: real defaults, one table, Excel export (commits 16–19)
Root cause: the take-off is correct (deck area from the polygon, enclosure per edge,
planters, furniture, parking spaces) and the fees print with their 2016 flag, but the
Manual rate set has no unit rates for any build line, so the estimate reads as City fees
alone and the sanity line says "no build cost priced yet". The diagram and the five-
column primer add nothing.
- Delete the Parklets 101 tab, its nav entry, the build-up diagram and the primer tables.
  The Sources paragraph (Vancouver Manual, SF, NACTO, Parkade, Cincinnati, Toronto) moves
  to the report's Sources sheet.
- Keep Quantities, Cost estimate and Materials as one block, "Cost estimate", on the
  Export step. Nav, step strip, G-002 title and file names all say "Cost estimate".
- Ship a third rate set "Vancouver indicative 2026, CAD", default: low/high per build
  line the take-off produces — decking per m² by family (softwood, cedar/thermowood,
  hardwood, composite), joists per m, levelling pedestals per m², planter wall per m and
  planter box per unit, railing per m by type (steel picket, cable, glass), screens per
  m, planter soil per m³, design-and-permit-drawings allowance, contingency %. Every
  rate tagged `indicative` with its basis in the row; the report lists where each number
  came from; a line with no credible source ships "—". The Parkade set stays selectable
  as `placeholder`; the Manual set keeps the fees.
- One table: the numbers people need first (build low–high, City fees, total low–high,
  position against the Manual's typical range for N spaces) at the top in five-second
  form; then Build lines (quantity, unit, rate low–high, cost low–high, material from
  Design, source), Furniture (schedule rows with quote fields), City fees (2016 flag),
  Total; the Manual range as one comparison line, never a cost line. The three-clause
  banner becomes one state line. Materials table at the bottom, families linking to
  Design › Materials. Rate-set picker, "new set from this one", CAD rate and meter count
  stay, grouped.
- Run Impeccable `critique`, `layout` and `clarify` on the block after it is built;
  apply findings before VERIFY; screenshots before/after.
- "Export to Excel (.xlsx)" beside the rate-set picker. Vendored SheetJS in
  `tools/vendor/` with licence in THIRD_PARTY. One workbook, three sheets: "Cost
  estimate" (the table; totals as live SUM formulas; the Manual range as a note row),
  "Quantities" (take-off with each formula written out in a text column), "Rates" (the
  selected set, one row per rate, with tag and basis). Frozen header, currency formats,
  column widths, design name and date in the header. File
  `<design-slug>-cost-estimate-YYYYMMDD.xlsx`. Study JSON export unchanged.
VERIFY: Robson, this design → Build total is a non-zero range, hand sum of the lines
matches (log it); banner reads a position against $40,000–60,000 for 4 spaces; deck to
composite in Design → decking rate and cost change; a line with no sourced rate shows
"—" and is counted; Parkade set still says placeholder; tab and diagram gone, grep for
the diagram builder = 0; G-002 in both modes with the new title; Excel opens with three
sheets, totals are formulas (change a rate → total updates), no `#REF`, on-screen total
equals the sheet total; file size of `parklet-checker.html` before/after.

## 10. Furniture and 3D placement — carry-over check (commit 20)
Brief 30 §4 reported done. Re-verify on the live build: drop a card on the 3D canvas,
Place → click in 3D, touch tap-card tap-deck, drag a placed piece in 3D. Fix anything
that no longer holds; report numbers as in Brief 30 §4 VERIFY.

## 11. Report sheets: scale and content (commits 21–23)
A. A-103 Deck plan: largest scale that fits (this deck → 1:50). Remove the accessible
   route hatch, turning circles, "1.50 clear" label and the C16 notes. Keep deck outline
   with chamfers, enclosure line with post ticks, furniture with tags, entries labelled
   outside the deck, section marker, dimensions (length, width, end setbacks, chamfer
   legs), grid bubbles if posts are on grid. "Entry" labels must not cross the section
   line.
B. A-104 Accessible route (new, optional): the §8 diagram on paper, only when C16 fails
   or the user ticks it in Export options; default off.
C. A-202 Parklet section: extent from 0.5 m inside the sidewalk edge to 0.5 m past the
   traffic-side enclosure; vertically 0.3 m below road to 0.3 m above the tallest deck
   element. No building, no tree, no far side. Scale 1:20 if it fits, else 1:25. Content
   from the model: curb profile with 150 mm and the deck-edge gap dimensioned (C14);
   deck layers (boards at their width and thickness, joists, levelling supports on the
   real crossfall) with top-of-deck and top-of-curb levels; enclosure in section with
   height dimensioned (C17) and its real construction per type; furniture cut at real
   size with seat height; buffer dimensioned; wheel stop and bollard beyond as City
   symbols; C19 clearance when an overhead element exists. Keynotes only for what is on
   this sheet.
D. A-201 Street section stays 1:100, loses the parklet keynotes now on A-202, keeps lane
   dimensions, building faces, deck as a simple bar.
E. A-102 Site plan picks 1:200 or 1:250 by the same rule. Title block and scale bar
   follow on every sheet.
VERIFY: Robson and the 7-piece test design → A-103 at 1:50 filling the drawing area,
scale bar 100 mm = 5 m measured in the PDF, no route graphics, no C16 notes; a 30 m deck
steps down and says so; A-104 only on a C16 fail or when ticked; A-202 at 1:20 with the
listed content and nothing else, scale bar 100 mm = 2 m; add an umbrella → the sheet
grows and C19 is dimensioned; A-201 without deck keynotes; `[report] layout check` 0
overlaps, 0 outside; before/after of each sheet.

---

## 12. Check as the same cards as Site facts (commits 24–26) — structural
Root cause: Site facts (answer) and Check (result) are two screens built two ways; Check
also says things twice (table, then a dark plain-language summary), the banner says
"fails on measured data" for a design fail, and a row reads "beside the the deck edge".
- One card component for both. Site facts: one at a time, gated. Check: all cards,
  collapsed, grouped by result, failures first, filters in the left panel.
- Collapsed: rule ID, title, result badge, one-line answer with provenance ("Hydrant
  7.0 m · measured on site, 4 Oct"). Expanded: rule text in plain words, Manual
  citation as a link that opens the page, value with provenance, how the result was
  derived, fix text, "show me", and the same inputs as the Site facts card with the
  provenance radio and Save. Re-run on Save; regroup on Save, not per keystroke.
  Design-only checks (C14, C16–C19) show derivation and "go to Design". Advisories
  become cards in an "Advisory" group.
- Banner counts by badge and uses the result words (a design fail: "Does not pass:
  1 check fails on the design"). Delete the plain-language summary and the table.
  C-001 reads the same card data. Fix "beside the the".
- Run Impeccable `critique` and `layout` after it is built.
VERIFY: Robson with F1 placed → one Fails card for C16 "Fail (design)", banner wording
as above; expand C05, 7.0 → 4.0 measured, Save → moves to Fails "Fail (measured)", cover
and C-001 agree; Manual link opens p. 60; one card implementation (grep = 0 for a
second); no text duplicated between banner, card and summary; Tab reaches every card,
Enter expands, Esc collapses.

## 13. Blank street: empty by default, context buildings by hand (commits 27–28) — structural
Root cause: the blank street seeds two buildings a side that nobody asked for, and there
is no way to add or shape buildings on a generic street.
- Blank street seeds the street only: sidewalks, parking lanes, two travel lanes, curbs;
  no buildings, trees or site objects. Sheets keep "Generic street — not a real location".
- A "Context" section in Design's left panel, only for blank-street designs: a list of
  buildings, "+ Add building" per side; per building: side, position along the street,
  frontage length, depth, setback, height or storeys (4.2 + 3.5 m rule until a height is
  typed), use, frontage type, name. Writes to `BLDG_L` / `BLDG_R` through
  `syncDesignModel`; no second store. Host = nearest to deck centre on the parklet side,
  as now; with none, frontage-dependent items read "no building entered".
- Delete the default blank-street buildings and the "two buildings on each side" text.
  Old blank-street designs keep their buildings as user-added, logged once.
VERIFY: blank street → `DESIGN_MODEL.buildings` empty, Plan/3D show none, consistency
check silent; add 12 × 20 m, 3 storeys, setback 1.0 m near side → Plan, Section (if
cut), 3D and A-102 agree, host frontage updates; storeys 5 → height follows; delete →
clears; imported site → no Context section; an old blank-street design loads unchanged.

---

## VERIFY sites (every section)
Robson & Burrard · Commercial & 1st · W 41st & Dunbar · W 4th at Yew · Main 2000/2500
block · Barclay at Jervis · blank street.

## Report
Per section: VERIFY results as numbers; "Decisions I made"; before/after screenshots
named by section; for §3A and §3B the cause of the regression; the rate-set sources
table for §9; Impeccable findings applied and skipped for §9 and §12; file size of
`parklet-checker.html` at start and end; peer-review issues with outcomes; "Needs
Jenna" (reference site plans for §5 if not supplied; anything needing her key or
Supabase). Update `docs/process/HANDOFF.md`; write `docs/process/HANDOFF_SESSION_9.md`.
Do not merge.
