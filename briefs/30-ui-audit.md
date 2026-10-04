# Brief 30 §12 — UI audit and critique (commit 21)

Impeccable `audit` and `critique` of the Curbside UI chrome (top bar, step strip, left panel, dialogs, Site facts, Check,
Export, Settings, Parklets 101) at 1280 × 800, 1440 × 900 and 1024 × 768 with touch, 2026-10-04, on branch
`friday-round` after §11 (f8b4fbd). The canvases (Plan, Section, 3D) and the report sheets are out of scope (`DRAW_STYLE`,
`DRAW_SYMBOLS`, the renderers and the report engine). Findings only; the fixes are commits 22–27.

**Method:** dual assessment. A (design review) ran as an isolated agent from the screenshots and targeted source reads;
B (measurements and the detector) ran in the main session and did not see A until both were done.
Evidence: `scratchpad/b30/ui/before-<width>-<tab>.png` (33 screenshots), `before.json` (per-tab measurements),
`detect-before.json` (the detector). Site: Robson & Burrard, imported, Site facts answered, one bench placed.

## B. Measurements (every tab, three sizes)

Counted in the page, interface text only (SVG, canvases and the Section strip excluded):

| Tab | Text < 12 px (1280 / 1440 / 1024) | Controls < 24 px (1280 / 1024) | Contrast < AA (1280) | Letter-spaced capitals |
|---|---|---|---|---|
| Site | 33 / 33 / 32 | 84 / 78 | 3 | 1 ("Steps") |
| Site facts | 41 / 44 / 40 | 14 / 8 | 0 | 1 |
| Generate | 30 / 30 / 30 | 28 / 22 | 2 | 1 |
| Design | 31 / 31 / 31 | 91 / 85 | 0 | 1 |
| Furniture | 93 / 93 / 67 | 36 / 16 | 44 | 1 |
| Access | 39 / 39 / 39 | 83 / 77 | 0 | 1 |
| Check | 32 / 32 / 32 | 18 / 12 | 8 | 1 |
| Visualize | 37 / 37 / 37 | 19 / 13 | 1 | 8 (Camera, Photoreal render, Output, Sun, Appearance …) |
| Export | 43 / 44 / 43 | 17 / 11 | 8 | 1 |
| Parklets 101 | 29 / 29 / 29 | 14 / 8 | 0 | 1 |
| Settings | 45 / 47 / 43 | 21 / 14 | 10 | 1 |

No page overflows sideways at any size; every header control is on screen at 1280, 1440 and 1024 (the tabs were
tightened in 9c478fd). Page errors: 0.

**Detector** (`impeccable detect --json parklet-checker.html index.html`): exit 2, 56 primary findings, 212 advisories.
- tiny-text 25 (11 px body text), low-contrast 9 (`#2b2b2b` on `#202328` ×3 — the Site facts box title; white on the
  old `#0696D7` and on `#3AA8E4`; `#666` on `#1a1e24` ×3; `#9ea3a8` on white), tight-leading 1 (line-height 1.0),
  design-system-font 3 (Barlow Condensed loaded and unused; Courier New in five legacy rules; the landing's SF Mono).
- cramped-padding 14 and clipped-overflow-container 3: on full-bleed frame containers (`.app`, `.topbar`,
  `.canvas-toolbar`, `.drw-panel`, `.vp-hdr`, `.status-bar`, `.canvas-area`). Checked in context: deliberate (toolbars
  and canvas frames are edge to edge; the canvases clip their own labels). False positives for this app.
- overused-font 1 (index.html: Inter).
- Advisories: design-system-color 186, -radius 15, -font-size 11: the legacy CSS layer (the old `#0696D7` blue, `#2B2B2B`
  ink, the sidebar rgba greys) and the drawing palettes in the same file.

## Audit health score

| # | Dimension | Score | Key finding |
|---|---|---|---|
| 1 | Accessibility | 2 | 29–93 texts under 12 px per tab; 9 contrast failures (one near-invisible title); 4–7 unlabelled inputs on canvas tabs and Export |
| 2 | Performance | 3 | Export and + New stall at most 0.43 s (§8C); the 2.6 MB single file loads once; nothing animates layout |
| 3 | Responsive design | 2 | 1024 touch: 77–85 controls under 24 px on canvas tabs, the Check table's Result and Source columns cut, the design name cut, step pills wrapping |
| 4 | Theming | 2 | A token layer exists (`--c-*`, `--accent-ui`, `--st-*`) but an older layer (`--nav-blue #0696D7`, `--ink`, sidebar rgba) still drives many rules |
| 5 | Implementation integrity | 3 | Coherent product-specific core (Site facts, Check rows); drift from older sub-systems (uppercase labels, monospace labels, two blues) |
| **Total** | | **12 / 20** | **Acceptable: significant work needed** |

**Implementation integrity verdict: pass, with drift.** The parts built for this product (the Site facts card, the
Check rows with requirement, value, page and "Open C02") are specific and coherent. The frame around them carries three
older visual sub-systems, which the detector's design-system advisories and A's review both point to.

## A. Design review (critique)

| # | Heuristic | Score | Key issue |
|---|---|---|---|
| 1 | Visibility of system status | 3 | Site facts: "16 of 16 answered" while 11 are "not known yet"; the progress bar reads full at card 1 |
| 2 | Match with the real world | 2 | "z 15.6 m", "1+1 two-way", "closed polysurfaces … Z-up", "SF / CALC / DI", a model ID, "Provisional" |
| 3 | User control and freedom | 3 | "Clear entered values" (destructive) beside "Download report (PDF)" |
| 4 | Consistency and standards | 1 | Nine tabs and six steps; "Access" / "Accessibility"; several words for how a fact is known; uppercase and monospace sub-systems |
| 5 | Error prevention | 3 | How a fact is known is required; the destructive control's placement |
| 6 | Recognition over recall | 2 | Content behind closed folds; a glyph-only Panels button |
| 7 | Flexibility and efficiency | 3 | Tabs or steps, typed values, Fit lanes to minimum |
| 8 | Aesthetic and minimalist design | 2 | Export opens on Rhino detail; "Fit design" twice on Access |
| 9 | Error recovery | 3 | Fail rows give requirement, value, "Open C02" and the page |
| 10 | Help and documentation | 3 | Parklets 101, "Why it matters", the ? panel |
| | **Total** | **25 / 40** | **Acceptable** |

**Specificity:** the Site facts card and the Check rows belong to this product; the frame is generic CAD/GIS chrome built
up over many briefs, and its engineering copy dilutes the plain-words promise where a first-time user lands.

**Emotional journey:** a valley at the start (Site opens on a stale bench's Selection panel and a red lane pill, the
Locate step below the fold); the peak at Site facts; a dip when it says "16 of 16 answered"; a plateau in Design (four
closed folds, nothing says start here); a peak in Access ("Route clear"); a valley in Check (estimate / imported /
provisional / not entered for related states); a mixed ending in Export (Rhino before the report).

**Strengths:** the Site facts card; actionable Check rows; Settings › Connections in plain words.

## Findings by severity, with the command that fixes each

### P1
1. **The 12 px floor and the mixed-case rule do not hold.** All tabs (table above); `--fs-11` and ~340 rules at 11 px;
   uppercase in "Steps", Visualize's folds, badges; monospace for labels in the Selection panel. → **typeset**
2. **Provenance words drift on the product's core promise.** Site facts counts "answered", not how facts are known; a ✓ on
   unknown facts; the bar full at card 1; Check says "Provisional" where the row says "estimate". → **clarify**
3. **The Selection panel takes over the left panel on Site and Access** with a stale selection, pushing the step's own
   content below the fold. → **layout**
4. **1024 touch:** controls under 24 px (canvas tabs ~80), the Check table's Result / Source columns cut, the design
   name cut, step pills wrapping. → **adapt**
5. **Contrast:** the Site facts box title at 1.1:1; Furniture's "Street Components" tab; Settings' Test / Remove and links;
   white on the old blue. → **polish**

### P2
6. **One accent broken:** "Awaiting measurement" badges in the accent blue (a status), furniture IDs blue, many primary
   buttons at once. → **polish**
7. **Export leads with the 3D model** (Rhino copy) before the report; unlabelled animation sliders. → **layout**, **clarify**
8. **Jargon and a garbled string:** "z 15.6 m" in the tree advisory; a species name read as "inges ruby vase ironwood";
   "SF / CALC / DI"; a model ID; a broken glyph on a Furniture button. → **clarify**
9. **First run:** Site opens with nothing saying where to start; Design's folds closed with no "start here". → **onboard**
10. **"Clear entered values"** beside the report download, styled alike. → **layout**

### P3
11. "Fit design" twice on Access; the Check left panel nearly empty; green "Done" pills on Site steps (status colour on a
    step state); Barlow Condensed loaded and unused; Courier New in legacy rules. → **polish**

## Recommended order (commits 22–27)

1. **adapt:** 24 px minimum targets (44 px under a coarse pointer for the main controls), the Check table stacking at
   1024, the design name and step pills at 1024.
2. **layout:** the Selection panel only in Design / Access with a live selection, below the step header; Export with the
   report first and the 3D model and animation folded under "More formats"; the destructive Clear away from Download.
3. **typeset:** the 12 px floor (`--fs-11` and the 11 px rules), sentence case for the remaining capitals, the UI face for
   labels.
4. **clarify:** one set of words for how a fact is known (measured on site, estimate, imported, not known yet); counts of
   measured facts; the advisory's "along the curb"; plain names for SF / CALC / DI, the model, the Rhino options.
5. **onboard:** a first-run line on Site and on Design saying what to do first.
6. **polish:** the contrast failures, the accent only for selection / focus / primary action, the unused font, the
   detector at exit 0 as a pre-push step.

Out of scope here and noted for later: merging the tabs and the steps into one navigation (A's P1 #1) is a structural
change to the app's information architecture, larger than this brief's UI pass; it is listed for Jenna.
