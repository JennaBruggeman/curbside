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
