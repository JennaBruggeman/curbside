# Brief 23 — Stranger test: triage

Site under test: https://jennabruggeman.github.io/curbside/ at v0.11-gis (master `079d611`), 2026-09-30, 17:54–18:13
Vancouver time. Nothing was fixed during the test.

## Smoke pass

Parent persona and persona 1, one run each, Claude Sonnet, run in parallel.

### How it was run (read this before the runs)

- **Driver.** Each agent drove its own headless Chromium (Playwright, 1400 × 900, software WebGL) through a small
  HTTP driver: go to, click (by role and name, text, label or pixel), type, keys, scroll, drag, screenshot, the
  visible text, the accessibility tree, the console. It offered no script evaluation, so an agent saw only what a
  visitor sees. The agents had the landing page and a copy of README.md, nothing else.
- **No accounts (deviation from the brief).** The brief has each agent create an account with a throwaway address.
  That is not allowed on the live site: Jenna's standing rule is that she tests sign-up herself, and the agents'
  safety rules forbid creating accounts on a hosted service. The agents opened the sign-up form and recorded it,
  did not submit it, and continued signed out at `parklet-checker.html?noauth` in place of a new account. Neither
  persona needed to save a design. **For the full pass, persona 6 (sign up, save, sign out, sign in) needs accounts
  Jenna creates, or it is run by Jenna.**
- **Harness artefacts, not app defects:**
  - A click by visible text or name times out when the first match is hidden (for example a second "Create account"
    in the dialog, or the "Download report (PDF)" text in the Check tab). The agents then clicked by pixel. Fix the
    driver to prefer visible matches before the full pass.
  - While the page's main thread is busy (PDF export, a new design), screenshots time out after 30 s, so an agent
    sees nothing and may click again.
  - Two browsers rendering in software on one machine at the same time make every timing here slower than on real
    hardware.
- **Screenshots and driver logs:** `<scratchpad>\b23\parent-run1\` and `<scratchpad>\b23\p1-run1\` (numbered PNGs,
  `driver-log.jsonl` with every command and its time). `<scratchpad>` is
  `C:\Users\bangp\AppData\Local\Temp\claude\C--Users-bangp-Desktop-UBC-Fall-2026-ARCH-540-AI-New-folder\53c36af6-f1db-4db4-82b7-a08691d53a6f\scratchpad`.
- **Checked against the evidence.** The agents' reports are model output. Each item below was checked against the
  driver log and the screenshots where that was possible. Where an agent's reading was wrong or unconfirmed, the
  item says so.

### Run: Parent (café owner), run 1, Sonnet

- **Site:** West 4th Avenue at Yew Street, Kitsilano, south side (host frontage Purdy's, 2180 W 4th Av).
- **Time:** 10 minutes to the schematic PDF (17:54 → 18:04). The export alone took 2.5 minutes, from the click at
  18:01:30 to the file at 18:04:01.
- **Outcome:** `curbside-untitled-parklet-schematic.pdf`, 558 kB. Verdict "does not pass": C01 is a bus zone, and
  C02 gives 4 lanes of 3.138 m against 3.2 m on a bus / truck route. 12 checks were not entered.

**Broke**
- **PDF export:** the page is unresponsive for minutes with only "Preparing the PDF…" (2.5 min here; screenshots
  timed out twice). There is no progress indication.
- **Blank map after choosing the search result** (`parent-run1\011.png`). *Unconfirmed:* the screenshot was taken
  0.8 s into the map's fly-to, and the agent zoomed out 12 s later. Probably a mid-animation frame. Recheck in the
  full pass.
- **"Create account" could not be clicked by name.** This is a harness artefact (see above); a pixel click worked.
- **Console:** only "GL Driver Message … GPU stall due to ReadPixels" warnings during the export (software WebGL).

**Confused**
- "West 4th Avenue and Yew Street", how a café owner says where the shop is, gave "No match. Try the street and
  block, e.g. 1000 Robson St." A house number worked.
- The click meant to pick the parklet's side landed on a street-tree dot and opened the tree's popup instead. The
  agent closed it and clicked an empty patch (`parent-run1\015.png`). The map is dense with layer dots
  (`parent-run1\014.png`).
- Check asks to confirm 88 imported items one by one, and there is no "confirm all". The agent exported anyway, and
  the site allowed it.
- The agent read "2 bus stops within 80 m" (the route-type note) as the reason for the bus zone. The bus zone
  actually comes from a stop within 15 m of the deck ("C01 set to a bus zone from a bus stop beside the deck"). The
  two notes are easy to conflate.

**README / landing wrong**
- README step 3 ("search an address") does not say a house number is needed and an intersection is not found.
- The README sets no expectation for the export time.

### Run: Persona 1 (BIA coordinator), run 1, Sonnet

- **Site:** Main Street, Mount Pleasant, east side. Block A is the 2000 block (near E 8th Av / Kingsway, host not
  recorded). Block B is the 2500 block (near E Broadway, host Barney's On Main).
- **Time:** 8 minutes to the first sheet (17:54 → 18:02), 19 minutes in all. Block B's export took 78 s (click at
  18:00:28, file at 18:01:46).
- **Outcome:** two PDFs. `curbside-untitled-parklet-schematic.pdf` (Block B, 521 kB) and
  `curbside-main-st-block-a-2000-block-schematic.pdf` (Block A, 531 kB). Both blocks "do not pass", for the same two
  reasons: C01 is a bus zone, and C02 gives 7 lanes of 3.164 m against 3.2 m.

**Broke**
- **The same numbers at both blocks, to the millimetre:** curb to curb 27.20 m, seven lanes at 3.164 m, C02 short by
  36 mm. *Verified, and it is real output* (`p1-run1\044.png`). At both blocks the import merged two one-way OSM ways
  into a dual carriageway of 4 + 3 lanes ("two one-way carriageways merged", "median not modelled"). The
  curb-to-curb width is then the estimate 7 × 3.2 + 2 × 2.4 = 27.2 m, not a measurement, so any two sites with the
  same lane tags give identical numbers. Main Street there is not a seven-lane road.
- **Sidewalk estimate 0.5 m at Block A and 1.0 m at Block B.** 0.5 m is the field's minimum. The over-wide
  curb-to-curb estimate puts the estimated curb at, or past, the building faces, so the "nearest building face"
  sidewalk is clamped. This follows from the item above.
- **The first export click "did nothing".** *Partly a harness artefact:* the first click by text timed out (it
  matched hidden text). The following pixel click did start the export, but the page then froze for over a minute
  with no sign of progress, so the agent clicked again. Creating Block A's design ("+ New", Create Design) also froze
  the page for more than a minute.
- **Console warnings:**
  - `[checkLandmarkConsistency] 1 value(s) disagree -- a renderer or shim is out of sync with DESIGN_MODEL: north: 3D compass`.
  - `[report] layout check: {overlaps: Array(0), outside: Array(1), texts: 2566}` (and `texts: 2663` for the second
    report): one text outside the sheet on each PDF. The same export at Commercial & 1st on Pages had 0 outside.

**Confused**
- The landing page says "Create account: invite code required — contact …". The sign-up form has no invite code
  field, and README step 2 says sign-up is open during the review. The agent did not know which to believe.
- Opening "Create account" shows the whole app shell behind the dialog, so for a moment it looks like you are
  already in.
- "+ New" for the second block gave no warning that the first, unsaved design would be replaced. The agent had
  downloaded its PDF by habit. *This was signed out, the test arrangement; with an account the design may autosave.
  Recheck in the full pass.*
- "2000 Main St, Vancouver" returned five neighbourhood-level "Main Street" results and no block. The agent guessed
  Mount Pleasant and clicked the block on the map.

**README / landing wrong**
- The landing page's "invite code required" contradicts README step 2 and the form.

### What the smoke pass says about the full pass

Every run on a commercial arterial will report the same verdict: does not pass, for C02 and usually C01. **C02 fails
by construction wherever the curb-to-curb width is the import's estimate.** The estimate is the lanes at exactly
3.2 m plus 2.4 m parking lanes. The 2.65 m deck then takes a 2.4 m parking lane, so each lane comes out
0.25 m ÷ (lanes) under 3.2 m on every bus or truck route: 3.138 m on W 4th, 3.164 m on Main, and 3.075, 3.117 and
3.138 m at the three VERIFY sites. Persona 2 (Manual references), 4 (inputs) and 8 (dimensions) would each spend
their runs on it. Fixing or relabelling this before the full pass would let the full pass find other things. The
brief says fix nothing, so it is left for Jenna to decide.

The landing page's invite-code line will also be reported by every persona that reads the landing page.

## Triage

| issue | seen by | severity | suggested fix | brief |
|---|---|---|---|---|
| C02 fails by construction when curb to curb is the import's estimate (lanes × 3.2 + parking; the 2.65 m deck takes a 2.4 m lane), so every bus / truck route "does not pass" | Parent, 1 (and all three VERIFY sites) | misleads | Do not judge C02 on an estimated width: report it "not entered, measure curb to curb" (or provisional with the reason stated) until the width is measured or confirmed | 25 |
| Dual carriageway merged near an intersection: 4 + 3 lanes, curb to curb 27.2 m, identical at two blocks of Main Street | 1 | misleads | Count only the through lanes at the site (turn lanes and split ways near intersections inflate the count); flag merged carriageways for the user to confirm | 25 |
| Sidewalk estimate clamped to 0.5 m (and 1.0 m) because the over-wide curb estimate reaches the building faces | 1 | misleads | When the face is nearer than the estimated curb, say "curb position unknown" instead of a clamped value; this follows the two fixes above | 25 |
| PDF export freezes the page for 1–2.5 min with only "Preparing the PDF…" (screenshots time out) | Parent, 1 | misleads | Build the PDF in steps that yield to the page (or in a worker), with a sheet-by-sheet progress line; README gives the expected time | 25 |
| "+ New" / Create Design also freezes the page for over a minute | 1 | annoys | Profile the new-design path (likely the same rendering as export) | 25 |
| Landing page says "invite code required"; the form has none and README says sign-up is open until 9 Oct | Parent, 1 | misleads | Make the landing line follow `CONFIG.INVITE_ONLY` (or edit it now and restore it after 9 Oct) | 25 `readme` |
| Address search: an intersection ("W 4th Av and Yew St") finds nothing; "2000 Main St" gives neighbourhood-level results | Parent, 1 | annoys | Accept "X and Y" by geocoding the cross street; README step 3 says to use a house number | 25 `readme` |
| The side-of-street click opens a tree (layer) popup instead of picking the side | Parent | annoys | While a street is picked and the side is awaited, a click picks the side; popups only on hover or after the pick | 25 |
| 86–94 imported items to confirm one by one; no bulk confirm | Parent, 1 | annoys | "Confirm all of this kind" per group (hydrants, trees, …), keeping single confirms | 25 |
| Route-type note "n bus stops within 80 m" next to C01's "bus stop beside the deck" reads as the bus-zone reason | Parent | annoys | Name the stop and its distance from the deck in C01's row; drop or rename the 80 m count | 25 |
| One text outside the sheet in each Main Street PDF (`[report] layout check … outside: Array(1)`) | 1 | annoys | Reproduce at 2000 / 2500 Main St and find the overflowing label | 25 |
| `checkLandmarkConsistency`: north of the 3D compass disagrees with DESIGN_MODEL | 1 | annoys | Reproduce at Main St (street axis 2°); fix the compass sync | 25 |
| Sign-up dialog opens over the full app shell, so it looks like you are already in | 1 | annoys | Dim or blank the shell behind the auth dialog | 25 |
| "+ New" replaces an unsaved signed-out design with no warning | 1 | annoys | Warn when the current design is unsaved (recheck signed in during the full pass) | 25 |
| Blank map right after choosing a search result | Parent | annoys (unconfirmed) | Recheck in the full pass; if real, wait for the fly-to before handing control back | 25 |
| README does not say how long the export takes | Parent | annoys | One line in step 7 | 25 `readme` |

Harness, before the full pass (not app issues): the driver should prefer visible matches for text and name clicks;
persona 6 needs accounts made by Jenna.

## Full pass

Site under test: https://jennabruggeman.github.io/curbside/ at v0.12-fixes (master `316d637`, published 2026-10-01
04:50 UTC; Pages built 36 s after the push). Started 2026-09-30 22:00 Vancouver time. Nothing was fixed during the
pass.

### How it was run (read this before the runs)

- **Personas and models:** 1–6 on Claude Sonnet, Parent, 7 and 8 on Claude Opus; two runs each, a third where run two
  found something run one did not; at most three agents at a time.
- **Driver:** the smoke pass's HTTP driver with four changes (`<scratchpad>\b23\driver2.js`): a click, fill or hover by
  text, role, label or placeholder takes the first visible match (the smoke pass's harness artefact); a touch mode with
  a `tap` command (persona 7: 1024 × 768, `hasTouch`); a page zoom (persona 5: 150 %, the CSS viewport 933 × 600); a
  `newbrowser` command (persona 6: a fresh context, no storage). No script evaluation: an agent sees what a visitor
  sees. The agents had the landing page and README.md (the v0.12 copy), nothing else.
- **No accounts, again.** Agents opened the sign-up and sign-in forms and recorded them, did not submit them, and
  continued signed out at `parklet-checker.html?noauth`. No password was typed anywhere. **Persona 6** therefore ran
  what a returning user can do signed out (save in this browser, come back in a new browser) and lists the
  signed-in round trip (sign up, save, sign out, sign in on a new browser) as steps for Jenna to run.
- **Persona 8** got a finished technical PDF made on the live site (E 10th Av at Main St, the 7-piece test design,
  14 pages: `<scratchpad>\b23\p8-input\curbside-main-street-technical.pdf`) and the Parklet Manual, and did not use
  the app.
- **Seen before the runs (harness check):** the first load logs a console warning `[route] ReferenceError: GEN is not
  defined at ACC.planSVG` (the Plan's route drawing runs before the layout model is defined; caught, nothing breaks).
  Agents that read the console will report it; it is one issue.
- **Screenshots and driver logs:** `<scratchpad>\b23\full\<persona>-run<n>\` (numbered PNGs, `driver-log.jsonl`, the
  agent's `report.md`). `<scratchpad>` is
  `C:\Users\bangp\AppData\Local\Temp\claude\C--Users-bangp-Desktop-UBC-Fall-2026-ARCH-540-AI-New-folder\53c36af6-f1db-4db4-82b7-a08691d53a6f\scratchpad`.
- **Checked against the evidence.** Each run block below is the agent's report, condensed; an item I could not
  confirm from the log or the screenshots says so.

### Run: Parent (café owner), run 1, Opus

- **Site:** 2611 W 4th Av, Kitsilano, north side (host Dark Table). **Time:** about 30 minutes to the schematic PDF (14
  pages); the export took about 100 s with three browsers rendering in software at once (3.6–12 s alone, VERIFY).
- The agent could not write its `report.md` (the tool refused); its report is condensed here.
- **Broke**
  - C01 does not follow the deck: after shortening the deck to 12 m the stop is listed "at z 21.9 m (9.9 m past the
    deck)", yet C01 still fails ("bus zone disqualifies this location") and Generate says "cannot pass whatever the
    design". The same list gives the one stop two positions ("at z 20.4 m: a bus zone" and "at z 21.9 m").
  - C01's row reads "SITE CONDITION Unknown. Enter parking restrictions for this site below." above a dropdown already
    set to "Bus zone present". (Confirmed in code: the site-condition text is static; C05 does the same, see persona 1.)
  - The Check side panel reads "Nothing imported to confirm" directly above "42 imported items still to confirm".
  - The bearing field shows "91.40999999999997".
  - "Roadway 17.600 m Allocated 17.602 m Over 0.002 m" in red: a rounding leftover flagged as an error.
  - "Near lanes … lanes=4" and "Far lanes … lanes=4" on a street called "4 lanes (two-way, 2+2)".
  - Dates: "imported 2026-10-01" beside a report dated 2026-09-30 (the import stamps the UTC date).
  - Shape editor: dragging an edge did nothing in two tries (typing a length worked); Escape left the Plan-only view
    and squeezed the editor (not checked: the drag may be the harness's mouse drag).
  - Enter in the left "Street address" box does nothing, and the address is not passed to the map search.
  - Console: about 20 `[route] ReferenceError: GEN is not defined at ACC.planSVG` on load; after the export
    `[report] layout check: {overlaps: Array(1) …}` (one overlapping text on a sheet at this site; not identified).
- **Confused**
  - "Does not pass yet … confirm or correct it on site" reads as maybe; Generate's "cannot pass whatever the design" as
    a flat no. What does "confirm on site" mean for a shop owner: measure it myself, or call the City?
  - The jump from the friendly "Choose a site" card to a full CAD workspace (lane numbers in red) after the import;
    jargon: "OSM way", "axis 91° from north", "z 21.9 m", "Provisional", "End zone", "SF / CALC / DI",
    "GEN-cafe_table", "seed 1 · 0 sampled", "bus_zone".
  - No pin on the shop after the map search; no hint to click the deck after "Place".
  - The lane check feels circular: the estimate is lanes × 3.2 m + parking, and C02 then says the lanes are 3.138 m.
  - The shape editor shows no hydrant or bus stop, so the deck was shortened blind; its ruler runs 20 → 0 m.
  - "Renders (cover and V-101 …)" is ticked although there are no renders; nothing says the PDF has downloaded.
- **README / landing wrong:** the landing page says "Site, design, check — the tool's three working tabs" and "The
  eighteen checks" (no C16); its footer says "Curbside v0.11-gis" (the PDF says v0.12); step 7's "under 20 s" was
  100 s here (load); Generate's message is in code words ("01 Parking restrictions = bus_zone").
- Evidence: `<scratchpad>\b23\full\parent-run1\` (001–054.png, the PDF).

### Run: Persona 1 (BIA coordinator), run 1, Sonnet

- **Sites:** Main St east side, block A at E 20th Av and block B at E 16th Av. **Time:** about 35 minutes for both PDFs.
- **Broke**
  - C05 on block A: three imported hydrants listed 12.8 m and more from the deck, yet the row said "Unknown. No fire
    hydrant location data provided" and "0 m < 5 m … Fails"; block B computed 29.12 m. **Not reproduced:** at Main & E
    20th, east side, C05 passes at 34.68 m (provisional); the 0 m most likely came from the agent's typing into the
    hydrant field (next item). The static "Unknown. No fire hydrant location data provided." beside imported hydrants
    is real (as C01's).
  - The hydrant distance field: clicking and typing "12.8" gave "0.001", "0.0011": a click does not select a number
    field's value, so typing appends (browser behaviour, but the field accepts the result silently).
  - "+ New": the Street Address text was appended to the Design Name ("Main St at E 16th (Block B)Main St & E 16th Ave"),
    which then printed on the cover and in the file name. (Not checked; may be the same append-on-type behaviour.)
  - After "+ New" the Site panel's "2 Import context" still shows the previous design's import summary, and "Locate on
    map" keeps the old search text, so the new query was appended ("No match" twice).
  - Console: `GEN is not defined` repeated on every PDF build; `[report] layout check: overlaps: Array(1)` on both.
- **Confused:** the landing list skips C16; a provisional fail sits in "Fails" with a pill (as designed); the two
  blocks' banners had different buttons ("Open C05" against "Survey sheet (PDF)") for what looked like the same state;
  no indicator of which design is open except the title.
- **README / landing wrong:** only the C16 gap; the steps matched.
- Evidence: `<scratchpad>\b23\full\p1-run1\report.md` and screenshots.

### Run: Persona 2 (M.Arch student, Manual references), run 1, Sonnet

- **Site:** W 4th Av at Yew St, north side (host Buddha Barn). **Time:** about 25 minutes to the PDF, 15 more for the
  Manual. The agent could not write its `report.md`; condensed here.
- **Manual references:** every citation matched the Manual's page and number except:
  - **C06 cites p. 20; the driveway / lane 1.5 m setback is on p. 62, P2 Setbacks.** Confirmed in the Manual (p. 20 has
    no driveway sentence; p. 62 does). The number agrees.
  - C16: the app's 1.1 m route is BCBC's (X-001 says so); **the Manual's G19, p. 60 asks for a 1.5 m wide clear access
    path** and a 1.5 m turning circle. The agent read the turning space as matched and the width as not.
  - C19 cites "E5, p. 65"; the agent read the 2.1 m sentence as E4. **Not so:** the bullet "Any overhead elements must
    be a minimum 2.1 m above the platform" is in E5's list (the page's third column continues E5). E5 stands.
- **Broke**
  - "Technical selected, the PDF came out Schematic." **Harness, not the app:** the screenshot after the agent's click on
    the text "Technical" (040.png) still shows Schematic selected; its later click by pixel selected Technical and that
    export is the technical PDF (both files are in the folder). The agent read the first file.
  - **C02 stays "Awaiting measurement" after the curb-to-curb width is entered.** Reproduced (W 4th at Yew, north side):
    the width becomes "confirmed by you", but "Far-side parking lane: estimate" remains, so C02 still awaits, and its
    message still says "Measure curb to curb: … on the estimated 18.40 m". The remaining estimate is not named and the
    agent found no way to confirm it.
  - "17.6184" in the width field: the agent's "Backspace ×10" sent one Backspace (the driver has no repeat): harness.
    Its point stands that the field accepts a garbled value silently.
  - `GEN is not defined` (20+ times); "imported 2026-10-01" against data and a report dated 2026-09-30.
- **README / landing wrong:** none in the steps; the landing page's "eighteen checks" without C16.
- Evidence: `<scratchpad>\b23\full\p2-run1\` (screenshots, both PDFs, `checktext.json`).

### Run: Persona 4 (sceptical engineer), run 1, Sonnet

- **Sites:** 4500 Kingsway, Burnaby (Willingdon Av), then 40 m curb to curb and 0 near lanes there; Pipeline Rd at
  Stanley Park Dr (a road inside the park). **Time:** about 35 minutes to a 13-page PDF of the park site. The agent
  could not write its `report.md`; condensed here.
- **What held up:** Burnaby: "No data for this location: the site data covers the City of Vancouver. The point is kept
  as clicked …", then an import of estimates, clearly labelled. 40 m curb to curb: the lanes capped by EDM Table 8-10
  (3.40 / 3.20 m) and "Remaining 28.350 m" left unallocated, no crash. The park road imported as a street, with "1
  parks" in the city context; C05 failed on a hydrant at the curb (plausible). The PDF matched the Check tab.
- **Broke**
  - **"Near lanes" = 0 is shown and tagged "You", but ignored.** The Section still draws two travel lanes and C02 still
    measures "2 lanes". Confirmed in code: the field's minimum is 1 and `onLanesAChange` returns without a word on 0,
    while the provenance records the typed 0 as the user's value.
  - "imported 2026-10-01" on an import made 2026-09-30 (the UTC date; as the other runs).
  - `GEN is not defined` on every Plan redraw; `[report] layout check: overlaps: Array(1)` on the PDF (one overlapping
    text, not identified; also in Parent and persona 1).
  - The footer breadcrumb says "Vancouver · Site" for a Burnaby site.
- **Confused:** the 28.35 m left over at 40 m gets no suggestion (add parking, planting, a median); a place name
  ("Beaver Lake, Stanley Park") finds nothing, so a point with no street near it could not be tried; the 0-lane entry
  gave no inline warning.
- **README / landing wrong:** none found; Blank street not tried.
- Evidence: `<scratchpad>\b23\full\p4-run1\` (001–047.png, the PDF).

### Run: Persona 5 (accessibility, keyboard only, 150 %), run 1, Sonnet

- **Site:** none reachable by keyboard (see below), so the blank street. **Time:** about 35 minutes to the PDF.
- **Broke**
  - **The sign-in / sign-up dialog traps the keyboard:** focus is not moved into it, Tab goes to the controls behind the
    overlay (disabled-looking ones take focus and show tooltips), Escape does nothing and there is no close control.
    The agent had to leave by URL. (Persona 6 also found no way to close it: Escape and a click outside did nothing.)
  - **A real site cannot be chosen by keyboard:** the map search's suggestion cannot be reached (ArrowDown does
    nothing, Tab skips it to "Search"), and "click the street, then the side" has no keyboard way.
  - "Place" on a furniture card put an armchair in the 3D view, but C16 kept "Nothing placed yet" and no keyboard way to
    select or move the placed piece was found. (Not checked: the piece may still have been in placing mode.)
  - The sample report "goes blank" and "one press gave three PDFs": **harness** (headless Chromium has no PDF viewer,
    so the sample's PDF frame downloads instead of showing: the two UUID-named files are from the two sample visits;
    the Download button made one file).
  - **The sample report's banner reads "18 pass, 1 fail":** confirmed: the reference design now fails C19 ("umbrella
    2.10 m clear, past the footprint"), so the sample no longer shows a passing design.
  - `GEN is not defined` on every page.
- **Confused:** Escape behaves three ways (nothing in the sign-in dialog, closes the map dialog, leaves the sample page
  for the landing page); 10–20 Tab presses to reach "Start a blank street", "Download report (PDF)" or the first
  "Place", with no skip links or headings to jump by inside the app.
- **README / landing wrong:** the landing page's check list has no C16, the one check about access; README step 3's
  "click the street" has no keyboard alternative.
- Evidence: `<scratchpad>\b23\full\p5-run1\` (001–087.png, the PDF).

### Run: Persona 6 (returning user, signed out), run 1, Sonnet

- **Site:** W 4th Av at Yew St, south side. **Time:** about 30 minutes; no PDF needed. Signed out throughout (no
  account; see the steps for Jenna below).
- **Broke**
  - **Placed furniture is not saved.** After placing three pieces and reloading, the site and the name came back but the
    Furniture tab said "Nothing is placed on the deck yet" (042.png). **Reproduced:** two pieces dropped from the
    library onto the Plan, 3 s, reload: 0 pieces; the stored design held 0 pieces before the reload. Placing a piece
    does not save the design; a later action that saves (switching tabs did, in my check) writes it. Signed in the
    autosave may cover it; not tested here (no account). **This loses work.**
  - The sign-in dialog has no close control; Escape and a click outside do nothing (as persona 5).
  - `GEN is not defined` on every Plan render.
- **Confused:** a new browser shows a blank "Untitled parklet" with no word on where the earlier design went or that an
  account keeps designs; signed out there is no "My designs", save or open control, and nothing in the app (only the
  landing page) says that designs are kept in an account; "+ New" asks for a name and gives no warning about the open
  design.
- **README / landing wrong:** the landing page's check list has no C16.
- **For Jenna (needs an account):**
  1. Create an account from the landing page (Name, Email, Password, Confirm; no code during the review). Check: where
     it lands; whether the header shows the account and a "My designs" entry. Also check the confirmation email's link
     (the 404 fix needs the Supabase redirect setting, HANDOFF).
  2. Locate W 4th Av & Yew St (south), import, name it, place three pieces. Check: a "Saved" / "Saving…" indicator;
     **then reload without switching tabs and check the pieces are still there** (the signed-out run lost them).
  3. Sign out from the account menu. Check: any warning about unsaved changes; where it lands.
  4. In a new browser (or a private window), sign in. Check: the design list shows the design; opening it restores
     the site, the three pieces and the name.
- Evidence: `<scratchpad>\b23\full\p6-run1\` (001–049.png).

### Run: Persona 8 (City staff reviewer, the PDF only), run 1, Opus

- **Input:** the technical set for E 10th Av at Main St (14 pages) and the Parklet Manual; no app. **Time:** about 10
  minutes. (The agent rendered the pages itself; the Read tool could not, pdftoppm is missing.)
- **The three dimensions**
  - **Adjacent travel lane:** "3.16" on A-201, A-202, A-102 (scales true: 28.00 m at 1:100, 17.60 m at 1:250) against
    3.2 m on a bus / truck route (p. 20, p. 62): **disagree.** And the set contradicts itself: C-001 p. 10 says C02
    "AWAITING MEASUREMENT", C-001 (cont.) p. 11 marks all seven lanes "3.20 FAIL" (confirmed in the PDF text; the lane
    envelope now sits on the page after C02's row since C-002 was folded into C-001), and the cover counts one fail.
  - **Hydrant clearance:** "21.51 (≥5.00 C05)" on A-102 against 5 m (p. 21): **agrees**, but the dimension runs off
    A-102's frame (its drawn length scales to about 6.5 m, not 21.51) and the hydrant on A-101 has no label. The value's
    source is "entered" on S-002, "measured from placed site objects" on X-001 and "imported, not yet verified" on G-001.
  - **Deck flush with the sidewalk:** the levels give the deck "+0.07" over the "±0.00 top of curb", i.e. 70 mm proud,
    against "flush … maximum 12 mm" (P3, p. 62): **disagree.** Note 8 speaks of the horizontal gap only, and C14 is
    "not entered". (Consistent with the model: curb top 0.15 m, deck top 0.215 m above the road.)
  - Extra: enclosure 0.90 m (scales true at 1:50) against 0.75–1.0 m (E2, p. 64): agrees.
- **Broke**
  - **The deck is 2.65 m wide; the Manual says the 3.0 / 3.2 m lane rule "will lead to a maximum width of 2.3-2.5 metres
    for parklet structures" (p. 20, confirmed).** Nothing flags it.
  - Dimension strings that do not close: A-201 0.80 + 2.65 + 7 × 3.16 + 2.40 = 27.97, overall "28.00"; A-102 9.77 against
    "9.78" (3.164 rounded per segment).
  - "top +0.21 m above the road" (notes on A-201 and A-202) against the levels' 0.22 (0.215 rounded two ways).
  - A-102: "21.51 (≥5.00 C05)" and "6.00 (≥6.00 C03)" are cut by the plan's frame; the 6.00 C03 zone is drawn as if
    measured although C03 is "not entered".
  - The bus stop's position: "z -7.1 m: a bus zone" on X-001, "-13.89 m (z)" on S-002.
  - A-101 note 3 says "genus tags on A-102"; A-102 has none (confirmed in the PDF text): a dead reference.
  - Text crossed by lines: "0.07" on A-201 and A-202 by the road line; the deck-end symbol over "2.65" on A-103; the A-A
    line through "17.60" on A-102.
  - C16 "Guideline (Manual page to confirm)", BCBC 3.8 in X-001 (as persona 2).
- **Confused:** the deck-end symbol (circle with a dot, a bar) matches the legend's "Utility pole" while note 4 calls it
  a flexible bollard and wheel stop; "Sidewalk width 0.80 m estimate" on Main St; C03 "not entered" at a corner
  address; two cherry trees drawn on the curb line at the deck edge, advisory only; C-001 applies the 3.2 m test to all
  seven lanes, not only the adjacent one, and calls 3.16 m an EDM "absolute minimum (City Engineer approval)".
- **Verdict as a reviewer:** "I would return this set": C01 fails (bus zone) and the deck is wider than 2.5 m. Trusts the
  scales and most citations; distrusts the self-contradicting C02, the deck level against the flush note, the strings
  that do not close and the cut-off dimensions.
- Evidence: the agent's report (this block); the input PDF in `<scratchpad>\b23\p8-input\`.

### Run: Persona 3 (landscape designer), run 1, Sonnet

- **Site:** Main St at E 23rd Av, east side (host Wong's Insurance, 3900 Main St). **Time:** furniture placed within
  about 10 minutes; the PDF (14 pages) much later, after long unresponsive stretches. The agent could not write its
  `report.md`; condensed here.
- **What worked:** dragging library cards onto the deck, the Selection panel (size, finishes, snap, align), the 3D
  view, Visualize's Sun panel ("A 1 m post casts a 0.57 m shadow toward NW"); **C16 named the agent's own pieces** as
  the obstructions ("0.30 m at z 3.25, beside the tree pit at z 4.75 …") and **deleting the curved bench removed its
  clause**: the furniture-to-check link worked.
- **Broke**
  - **"Place" on a card did nothing visible:** it switched to Design with an empty deck, and only dragging placed a
    piece. (Place starts a placing mode that waits for a click on the deck; nothing says so. Parent run 1 met the same:
    "after Place nothing told me to click on the deck".)
  - "The drawing list on A-000 disagrees with the footers": **not so.** The rendered A-000 lists V-000 Cover, G-001 What
    to do next, A-000 Title sheet, A-101 Site plan … in line; the agent read pdftotext's column layout, which shifts the
    title column two rows. On the same page, "C01 – C19 Parklet Manual checks (C16 reserved)" is out of date (C16 exists
    now) and G-001 has no scale.
  - The app was unresponsive for minutes at a time after selecting and deleting a piece in the Plan (every command timed
    out; it recovered and the delete went through). Not checked; three browsers were rendering in software at once.
  - `GEN is not defined` on every Plan render; `[report] layout check: overlaps: Array(1)` after the export.
- **Confused:** after a delete, the selection handles stayed on the Plan where the bench had been; the route overlay and
  the floating Plan key appeared unasked and could not be dismissed (the key folds; the agent did not find that).
- **README / landing wrong:** step 5 "place furniture from the Library" does not say it is drag and drop while each card
  has a "Place" button.
- Evidence: `<scratchpad>\b23\full\p3-run1\` (001–100.png, the PDF).

### Run: Persona 7 (tablet, touch, 1024 × 768), run 1, Opus

- **Site:** W 4th Av at Yew St, south side (host Mejuri, 2170 W 4th Av). **Time:** about 20 minutes to the PDF (14
  pages). The agent could not write its `report.md`; condensed here.
- **Broke**
  - **The header's right end is off-screen and cannot be reached:** the design name shows as "Untitle…", and "+ New",
    "?" and "Sign in ▼" (with Settings) are past the right edge. **Confirmed, and wider than tablets:** the header does
    not shrink below about 1360 px. At 1280 × 800, a common laptop width, "?" (1280–1297 px) and "Sign in" (1305–1356 px)
    are off-screen and the page cannot scroll sideways, so **nobody on a 1280 px screen can sign in**; at 1366 px they
    fit. At 1024 px "+ New" is gone too.
  - The Check table's Result column is cut off ("Fail prov…", "Awaiti… measure…") and Source is not visible; a sideways
    swipe scrolls the page instead.
  - **Furniture cannot be placed by tapping:** a tap outlines a card, and tapping the deck afterwards does nothing; only
    a drag places a piece (the driver's drag is a mouse drag; a real finger may not start HTML drag and drop). The cards
    are not buttons in the accessibility tree. (Persona 3 and Parent met the same "Place" gap with a mouse.)
  - The C01 row's "Unknown …" above "Bus zone present"; "Nothing imported to confirm" above "92 imported items still to
    confirm" (as Parent).
  - After dragging a bench on the Plan the Selection panel kept "Along 13.000" until it was reselected ("8.036", off the
    0.25 m snap grid shown below it).
  - Bearing "91.2900000000002"; "Over 0.002 m"; "imported 2026-10-01"; landing footer "v0.11-gis" against v0.12.
  - PDF A-103: the A–A line through "19.80"; "2.65" over the end symbol; "1.10 clear" over tag 2. PDF S-002: "Nearest
    hydrant to the deck (C05) 31.21 m entered" although nothing was entered (X-001: "measured from placed site objects").
  - `GEN is not defined` twice.
- **Confused:** dimensions on furniture cards show only on hover; tap targets too small (import check boxes ~13 px,
  colour swatches ~12 px, selection handles ~8 px, zoom buttons ~22 px); a hover tooltip on a number field covers the
  fields below and describes the parklet's centre, not the selected piece; the Plan key covers half the Plan in the All
  view at this size; the Plan draws "6.00 (≥6.00 C03)" and "1.50 (≥1.50 C13)" as if met while both are "Not entered";
  the counts' words differ between the sidebar, the groups and the PDF ("12 not confirmed (provisional …)" for checks
  with no value at all); the deck was put beside a bus stop automatically and nothing suggested another frontage.
- **README / landing wrong:** landing "eighteen checks" (no C16) and "three working tabs"; README step 5 does not say
  furniture is placed by dragging; README says Settings is in the account menu, which is off-screen at this width;
  S-002 says "Site > Survey", which the agent did not find (it did not scroll the whole Site panel).
- Evidence: `<scratchpad>\b23\full\p7-run1\` (001–040.png, `pdfpageN.png`, the PDF).

### Run: Persona 1 (BIA coordinator), run 2, Sonnet

- **Sites:** Denman St, West End: block A at Davie St (south-east side, host Starbucks, 1789 Davie St), block B at Comox
  St (north-west side, host Denman Dry Cleaner, 1075 Denman St). **Time:** about 12 minutes to block A's PDF. The agent
  could not write its `report.md`; condensed here.
- **New since run 1**
  - **Both Denman blocks fail C01 as a bus zone**, so the comparison a coordinator wants ("this block passes, that one
    does not") never appears: the two reports have the same counts (4 pass, 1 fail, 1 awaiting, 13 not entered). After
    "Confirm all visible (70)" the verdict turned to "Does not pass: 1 check fails on measured data": confirming the
    stop turns a provisional bus-zone fail into a measured one.
  - **Two reports, one file name:** both designs were "Untitled parklet", so both PDFs are
    `curbside-untitled-parklet-schematic.pdf`; the file name carries no address. (The second download overwrote the
    first in the test folder: the driver saves by the suggested name; a desktop browser would add "(1)". The point
    stands for anyone comparing blocks.)
  - "Generate produces nothing": **harness.** The agent clicked by role and name "Generate", which matched the
    "Generate" tab before the panel's own "Generate" button (046.png shows the button untouched). Generate itself
    answered "This site cannot pass whatever the design" in Parent run 1.
  - "+ New" then typing the name: the driver's fill failed ("Cannot read properties of undefined (reading 'unicode')",
    a Playwright error), "Create Design" timed out and the page stopped answering for about four minutes; afterwards the
    canvas showed "Choose a site" while the Site panel still showed the previous design's import and host frontage
    (as persona 1 run 1 saw). The freeze is not confirmed as the app's (three software renderers were running); the
    stale Site panel after "+ New" is (two runs).
  - Bearing "44.72999999999999999".
- **README / landing wrong:** none confirmed (the Generate mismatch is the harness).
- Evidence: `<scratchpad>\b23\full\p1-run2\` (screenshots, `blockA_pdf.json`, `blockB_pdf.json`, block B's PDF).

### Run: Parent (café owner), run 2, Opus

- **Site:** Union Market, 810 Union St, Strathcona, south side (a quiet residential street, no bus route). **Time:**
  about 43 minutes to the schematic PDF (13 pages), about 15 of them with the page frozen (Generate, Open in Design, tab
  switches, the PDF; three software renderers at once). Route: Generate, then Open in Design; no furniture placed by
  hand. The agent could not write its `report.md`; condensed here.
- **New since run 1**
  - **Typing in a Check field loses keystrokes** ("17" became "1"): the row jumps to another group after the first
    digit and the field loses focus; the banner flashed "Does not pass". **Reproduced, and it is a regression from Brief
    25 item 31** (the grouping): typing "17" into C03's field at Dunbar leaves "1" and focus on nothing; the first digit
    changes the row's state (not entered → fail) and the regrouping moves the row out from under the cursor. Every
    persona who types a measured value meets it.
  - **Opening a generated scheme wipes the imported context:** 156 imported items down to 1, Site "not imported", the
    estimate badges gone, the PDF "No street trees in this stretch" and "No imported street is recorded"; Export says
    "Locate a site first" with the site set. **Reproduced** (Dunbar): site objects 35 → 1, trees 31 → 0, the import record
    and the existing street gone, and **C02 goes from "Awaiting measurement" to "Pass" on the estimate it no longer
    knows is one**, against the rule the page states.
  - **Generate needs ten site facts typed in Check first** ("Set these site facts first … 01 Parking restrictions; 03
    …; 13 …"); README step 5 does not say so. After the facts are set the main "Generate" button is gone and the old
    message stays; the second button is inside the folded "Output" section. Generate's cards say "19/19 checks" and
    "passed every check" while C02 still awaited a measurement. Clicking an item under Generate › Site facts does
    nothing.
  - A slope typed as "1" was stored as "0.1 %" (probably the keystroke loss: not separated).
  - Mouse clicks on a native dropdown's options did not register (the keyboard did; may be the harness); the dropdowns
    have no accessible name ("combobox").
  - After the scheme, the Section reads 2.80 | 2.40 | 3.00 | 3.00 and the PDF "Beside the parklet: Parking, 2.40 m",
    parking between the deck and traffic, where the import had the parking on the far side.
  - Console after the PDF: `[checkLandmarkConsistency] 4 value(s) disagree … Plan vegetation count; Plan transit count;
    section: cut objects drawn vs getSectionScene; section: beyond objects …` (after the scheme opened).
  - Counts read differently: the side summary counts provisional passes inside "passing" and again as "provisional"
    ("19 passing · 1 provisional" against groups "Pass 18 · Provisional 1"); the PDF cover's "0 not confirmed
    (provisional)" while one hydrant waits to be confirmed. Consistent sums, confusing words.
- **Confused:** guessed distances count as measured (nothing tells "guessed" from "measured"); C06 has no "no driveway
  nearby"; C10 and C11 have opposite good answers ("No – confirmed clear" against "Yes – all drains clear"); C03 not
  filled by the import with Hawks Av at the corner; the 19.8 m deck runs past the 7.00 m frontage onto the neighbours'
  curb with no word about it; the step strip lit "1 Site" while in Design, and nothing on Generate; the README's
  "Override" button was never seen (only "Confirm").
- **README / landing wrong:** step 5 (Generate's facts); step 2 (the strip was still there right after the first
  export: not checked after a reload; it hides on the next tab change); step 3's "with its house number" while the Site
  panel's example is "1000-block Robson St"; "Override" (step 4) not found.
- Evidence: `<scratchpad>\b23\full\parent-run2\` (screenshots, the PDF).

### Run: Persona 2 (Manual references), run 2, Sonnet

- **Site:** W 10th Av at Tolmie St, south side (host Pizza Pizza, 4574 W 10th Av; it turned out a bus / truck route,
  the 99 B-Line). **Time:** about 25–30 minutes to the technical PDF.
- **Manual references:** C01–C15 matched page and number (the agent placed C06's driveway sentence on p. 20 this time;
  run 1 and the Manual's text put it on p. 62 only: run 1 stands). C16: the Manual's G19, p. 60 asks for a 1.5 m wide
  access path; the app's 1.1 m route is not in the Manual (as run 1).
- **New since run 1:** the way to make C02 pass, found by elimination: entering the curb-to-curb width is not enough;
  **confirming the separate "Far-side parking lane estimate" in the side list** is what moved C02 to "Pass
  (provisional)"; the row never names it (run 1's dead end, now with its exit). Clicking the word "Technical" did not
  select it, a click on the radio did: **not reproduced** (a click on the word selects Technical here): harness.
- **Confused:** nothing before the import says a street is a transit corridor; the PDF cover's "12 not confirmed
  (provisional)" covers the "Not entered" checks.
- **README / landing wrong:** none; export time 60–90 s here (load).
- Evidence: `<scratchpad>\b23\full\p2-run2\` (001–063.png, the technical PDF).

### Run: Persona 4 (sceptical engineer), run 2, Sonnet

- **Sites:** the blank street pushed to extremes, then Dunsmuir St at Richards St (one-way, three lanes, bus / truck
  route, a separated bike lane), the deck on a 4.30 m frontage 0.83 m from the corner. **Time:** about 30 minutes to a
  14-page PDF of a failing design. The agent could not write its `report.md`; condensed here.
- **What held up:** a 500 m deck edge: "Edge 1 runs past the end of the parking segment", Apply disabled; a 50 m wide
  parklet: "⚠ Parklet: requested 50.00 m, set to 2.65 m (remaining roadway 2.65 m)"; a lane dragged to 6.8 m: "set to
  4.80 m (EDM Table 8-10 note 8 exception cap 4.8 m)"; "Find corners" found Richards St and C03 failed "0.83 m < 6 m";
  removing a travel lane recalculated the street. The PDF of a failing design builds.
- **Broke**
  - **"99999" in C03 and C07 committed as "9"; "-10" in C03 left "−" and the result "✗ NaN m < 6 m minimum. Fails."**
    while the row's badge still said "Not entered". The 9 and the "−" are **the keystroke loss** (Parent run 2: the
    row moves on the first character); **the "NaN m" in a compliance message and the badge disagreeing with it are
    real** on their own (a lone "-" is evaluated).
  - **Check values typed for one site stay when the design moves to another:** pole and signal-box distances typed on the
    blank street still counted as passes at Dunsmuir & Richards, three kilometres away and never surveyed.
  - **"Add segment" does nothing when clicked:** the Section's "Add segment – drag into the section or click to
    append": Bike Lane twice, Planting once, and a drag: nothing added. **Reproduced** (Commercial & 1st): clicking Bike
    Lane and Planting leaves the segments unchanged and says nothing (the roadway there is fully allocated, 0.001 m
    remaining; whether appending needs free width is not said anywhere). README step 5 names this action.
  - A negative deck edge ("-5") is shown in the field and silently ignored.
  - `[checkLandmarkConsistency] … disagree` after editing lanes (four lane / parking positions) and once for the
    vegetation count; `GEN is not defined`.
- **Confused:** after a Check edit moved a row to another group the page jumped to the top of the list (the same
  regrouping); the slope field is a slider and a number box, and a click beside it selected the whole page's text; the
  imported separated bike lane folds into the far side's "2.40 m" in the Section rather than its own segment; "Start a
  blank street" asks a confirmation the README does not mention (it is the disclaimer the brief asked for).
- **README / landing wrong:** step 5's "edit the street in the Section (Add segment)": click to append did nothing.
- Evidence: `<scratchpad>\b23\full\p4-run2\` (screenshots, the PDF).

### Run: Persona 5 (accessibility, keyboard only, 150 %), run 2, Sonnet

- **Site:** a real address found by keyboard (1000 Davie St), then the blank street. **Time:** about 35 minutes to the
  survey sheet PDF; the sample report's PDF after.
- **New since run 1**
  - **The search results are reachable after all**, one Tab further than expected (Tab from the box lands on "Search",
    the next Tab on the first result; arrows do nothing). Run 1's "cannot pick a result" is softened; **the street and
    side pick still has no keyboard way** ("Use this location" stays disabled, the map is never a tab stop): confirmed
    again.
  - **"Place" cannot be finished by keyboard:** the card's tooltip says "Places this piece on the deck; click in the
    Plan to set where." So a keyboard user can never put seating on the deck, and C16 stays "Nothing placed yet". This
    is also why "Place did nothing" for Parent run 1, persona 3 run 1 and persona 7 run 1: Place arms a placement that
    waits for a click on the Plan, and only the tooltip says so.
  - No keyboard way to select a placed piece (Help lists arrows for "the selected piece" but nothing selects one).
  - Escape on the map dialog sends focus to the document start, not back to "Locate on map".
  - The expanded Furniture library puts its 50 cards (one or two tab stops each) in the page's tab order with no skip.
  - The Check groups are one tab stop each and open with Enter, but expose no expanded / collapsed state to a screen
    reader (the `<summary>` is read as a plain button in the snapshot).
  - Tooltips of the hidden app toolbar show over the sample report page when tabbing.
  - "Accessible seat" (a bench end, or a table with knee clearance) is not a term the library's search or categories
    know ("accessible" finds nothing; "wheelchair" finds the entourage figure).
  - The console `GEN is not defined at ACC.planSVG` read as "the route drawing is broken": the route is drawn once the
    layout model exists (verified in VERIFY); the warning is from the first renders. Still one issue to fix.
- **README / landing wrong:** step 3 is mouse-only and does not say so; the PDF's "(C16 reserved)".
- Evidence: `<scratchpad>\b23\full\p5-run2\` (001–138.png, two PDFs).

### Run: Persona 3 (landscape designer), run 2, Sonnet

- **Site:** Fraser St at E 22nd Av, west side (host 3755 Fraser St, a café). **Time:** about 10 minutes of steps, over
  60 minutes on the clock (freezes of 20 s to 4 min after ordinary clicks).
- **New since run 1**
  - **A nicer edge breaks the route:** switching the traffic-side enclosure to Planter wall took the usable width from
    2.65 m to 1.85 m, and a bench and a round planter then failed C16 ("no 1.10 m route to an accessible seat … beside
    the deck edge or the enclosure"). The Edge panel had said so in "The buffer stops at 0.44 m: wider, no layout keeps
    a 1.5 m entry space and a 1.10 m accessible route in the usable width": correct, but hard to read.
  - The Edge panel's option tiles share their words with the tab subtitles ("Planter wall"), so a click by text landed on
    the "Start end" tab (harness-adjacent; a person clicks the tile); the ends default to Planter wall and the traffic
    side to Steel picket, which the README does not say.
  - **Furniture survived a reload** here (the agent had switched tabs before reloading: consistent with persona 6's
    finding that placing alone does not save).
  - Visualize's "Technical" appearance button is greyed out with no reason given (not checked why).
  - A quick drag of a card placed nothing; a slower one did (may be the harness's mouse drag).
  - The reload itself hung for minutes ("Loading …?noauth") and then restored the design; `[report] layout check:
    outside: Array(1)` once (one text outside a sheet, not identified).
- **README / landing wrong:** none.
- Evidence: `<scratchpad>\b23\full\p3-run2\` (screenshots, the PDF).

### Run: Persona 8 (City staff reviewer, the PDF only), run 2, Opus

- **Input:** two sets made by this pass's runs: persona 2 run 2's technical set (W 10th Av at Tolmie St) and persona 3
  run 2's schematic set (Fraser St at E 22nd Av, a planter-wall edge and a shaped deck), and the Manual. Three
  dimensions chosen per set, none of run 1's. **Time:** about 16 minutes. Both scale bars true (1:250, 1:100).
- **The dimensions**
  - **Set 1 (technical)**
    - C13 parking setback: "1.50 (≥1.50 C13)" on A-102: **cannot tell.** It is the rule zone, not a measurement; C-001
      says C13 "not entered", and the near side has no parking at all (a bus zone).
    - Deck width 2.65 m against p. 20's 2.3–2.5 m: **disagree** (as run 1).
    - C18 openings: clear runs 11.88 and 5.07 m scaled, against C-001's 11.90 / 5.10: **agree** ("8 openings" is the
      tool's own count, run length ÷ 1.8).
  - **Set 2 (schematic)**
    - C03 intersection setback: "6.00 (≥6.00 C03)", the rule zone again, cut by the frame at about 5.2 m drawn: **cannot
      tell.** A-101 draws no cross street within its 78.5 m, while the locator shows one about 18 m before the deck.
    - C16 route: fails on the sheets, **agree in substance, wrong basis.** It tests 1.1 m against the Manual's 1.5 m (G19,
      p. 60, as before). The text's "entry 1 (z 3.30)" does not match the entry drawn at z 4.65–6.15. A third entry
      drawn near z 16.5 is not mentioned, and the "0.30 m" pinch could not be found on the drawing.
    - Deck width 2.65 m: **disagree.** By the set's own street (15.20 m curb to curb, four 3.2 m lanes) it can be at most
      2.40 m.
- **New since run 1**
  - **Rule zones read as measurements:** "1.50 (≥1.50 C13)" and "6.00 (≥6.00 C03)" share the format of a real value
    ("40.27 (≥5.00 C05)"), so a reviewer reads them as met when both checks are not entered.
  - **Red zones contradict the legend:** the legend says "Clearance zone (red: the check fails)", but in the schematic set
    passing C05 ("32.22") is red. **Confirmed in code:** the schematic style draws passes in zone red at 60 %.
  - **A notched deck under a straight enclosure (set 2):** the shaped deck is cut back about 1.8 m on the traffic side at
    the far end. The planter wall runs straight on over the missing deck, leaving a 1.36 × 0.32 m void inside the
    enclosure. The "2.65" still spans the full width, and X-001's 50.17 m² is less than 19.80 × 2.65. Not reproduced by
    me; it fits persona 3 run 2's use of the shape editor.
  - **Three curb-to-curb widths in set 1:** 17.60 (X-001, imported), 18.15 (A-201's segments) and 19.00 (A-101 and S-002,
    "user"). C02's pass rests on a "proposed" street with wider lanes (3.50 / 3.20 …) and a 2.00 m sidewalk, not the
    imported 17.60.
  - **The C03 and C05 strings run off A-102's frame** in both sets (as run 1).
  - C16's text reads "beside the the deck edge". **Confirmed in code:** `ENC.near` already returns "the …".
  - "3 routes 1.72 m clear or more" on C-001 (set 1) against "1.10 clear" on A-103; no 1.72 m anywhere on the drawing.
  - A-101's legend lists a bus-stop symbol, but the stop 8.7 m past the deck (S-002) is not drawn on the plan.
  - C02 again "AWAITING MEASUREMENT" in the table and "3.20 FAIL" four times in the lane panel (as run 1).
- **Verdict as a reviewer:**
  - Trusts the technical set's linework and its C16 / C18 geometry; distrusts its street numbers.
  - The schematic set is more honest about estimates, but its red zones and the notched deck would make the reviewer
    send it back sooner.
  - Trusts neither for C03 or C13 until site values are entered.
- Evidence: the agent's report (this block); the input PDFs in `<scratchpad>\b23\full\p2-run2\` and `p3-run2\`.
