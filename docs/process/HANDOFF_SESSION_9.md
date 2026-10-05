# Curbside: handoff, session 9 (Brief 31, the walkthrough round, 2026-10-04)

## Where things stand

- **Branch `walkthrough-round`** from `friday-round`. There are 31 commits, one per
  change. **Not merged, not pushed.** Master, origin, GitHub Pages, curbside-data's published cells and Supabase were not touched.
- **`parklet-checker.html`:** 2,644,050 bytes at the start and 2,726,074 at the end (+82,024).
- **New files:**
  - `tools/vendor/xlsx-0.20.3.full.min.js` (SheetJS CE, Apache-2.0) with `xlsx-LICENSE.txt`.
  - `THIRD_PARTY.md`.
  - `briefs/31-walkthrough-round.md`.
- **Changed files:** `tools/serve.ps1` (a read-only `/curbside-data/` route to the sibling checkout) and `README.md`.
- **Peer-review issues:** `gh issue list` returned 0 open issues, so there was nothing to triage.
- **Final regression** (Robson, Commercial, Dunbar, W 4th, Main, blank street):
  - Keys 1–7 walk all seven steps.
  - Placing a piece gives 0 consistency issues.
  - Check: 19–20 cards and a banner.
  - Every drawing sheet's scale bar agrees with its scale. Layout check: 0 overlaps, 0 outside.
  - Errors: 0.
  - The script is `scratchpad/b31/treg.js`; the numbers are below.

## Working conventions (new this session)

- **Headless runs use Playwright's own timeouts, never the shell's.**
  - **What happened:** a §5 timing run hung for over two hours. The cause was the W 4th "after" run, a node process
    started at 12:25 that never returned. `timeout 900` in Git Bash on Windows did not end it: the signal does not
    reach a node process that is holding a Playwright Edge, so the shell kept waiting on it.
  - **The fix is in the harness (`scratchpad/b30/h.js`):**
    - `page()` sets `page.setDefaultTimeout` and `setDefaultNavigationTimeout` (30 s, or `PW_TIMEOUT`).
    - `H.run(fn)` launches the browser, runs `fn`, and closes the browser in a `finally`.
    - `H.run` also has a whole-run cap (`PW_RUN_MS`, 300 s by default) that closes the browser itself.
  - A step that waits too long now throws within 30 s and the browser closes. This happened twice in the §12 test
    runs and was reported at once each time.
  - Every script written after this point (`t12.js`, `t12d.js`, `treg.js`) uses `H.run`.
  - The single §5 re-timing used an in-process 60 s watchdog. All six runs finished.
- **Before/after runs:** the before build is served by `git show HEAD:parklet-checker.html > scratchpad/bis/...` on
  port 8769, and the after build by the repo on 8766. The local data server for curbside-data is on 8771.
- **Patches** are Node scripts written with the Write tool. Bash heredocs mangle `\\b`.

## What each section did (commit, VERIFY in numbers)

### §3A Picker markers: regression (1611104)
- **Cause:** Brief 30 put the marker sizes into `circle-radius`. That property is a radius drawn outside a 1 px halo, so
  the dots were 10, 14 and 18 px across instead of the specified size. At zoom 15, 3,684 trees merged into ribbons.
- **After, at Barclay & Jervis:**

  | Zoom | Trees | Hydrants | Stops | Dot size across |
  |---|---|---|---|---|
  | 14 | 0 | 0 | 0 | none shown |
  | 15 | 3,651 | 149 | 49 | 4 px |
  | 16 | 1,014 | | | 6 px |
  | 17 | 311 | | | 6 px |

  Tree opacity is 0.8.

### §3B The eligibility band: regression (eeaedd7)
- **Cause:** the band was on from zoom 15 and its legend showed, but its blockfaces layer exists only on
  curbside-data's unpublished `friday-round` branch. The published cells have no such layer, so nothing drew.
- **Fix:** on a development host the app reads the sibling checkout through `tools/serve.ps1`'s new `/curbside-data/`
  route.
- **Through the local server:**
  - Robson: 266 pieces (71 need measurement, 174 excluded, 21 eligible).
  - Main: 408 pieces. Denman: 234 pieces.
  - 229 local cells were requested.
  - Hovering a piece shows "Excluded here, Within 6 m of the corner at Beach Avenue (C03)".
- **With `?gis=published`:** 0 pieces, and the Layers row says "not in the published data yet".

### §3C Re-pick on another street (45801f7)
- Barclay was picked (way 1197491724, south-west side).
- A click on Jervis moved the pin about 56 m, and the footer named Jervis.
- A click on the same street flips the side instead.

### §4 Keys survive every reset (a0efe32)
- **Cause:** Clear all saved data called `localStorage.clear()`. Browser storage is also separate for each address
  (origin).
- **After:** the key survives each of the following, and Test reports OK afterwards:
  - sign-out, then sign-in;
  - + New;
  - the blank street;
  - Clear all saved data (only `pkt_connections` remains);
  - a reload.
- A private window starts with Connections empty and shows the line that explains why.

### §2 Dialogs (967a4ba)
- **Before:**
  - The blank-street dialog's text had a contrast of 1.11:1.
  - Tab stayed inside the blank, rename, delete, unsaved and replace-site dialogs for only 0–2 of 30 presses.
  - Esc left those dialogs open.
  - Clear values used the browser's native confirm.
- **After:**
  - All 8 dialogs have a contrast of at least 5.67:1.
  - Focus moves into each dialog when it opens.
  - Tab stays inside for 30 of 30 presses.
  - Esc closes every dialog.

### §1 One navigation (0ecfc0a, 73ae07f, 2a777a3)
- There is one nav and no step strip.
- Walking the steps 1–7 works at Robson and on the blank street, with the gate in place. Keys 1–7 work.
- Generate and Furniture are each 2 clicks away.
- The header at 1280 px has 15 controls. In the 1440 px run its rightmost control ends at 1428 px.
- Panels:
  - Open three Design sections, go to Check, then come back: only the shape editor is open.
  - + New resets the panels.
  - No panel state is kept in localStorage (0 keys).

### §9 Cost estimate (e377d49, 62513da, 988f8b0, 57587ea)
- **Removed:**
  - Parklets 101 is deleted. Its diagram builder and `LAYERS` are undefined, and the learn tab count is 0.
  - G-002 is titled "Cost estimate" in both report modes.
- **Robson, Build:**
  - $7,061–11,938, which equals the hand sum.
  - 4 of 9 lines are priced. The other 5 show "—" and are counted.
  - 7 furniture pieces are not priced.
- **Banner:** "below … so far", against $40,000–60,000 for 4 spaces.
- **Composite decking:** the rate is $55.17–74.93/m², and Build becomes $9,136–15,116.
- **The Parkade set** says "placeholder".
- **xlsx export:**
  - 3 sheets, 28 formulas, 0 #REF.
  - Frozen panes on all 3 sheets.
  - 10 columns with set widths and 46 currency cells.
  - The sheet total of $9,904.97–15,142.41 equals the on-screen "$9,905 – $15,142".
  - Raising one rate by $10 changes the total by 653.4, as expected.
  - File name: `1000-robson-st-cost-estimate-20261004.xlsx`.
- **Rate set "Vancouver indicative 2026"** (retrieved 2026-10-04):

  | Line | Rate | Basis |
  |---|---|---|
  | Decking, softwood | $23.42–26.30/m² | Turkstra $12.38 to Kent $13.90 per 12 ft board; 0.5285 m² per board |
  | Decking, cedar | $53.49–53.89/m² | BMR 14 ft $32.98; RONA 12 ft $28.48 |
  | Decking, hardwood (ipe) | $294–317/m² | Patio Etc / Clôture Nationale $12.95–13.95 per linear ft |
  | Decking, composite | $55.17–74.93/m² | Home Depot Canada Trex $29.16; Patio Etc $39.60 |
  | Edge, steel picket | $229.66–426.51/m | Builders Ontario 2026 aluminum $70–130/ft; DecksForLife $83–120 |
  | Edge, cable | $196.85–820.21/m | $60–150/ft (Builders Ontario); $180–250/ft (DecksForLife) |
  | Edge, timber | $98.43–246.06/m | $30–75/ft |
  | Edge, glass | $492.13–984.25/m | $150–300/ft |
  | Planter soil | $82.21–95.92/m³ | Arts Nursery $44 per scoop of 60–70 % of a cubic yard |
  | Contingency | 20 % | NerdWallet Canada, Feb 2026 |
  | Joists, pedestals, labour, planter wall, screens, design allowance | — | no source that could be checked |
- **Impeccable** (critique scored 25/40):
  - **Applied** (57587ea): the position against the Manual says "so far" while lines are unpriced; Build names the
    figure that includes the furniture; the yearly fee sits after the total; the total leads the summary; the rate
    set and Excel come first, then the meters; the exchange rate shows only for a USD set; Copy as a new rate set is
    folded away; the select is a dark field; field edges are at 3:1; long text is held to 72ch; the fee sources are
    trimmed; an unpriced line is tagged "not priced"; Materials are grouped by family with one link to Design; a
    refused number says why.
  - **Skipped:** these were not written down at the time, and the commit lists only what was applied, so I can't
    list them now. The detector exited 0 with 184 advisories. `--no-config` shows 16 frame findings that the config
    suppresses on purpose.

### §6 3D grid, trees, ground (626bdc7, 7e0b9a5, 271258c, 78f18b4)
- **Grid:**
  - Off by default.
  - When on: 2 sets, fading over [12, 30] and [67.5, 150], reaching 60 m and 300 m.
  - The axon has no grid in its scene.
- **Trees:**
  - They share 1–3 geometries (before: one per tree, 11–14) and are translucent.
  - The Tilia at W 4th has a 3D crown of 7.29–7.49 m, against 2 × canopyR = 7.70 m.
- **Ground:**
  - Hairline edges: 7 at Robson, 9 at W 4th.
  - Frame time 1.2–2.0 ms.
  - The consistency check passes.

### §10 Furniture placement carry-over (no change needed)
- **All 5 sites:**
  - 1 piece added at (1.25, 8.00), with 0 consistency issues.
  - The piece is still there after a reload.
- **Place → 3D** works:
  - Esc cancels and adds 0 pieces.
  - A drop beside the deck lands at x 1.885 with the message.
  - A 3D drag moves the piece 2 m.
  - A touch adds 1 piece.

### §8 Access as a dimensioned diagram (7f0b955)
- **Blocked case** (planter at z 12.5):
  - 3 corridors (1.50 m, 0.82 m, 0.82 m) and 2 turning circles.
  - The pinch is labelled "0.86 m · min 1.50 m".
  - The obstruction is outlined, with a leader to "F2 planter in the way".
  - 0 filled bands.
- **Mid-drag:** the pinch updates to 0.95 m and its dimension moves from y 132 to y 106.
- **Pass state:** 8 turning circles and "1.50 m clear".
- The A-102 and A-103 hashes are unchanged.

### §13 Blank street (5ca2418, d123c81)
- **Empty by default:**
  - 0 buildings.
  - The host line reads "No building entered".
  - Consistency 0.
- **Context section:**
  - It sits in Design.
  - Adding a 12 × 20 m building, 3 storeys, setback 1 m gives:
    - a model height of 11.2 m, and the host updates;
    - 1 building on the Plan;
    - a 3D mass of 20 × 11.2 × 12 at x −24;
    - consistency 0.
  - 5 storeys gives a height of 18.2 m. Delete gives 0 buildings.
- **Older designs:**
  - An old blank street keeps its 4 buildings, noted "added by you", and this is logged once.
  - An imported site keeps Context in Site.

### §7 Materials (37cfa61, 67c534a)
- **Swatches:** the deck tiles offer no red and no glass.
- **3D surfaces:**
  - Ipe gets the timber map and its normal map.
  - Terrazzo gets the speckle; galvanized gets the sheen.
  - The environment map is on.
- The schedule's names are unchanged.
- **Blank street frame time:** 0.8 ms (1,186 fps) before the textures, 1.1 ms with them.

### §11 Sheets (19d0457, 81f974c, 02ddd61)
- **A-103:**
  - Robson is at 1:75 (before: 1:100). The scale bar reads 100 mm = 7.5 m.
  - 0 route graphics, 0 C16 notes, 2 entries.
  - The brief expected 1:50. That does not fit this 19.8 m deck on one sheet: the ladder takes the largest scale
    that fits.
  - A 30 m deck goes to 1:100 and adds the note "Drawn at 1:100".
- **A-104:** appears when C16 fails (the default design) or when it is ticked in Export (off by default).
- **A-202:**
  - At 1:20, with the bar reading 100 mm = 2 m.
  - Tags: road, sidewalk, curb, curbH, board, batten, pedestal, gap, encH, buffer.
  - No building, no tree, no far side.
  - Adding an umbrella moves it to 1:25 and adds the C19 dimension.
  - The 150 curb dimension was moved out of the sidewalk hatch.
- **A-201:** at 1:100. It keeps only the "Building at the cut" note, and the deck is drawn as a bar.
- **A-101 / A-102 (§11E):** both take their scale from the same ladder. At Robson, W 4th and Commercial, in both
  styles:
  - A-102 picks 1:250, because 1:200 does not fit the block face.
  - Every scale bar and title block agrees with the sheet's scale.
  - Layout check: 0 overlaps, 0 outside.

### §5 Plan context: a figure-ground (a32be4e, a18f9dd)
- **Root cause:** every street was a filled ribbon with round ends, the footprints were one grey across the whole
  1 km, there were no names, and the design street was a striped bar at Far.
- **After:** `DRAW_STYLE.CTX` defines the figure-ground. The live Plan (both its vector and raster tiers), A-101, A-102
  and the locator all draw from it:
  - The ground is paper, and the footprints are the only filled shapes.
  - Streets are paper between curb lines 1 px wide. Each curb casing is 2 × 1 px wider than its street, measured as
    exactly 1 screen px. The ends are square.
  - Every casing is drawn under every surface, so curb lines break where streets cross.
  - Service lanes are drawn at half the weight.
  - Parks are the palest green, with no outline.
  - Three weights by ring: the design block is the model's own, the inner 100 m ring is medium, and the outer ring
    is hairline with fill only.
- **Street names:** shown at Mid only (Fit sheet is Mid at these sites): 107 at Robson, 90 at Commercial, 82 at W 4th.
  None at Far.
- **The design street at Far** (a18f9dd):
  - It is paper between its two ink curb lines: 1 street and 2 curb lines per site.
  - The curb lines break at the cross streets: 11 crossings at Robson, 6 at Commercial, 3 at W 4th.
  - The parklet marker and the C03 circles stay on top.
- **Striped bands:** the count is unchanged at every tier (Robson 1 technical / 5 schematic). They are under the Far
  street, so the consistency check still reads them.
- **Timing at 1 km** (Fit context; median of 3 renders with the cache cleared; one sequential re-run, each run under
  a 60 s watchdog; none hung):

  | Site | Technical before | Technical after | Schematic before | Schematic after |
  |---|---|---|---|---|
  | Robson | 132.5 ms | 117.6 ms | 112.3 ms | 135.1 ms |
  | Commercial | 77.7 ms | 92.8 ms | 96.9 ms | 107.6 ms |
  | W 4th | 104.4 ms | 111.3 ms | 103.7 ms | 123.1 ms |

  After is slower in 5 of 6 cases, by 7 to 23 ms (10–20 %). Earlier parallel runs showed the opposite order, so the
  spread between runs is about the same size as the difference. **This does not establish "not worse".** The added
  work in the raster tier is the per-building ring split and the cross-street strokes.
- **Reference plans:** `briefs/refs/` does not exist, so I used the brief's fallback 1:2500 convention.
- **Screenshots:** `s5-before-*` and `s5-after-*` for rb, cd and w4, both styles, at sheet and context.

### §12 Check as the same cards as Site facts (224b214, 7b3efed)
- **One component, `PKCARD`:**
  - It renders the Site facts card, the Site facts end card, every Check card and the advisories.
  - A grep finds 0 other card builders: `<div class='sfc-card` 0, `<div class="criterion chk-row` 0.
  - The plain-language summary and the table head are deleted: `summaryBox` 0, `Plain-language summary` 0.
- **VERIFY at Robson:**
  - **Bench F1 placed**, with a planter (F2) in the route as in §8. A bench alone gives C16 a pass, so F2 is needed
    to make it fail.
    - Banner: "Does not pass: 1 check fails on the design."
    - C16 is in Fails as "Fail (design)".
  - **C05:**
    - It starts at 7.0 m as an estimate: "Provisional pass (estimate)".
    - Expand, Change, enter 4.0 measured, Save. It moves to Fails as "Fail (measured)", and its answer reads "Fire
      hydrant 4 m · measured on site, 2026-10-04".
    - Banner: "Does not pass: 2 checks fail, 1 on measured data and 1 on the design."
    - The counts line: "1 fail (measured) · 1 fail (design) · 2 provisional fail (estimate) · 10 awaiting
      measurement · 1 not entered · 4 pass (design)".
    - C-001's C05 row reads "Fire hydrant 4 m · measured on site, 2026-10-04. 4 m < 5 m required clearance from
      fire hydrant. Fail (measured)", and its result is "Fail (measured)".
    - The cover tally agrees with the banner.
  - **Manual link:** C16's link is `…/parklet-design-construction-manual.pdf#page=60` and opens in a new tab.
  - **No text said twice:** the banner sentence appears in 0 cards, and "beside the the" appears 0 times.
  - **Keyboard:** Tab reaches 20 of 20 card headers; Enter opens a card; Esc from a link inside a card closes it and
    returns focus to the header.
  - Errors: 0.
- **Impeccable critique** (27/40). In the table, C*n* is the critique's finding *n*, L*n* the layout review's.

  | Finding | What it said | Outcome |
  |---|---|---|
  | C1 / L1 | Filters ran together ("ProvisionalPassing"): `.seg-btn { flex: 1 }` forced 59 px buttons | Applied |
  | C2 | Blue text on paper at 2.6:1 | Applied: Survey Ink #1F6FA3 |
  | C3 | The banner's count differs from the Fails group's | **Skipped:** the brief's VERIFY sets that wording |
  | C4 | "not entered · not known yet" said twice | Applied: "Not known yet · measure on site" |
  | C5 | A badge repeats its group's name | Applied: shown as text |
  | C6 | The provisional badge has a double ring | Applied: dashed. The badge radius was **skipped**: the badge is shared app-wide |
  | C7 | Clear entered values was red | Applied: graphite |
  | C8 | List roles over `details`, and the header's name | Applied (roles dropped, `aria-labelledby`). The hidden Confirm stays in the header; it is never shown since Brief 30 |
  | C9 | The verdict icon | **Skipped:** shared with Export |
  | C10 | Subtitle | Applied |
  | C11 | Review site facts button style | **Skipped:** app-wide `ctx-btn` |
  | C12 | Group marker | Applied: 14 px ink, 32 px summary |
  | C13 | "Failing" / "Fails" | Applied: "Fails" |
  | L2–L4 | Edges | Applied: body 81 px, summary 17 px, a 130 px fact-label column |
  | L5 | Banner hierarchy | Applied: verdict 18 px over the label at 15 px |
  | L6 | Rhythm | Applied |
  | L7 | Measure | Applied: 1080 px |
  | L8 | Banner on a phone | Applied |
  | L9 | `verdict-rule` edge | Applied |
  | L10 | Bar hint below 1100 px | Applied |
  | L11 | ≤540 px panel | **Skipped:** structural, for `adapt` |

  The detector exits 0 (189 advisories over the whole file).

## Decisions I made
- **§1:** Generate and Furniture are sub-tabs of Design. Two clicks away was the plainer reading of "seven steps".
- **§3B:** the band reads the sibling curbside-data checkout only on a development host. The live site still reads
  the published cells.
- **§9:** the default rate set prices only what has a checkable source. Everything else shows "—" and is counted.
- **§11:** A-103 at Robson is 1:75, not the 1:50 the brief expected. The ladder rule picks the largest scale that fits,
  and 1:50 does not fit.
- **§11:** A-104 needs an Export tickbox. It is off by default, and the sheet prints anyway when C16 fails.
- **§5:** names at Mid only, which is what Fit sheet is at these sites. The design street is drawn like the others at
  Far only; Mid keeps its bands, because it is the working view where the lanes and the C03/C13 tags are read.
- **§5:** a street's ring is decided by its nearest point; a building's ring by its centroid.
- **§12:**
  - Every check group starts open, with the cards collapsed, so Tab reaches every card.
  - The Site facts inputs open in the card through Change, one card at a time. `SFG.form`'s fixed ids allow only
    one form on the page.
  - A Save regroups at once. This replaces Brief 30's "held row"; the card keeps the focus where it lands.
  - The design-only checks are C14 and C16–C19, as the brief lists them. C15 keeps its input.
  - The Manual link is the City's PDF with `#page=` the Manual page number.

## Needs Jenna
- **§5 reference site plans:** `briefs/refs/` is empty. I used the brief's fallback convention; add one or two plans
  and §5 can be matched to them.
- **§12 Manual link pages:** the link uses `#page=<Manual page>`. I have not checked whether the PDF's page index
  matches the printed page numbers. If the PDF has front matter, every link is off by a fixed number of pages.
- **§5 timing:** it is not shown to be "not worse" (see the table). Decide whether 10–20 % at 1 km is acceptable, or
  ask for the raster tier to be optimised.
- **§9:** confirm the rate set's sources, and supply rates for the lines shown "—" (joists, pedestals, labour, planter
  wall, screens, design allowance).
- **Waiting from before:** PRODUCT.md, the sample re-render, the assistant test with your key, the hosted relay and
  render-to-account tests, and the landing screenshots.
- **curbside-data `friday-round`:** still unpublished. §3B's band shows on the live site only once it is published.
- **Merge:** the branch is ready for your walkthrough. Nothing is merged or pushed.
