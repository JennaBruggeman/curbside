# Curbside: handoff, session 8 (Brief 30, the Friday round, 2026-10-03 .. 10-04)

Read this first in the next session. Previous notes: `HANDOFF_SESSION_7.md`, `HANDOFF_SESSION_7b.md`. Brief:
`briefs/30-friday-round.md`. The working log the numbers come from was kept in the session's scratchpad.

## Where things stand

- **Branch `friday-round`** from master `cfd4b63` (v0.17.2), 56 commits (52 for the brief, 4 follow-ups), one per change. **Not merged, not pushed.**
  Master, the live site, GitHub Pages and Supabase are untouched (code freeze until after 9 October).
- **curbside-data:** branch `friday-round` (b93e85e blockfaces build, 62b8e56 points beside every face). Not pushed;
  the published cells are unchanged. The app's band reads the blockfaces layer, so **the band shows nothing on the
  live cells until that branch is published** (the test fixtures in 1357a77 carry it for the three test sites).
- `parklet-checker.html`: 2,475,673 bytes at start, **2,633,310** at the report, **2,640,907** after the follow-ups (+165,234; §10 removed 42,407).
- Test browser: the installed Edge through Playwright (`channel: 'msedge'`). The ms-playwright Chromium was gone
  after the reinstall and was not downloaded again. Tests serve the repo from disk through Playwright routes (the two
  background servers on 8766 / 8767 stopped at their 2-hour limit).
- The assistant was tested only against a mocked endpoint with a fake key; Jenna's key was never used. Nobody
  signed in on the live site.
- Impeccable 4.5.0 (user scope) was used for §12: `docs/PRODUCT.md`, `docs/DESIGN.md`, `.impeccable/design.json`,
  `.impeccable/config.json`; the detector is a pre-push step.

## What each section did (commit, VERIFY in numbers)

### §1 Picker basemap and markers (0709200, e96a2af, 59ab1fb)
- Monochrome vector basemap (OpenFreeMap positron, `CONFIG.MAP_STYLE`), raster OSM fallback.
- Markers at Layers defaults (Robson): before z15/16/17 = 3173 / 685 / 141; after z14 = 0 (with a note), z15/16/17 =
  3192 / 702 / 142 (same features, +19 from a cell refresh), radius 4 / 6 / 8 px. Same at DPR 1 and 2. Tile errors 0.
- Hover lights the street at 5 sites (Robson, Commercial, W 41st, W 4th, Main); a tree 7.0 / 9.2 / 8.4 m from the street
  picks the street while picking (no popup). A master-saved design opens at the same point, bearing and side.
- **Step 0:** the City catalogue was searched for parklet, patio, street use, street-use, sidewalk cafe, patio permit,
  permit, outdoor, seating, plaza and temporary. **No parklet, patio or street-use permit dataset**, so no
  existing-parklets layer.

### §2 Where a parklet could go (curbside-data b93e85e, 62b8e56; app 8e76cb0, f50bbde, 1357a77)
- Build: 41,040 faces split into 119,436 pieces (eligible-estimate 25,189, excluded 84,963, needs-measurement 9,284).
  235 cells, 3.3 MB gz, largest file 40 kB gz. `--only=derived` 15 s; full build 58.4 s; deterministic.
- Band against Check at 7 sites: **0 contradictions** (before the import fix, Robson SW had 2: a Burrard stop counted as
  a bus zone, and a hydrant 40 m down Burrard failed C05 at 2.61).
- The import keeps objects within 12 m of the curb and between the corners; C03 reads the corners from the cells.

### §3 Shape editor: a rectangle and 45° cuts (819575e)
- 12 × 2.4 with the traffic corners cut 0.6: area 28.44 in the editor, the model, the Plan clip, the 3D, Rhino and the
  schedule; consistency 0.
- **Brief error, not a code issue:** the brief's expected area of 27.99 m² is wrong. 12 × 2.4 = 28.8, less two 0.6 m
  corner triangles of 0.18 m² each = 28.44 m², which every view gives. (27.99 would need 0.9 m cuts.)
- A handle drag gives a 0.75 cut on the 0.25 grid; Ctrl+Z returns to 0. An older notched design loads at 49.052 m²
  unchanged; Convert gives 19.8 × 2.5 = 49.5. Polygon, notch and vertex: 0 matches in the UI.

### §4 Furniture placement, one path (b712663)
- A Bench dropped on the 3D deck: 1 added at (1.25, 8.00) at all 5 sites; 3D = model = Plan; it is still there after a
  reload. Master: 0 added. A drop 1.5 m off the deck lands on the deck edge (x 1.885). A 3D drag of 2 m moves it
  2.000 m. A touch tap places one.

### §5 The parklet's materials, one store (ff2e3a6)
- Robson, Recycled plastic grey: 3D deck #d6ae74 → #7e8083; Plan tint #C8A97A → #A2A3A3; Rhino (200,169,122) →
  (162,163,163); S-001 row; the prompt says "recycled plastic grey decking"; consistency 0.
- A master-saved design keeps today's look. Thermowood + anthracite at 5 sites: consistency 0.

### §6 Parklets 101: build, quantities, cost (bc428d4)
- Robson 7-piece design: deck 49.5 = model; railing 19.8 = runs; 20 posts = 3D. Furniture shows "—" until a quote
  is typed. A bench quote of 1,200 prices its row; adding an identical bench doubles it.
- Placeholder rates: the hand sum and the app agree at CAD 989.08–990.51. Fees at Robson: 41,404–61,404 CAD (Manual
  p. 18 and p. 40).

### §7 The assistant in Generate (29bc7c4), mocked only
- At 5 sites, "Lay out seating for 6 and a planter on the traffic side" ran the generator: Robson 16.36 × 2.40, 4
  benches + 3 planters, C03 fail → pass. Undo restores the design exactly (3 of 3). Commercial and Denman: the
  generator refuses (bus zone) and says so in the chat.
- "Why does C02 fail?" answers from the check. An unknown tool is refused. A 401 gives one plain message.
- The export has no key and no chat text; the system prompt is 11.1 kB.
- `GEN.writeRationales` made 6 Anthropic calls after every generator run when a key existed. Since 29b2397 it is a
  choice in the assistant block, off by default (see the follow-ups below).

### §8A Peer-review issues
- `gh issue list --state all` on JennaBruggeman/curbside: **0 issues**.

### §8B Access, carry-overs, the sample (4ef0e34, a7dbc82, 1aa6639, d22c606, 888e8c0, 2ee27f8, fd3c843)
- **Keyboard site pick:** works at 5 sites (4/2/2/4/2 street-side buttons). Enter enables Use and moves focus to it.
- **200 % zoom (800 × 450):** the last control in the Selection panel was at 950 px of 450; now 285 px (the panel scrolls).
- **Forced colours:** the active tab and pressed toggles were identical to the others; now they have a 2 px outline.
- **Touch:** a one-finger Plan drag moved the bench 1.98 m with no page scroll; a shape-editor corner drag cut 0.75.
- **Persona 7, scripted on touch at W 4th:** tap place 1; orbit 37.4; drag 1.11 m (the same as a mouse); the panel
  scrolls 506/506; the PDF arrives in 1.0 s; errors 0.
- **Two tabs:** the later writer asks before it overwrites, signed out and signed in.
- **Sample:** the umbrella is 2.60 m high; the rebuilt reports pass 19 of 19.
- **Try without an account:** the link on the index opens the tool signed out.

### §8C Triage rows (5ba89a9 .. e23af12)
- **Export freeze:** schematic 0.96 s, longest stall 430 ms (master 426); + New stalls 331 ms (master 327). PASS
  (≤ 1 s).
- **Regroup:** the saved row stays at 515 → 515 px (master jumped 183 px).
- **Over by 2 mm:** now valid, Remaining 0.000.
- **Decimal comma:** "2,5" gives 2.5 (master 25); "250 cm" gives 2.5; "12 ft" and "abc" are refused with a reason.
- **Duplicate:** the copy keeps 135° (master 0°); the Along field follows a drag (7.436).
- **Blank street onto Robson:** named "Untitled parklet", file curbside-1000-robson-st-schematic.pdf.
- **Sidewalk:** goes from 3 to 4.00 with the roadway full.
- **S18:** 6 schemes survive a reload.
- **S16:** a held lookup ends at 15.0 s with a message.
- **S19:** first and second click 162–2006 ms / 3–6 ms.
- **Not reproduced:** S5 (400 Tabs) and T15.
- The full table of closed rows is in `23-triage.md`, "Closed in Brief 30".

### §9 Site facts (99ed523, 9c478fd, a236a92, 9803b79)
- **Cards per site:** Robson 16, Commercial 17, Denman 17, W 4th 17, Main 18, blank street 15.
- **The gate:** every tab past Site facts is locked until every card is answered, with a tip naming the next card.
- **C05 through all three answers:** measured 7.0 gives Pass; an estimate gives "Pass [estimate]"; not known gives
  Awaiting measurement. The report and the cover follow ("1 of 15 measured on site" → 2 of 15).
- **Typing in a card:** 17 gives 17.
- **Confirm all:** Robson trees 14 → 14 in one click. The other sites: Commercial 1 stop and 4 trees; Denman 1 stop and
  7 trees; W 4th 1 hydrant and 11 trees; Main 1 hydrant, 1 stop and 4 trees.
- **Reload:** returns to card index 3, still locked.
- **A master design:** loads unlocked, with one notice; its typed values count as estimates.
- **Header:** Parklets 101 had been cut off at 1280; all nine tabs fit now. Errors 0.

### §10 Survey import removed (174346c, c51a6fd)
- −42,407 bytes. 0 matches for "SURV" in the file and in the DOM at 5 sites.
- S-002 is 1 page with 15 rows at 5 sites. "I've measured on site" opens with Measured chosen, and C05 7.0 gives
  Pass. Old survey provenance still loads as measured.

### §11 Enclosure from the outline (f8b4fbd)
- **Rectangles unchanged:** every part's signature (to 0.1 mm) is identical for 4 archetype mixes (204 / 87 / … parts).
- **12 × 2.4 with 0.6 cuts, buffer 0.3:** runs 10.551 + 2 × 1.024 + 2 × 1.376 = 15.35 = the schedule.
- **Buffer 0:** the runs total 16.097 = the enclosed deck edges, with 4 vertices of 1 post each. Rhino has 14 posts,
  the same as Parklets 101.
- The 3D extent equals the model's; consistency 0. A notched outline is now wrapped (triage row 21).

### §12 Interface pass with Impeccable (b47fb2e .. 2fc5d55, commits 19–27)
- Audit before: 12/20; critique 25/40 (`briefs/30-ui-audit.md`).
- **Every tab at 1280, 1440 and 1024 touch, 33 views:**
  - Text under 12 px: 1,335 → **0**.
  - Letter-spaced capitals: 54 → **0**.
  - Controls under 24 px: 1,196 → **13**. These are Settings' inline text links (4/5/4), left as text links.
  - Contrast under AA: 0, apart from 1 measuring artifact per size on Export (a hidden swatch).
- **Design detector:** exit 0, and it runs on pre-push. `.impeccable/config.json` has 3 reasoned exceptions.
- **Drawings untouched:** Section and 3D pixel-identical at 6 sites. The Plan is pixel-identical; its markup differs
  only in timestamped `data-seg` IDs.
- **Header at 1280:** 16 controls, the rightmost at 1217 px, none off-screen.
- **Sign-in dialog:** Tab stays inside 15/15; Escape closes it and focus returns to + New. Errors 0.

## Decisions I made (the plainer choice where the brief left it open)
- §1:
  - OpenFreeMap positron, because CARTO's hosted tiles are enterprise / grant only.
  - The streets layer is thin, dashed grey.
  - The dots stay inert until a street and a side are picked.
- §2:
  - Faces on primary to residential, unclassified and living_street only.
  - Corner = crossing half-width + 6 m; bus zone ±15 m; hydrant ±5 m.
  - Lane width counts as needs-measurement within 0.1 m of C02's minimum.
  - The import keeps objects within 12 m of the curb, between the corners.
- §3: Ctrl+Z inside a cut field is the field's own undo. The generator's notched footprints are left as they are.
- §4: a drop more than 3 m from the deck is refused; a nearer one lands on the nearest deck point.
- §5:
  - "Composite grey" = Recycled plastic grey; the fourth preset is Thermowood + anthracite.
  - An archetype keeps its own material where it is not made in the chosen one.
  - Technical drawings stay ink on white.
- §6:
  - Fees are cited from p. 40 (the brief said 41); a parking space is 6.0 m.
  - Quotes are stored per design, per identical group.
  - Manufacturer links go to the brand's site.
  - Cincinnati and Toronto are listed as consulted, with no figure taken.
- §7: the model string stays claude-sonnet-4-5.
- §8B:
  - Persona 7 was re-run as a script of the run-3 list, not a 50-minute agent run.
  - The A-A cut handle still takes a drag that starts on a piece under it (noted).
- §8C:
  - A held row moves when Check is left.
  - Units accepted are m, cm and mm; feet are refused, not converted.
  - Schemes are kept in the tab's session storage, not in the design.
- §9:
  - Site facts is a step with the Site tab lit, not a tenth tab (no room at 1280). Furniture is gated too.
  - C02 has three cards. C12 is a card. C15 stays a design input.
  - Object groups are "Checked on site" / "Not checked yet" cards.
  - An estimate gives a provisional result marked "estimate". Values typed in the Site panel or the Section count as
    estimates. A check left open only by "Don't know yet" does not reject generated layouts.
  - Older confirmations load as estimates.
- §10: old survey records are still read (they load as measured) but never written. X-001 says "Measured on site by
  the applicant, <date>".
- §11:
  - A square corner keeps its butt joint, so rectangles are unchanged.
  - Mitres and vertex posts at oblique corners; the vertex post belongs to the run on posts.
  - The curb side stays open; the wheel stops follow the outline's ends.
- §12:
  - PRODUCT.md is from the brief's pre-decided answers.
  - Barlow Condensed is kept, because the Plan's labels use it (a detector exception).
  - Settings' inline links stay text links.
  - The accent ink #1F6FA3 is for blue text on paper.
  - "Awaiting" is in the Wait colour, not the accent.

## Follow-ups after the report (2026-10-04, three commits)
1. **80c0b12, no bare Pass on an estimate.** A result that rests on an estimate reads "Provisional pass (estimate)" /
   "Provisional fail (estimate)"; on imported data not yet checked, "(imported)". This covers the Check badge (all four
   painters), the row's result text ("Passes." → "Provisional pass (estimate)."), the counts line, the compact verdict,
   the verdict, the summary, C-001's Result column and count, and the counts on A-000 and the cover.
   - **Before**, at W 4th with C05 as an estimate, 3 provisional checks were shown bare in 9 places: badges "Pass" /
     "Fail" (C02, C03, C05); row text "Passes." (C03, C05); counts "6 passing · 3 provisional"; cover "6 pass, 1 fail";
     A-000 "6 pass"; C-001 "PASS (estimate)" and "6 pass"; the summary's Passing column.
   - **After**, at W 4th and Robson (C05 measured, estimate, not known yet): 0 bare. X-001 never printed a result
     (0 matches); it states how each fact is known.
2. **e47c2a4, G-002.** The City's fees are cost lines in every rate set (the Manual's when a set has none). The
   Manual's $10,000–15,000 a space is a separate line, not in the total, used only for the banner (below / within /
   above). The sheet adds Build and City fees subtotals.
3. **29b2397, rationales.** "Write a rationale for each scheme (uses your key, about 6 calls)" is a box in the
   assistant block, off by default and kept in this browser. Generate with a key: 6 calls before; 0 with the box off,
   0 after a reload; 6 when on.
- The scratch worktrees `master-wt` and `pre12-wt` were removed; `git worktree list` shows only the main checkout.

## Jenna's decisions (2026-10-04)
- No tabs and no step strip merged; the interface stays as it is until Jenna has walked through it.
- Wait for **Brief 31**, after the merge on 10 October: PRODUCT.md, the sample re-render, the assistant test with
  Jenna's key, the hosted relay and render-to-account tests, the landing page screenshots, and the open triage rows.

## Needs Jenna
1. **The assistant with a real key** (Brief 31). It is mocked only; open is a real model's refusal sentence for
   provenance.
2. **Photoreal sample renders.** `demo/render-*.jpg` still show the 2.4 m umbrella. Re-rendering needs the hosted
   render.
3. **The hosted photoreal relay, and the render-to-account test** (the Supabase `design-renders` bucket is untested).
4. **Publish the curbside-data `friday-round` branch** after 9 Oct, so the band works on the live cells.
5. **PRODUCT.md:** confirm the answers (written from the brief, no interview).
6. **The landing page:** new screenshots, and a Site facts step in its walkthrough.
7. ~~Audit P1, merging tabs and steps~~: decided 2026-10-04, no merge; the interface stays until Jenna's walk-through.
8. **Triage rows still open:** 5, 7, 11, 15, 18, 19, 27, 28, 31, 36, 37, 38, 41, S17 (`23-triage.md`).
9. **The merge:** review the branch, then merge, tag and push after 9 Oct. Then set `invite_only` back to true.
10. Carried over: the numbers in HANDOFF's "Numbers waiting on Jenna" (route width 0.92 m, tree clearance, …).

## Tools left behind
- `tools/hooks/pre-push` runs the Impeccable detector on `parklet-checker.html` when the launcher is installed. It is
  skipped with a note when the launcher is not installed.
- The scratch worktrees (`master-wt`, `pre12-wt`) were removed on 2026-10-04.
