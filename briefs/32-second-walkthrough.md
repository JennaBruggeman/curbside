# Brief 32 — Second walkthrough: picker answers first, rectangular generator, designed entries, a cost estimate that lands, cover and A-102
(branch `second-walkthrough` from `walkthrough-round`; nothing has been merged or pushed,
master is still v0.17.2 and stays so until Jenna says otherwise)

Run to completion without pausing. Where a decision is not made below, make the plainer
choice, log it under "Decisions I made" in the report, and continue. One commit per
distinct change. Do not merge. Sections are ordered by what users meet first; the
structural sections (§4 onward) come last so the rest can merge if they overrun.

Read first: `docs/process/HANDOFF.md`, `docs/process/HANDOFF_SESSION_9.md`,
`briefs/31-walkthrough-round.md`, and the peer-review issues on the repo ("Review: <name>").

Conventions that still govern: one fact one store (`DESIGN_MODEL`); one mapping per view;
checks are the only compliance logic; the LLM never writes geometry; nothing measures
through a hidden panel; verify with numbers; `checkLandmarkConsistency()` silent after
every sync; every result word comes from `CHK.label` / `CHK.msgFor` / `CHK.tally`;
headless runs use Playwright's own timeouts and close the browser in a `finally`; any
VERIFY that depends on published data says whether it ran on `published` or `local`.

Pre-decided:
- The picker's base state is the eligibility band; no other layer is on by default.
- Every generated deck is a rectangle with optional 45° chamfers; no other outline.
- Entries are objects in the model, seeded at the deck ends, edited by the user.
- Every build line in the cost estimate is priced; the tag says how well (`sourced`,
  `indicative`, `proxy`, `user`). "Not priced" exists only for furniture awaiting a quote.
- Cover camera: never the full-context axon; the Street or Corner preset framing the deck.
- Sheet scales include dimension strings and labels in the fit test (≥ 2.0 mm text on
  paper).
- Anything else ambiguous: plainer choice, log it, continue.

---

## 1. The picker opens on the answer (commits 1–2)
Root cause: the eligibility band is a layer the user opts into, drawn above zoom 15, with a
legend paragraph in a side panel, on a map that opens at whole-downtown zoom with the
bikeways layer on. The question is "where can I put this?" and the map doesn't answer it
until the user finds the panel. (The band is also absent on the live build because the
`blockfaces` layer is on curbside-data's unpublished branch; that resolves with the merge
and is not part of this section.)
- On open: Vancouver at a zoom where the bands read (about 14); the only overlay drawn is
  the three band tones along every block face with a parking lane (green could-go-here,
  grey excluded, hatched measure-first). No dots, no bikeways, no other layer on. The
  Layers panel still exists and opens closed.
- Legend: three words under the search box, not a paragraph in the panel.
- Hover a band → one-line reason. Click a green or hatched band → that face and its side
  are picked in one click (the band knows its side); the street-then-side sequence
  remains only for grey faces and streets with no band.
- Below zoom 14 the bands thin to one tone per block; above 16 the dots appear as now.
- When the data is absent, the footer says so once in plain words; no legend for a layer
  with 0 pieces.
VERIFY (state `published` or `local`): open at Robson & Burrard → bands visible with no
interaction, Layers closed, zero dots; hover a grey face → reason shown; click a green
face → pin, side and footer set in one click; a grey face picks with its reason on the
pick card; `?gis=published` shows the footer sentence and no legend; counts of green /
grey / hatched faces in view logged at zoom 14 and 15; before/after screenshots.

## 2. Generator: rectangles only, and say what didn't pass (commits 3–4)
Root cause: `GEN.PATTERNS` still contains "Split (linked pair)" and any other pattern that
produces a non-rectangular outline, which the Brief 31 §3 editor cannot draw and the
enclosure cannot wrap. And when fewer schemes pass than were asked for, the header shows
"120 sampled · 1 built · 1 passed" and the user gets one card with no explanation.
A. Remove every pattern that produces a non-rectangular deck; every generated deck is a
   rectangle with optional 45° chamfers. The pattern card and its text go.
B. When fewer than the requested number pass, the header is a sentence: "6 asked · 1
   passed every check · 5 failed: 3 on C16 route width, 2 on C02 lane width". A "Show
   schemes that didn't pass" toggle lists the failures drawn with their failing checks
   named. If none pass: "none passed" and the nearest misses shown. The current header
   string (seed, sampled, built, ms, scoring) moves to a tooltip.
VERIFY: 50 generated schemes at the five sites → every deck polygon has 4–8 vertices and
only 90°/45° angles (log the check); "Split" absent from the UI and `GEN.PATTERNS`; a
saved split-deck design loads with the §3 "older tool" notice; Robson, Bus/truck → the
sentence names the count and the failing checks; the toggle shows failures with reasons;
a site where all six pass shows six and no toggle.

## 3. Cover camera and A-102 scale (commits 5–6)
Root cause: the cover axon is drawn from so far up that the parklet is a sliver across a
grey road with half the sheet blank; A-102 at 1:250 puts an 80 mm deck on a sheet a third
empty, with dimension text smaller than the sheet number.
- Cover: when no render is ticked, the fallback camera is the Street or Corner preset
  framing the deck across the middle 60 % of the sheet with the host building behind it,
  sky or road under the title panel; never the full-context axon. The drawing fills the
  sheet to its edges.
- A-102: the scale ladder's fit test includes the dimension strings and labels (≥ 2.0 mm
  text on paper), so it lands at 1:150 or 1:200 here; the far-side road is cropped to one
  lane past the centreline unless a clearance dimension reaches further. The same fit
  rule applies to every sheet in the ladder.
VERIFY: Granville and Robson covers before/after, the deck occupies ≥ 50 % of the sheet
width; A-102's chosen scale and smallest text height logged at the five sites; layout
check 0 overlaps, 0 outside.

---

## 4. Entries are designed, not inferred (commits 7–9) — structural
Root cause: the tool invents entries (C18 openings at fixed spots), then C16 draws a 1.5 m
route from each invented entry to a seat and reports furniture "blocking" a route to a
door the user never placed; turning circles are drawn at every candidate, so they
overlap. The §8 dotted fill and dashed-blue rectangle also survived.
- `DESIGN_MODEL.parklet.entries`: each with position along the curb edge and width
  (default 1.8 m). The sidewalk-side enclosure has gaps at the entries and nowhere else;
  end planters and screens close around them. A new design seeds two entries at the deck
  ends. The user drags an entry along the curb edge in the Plan, adds or removes one
  (minimum one), or sets positions in the Design panel's enclosure section.
- C18 checks the entries that exist (count ≥ 2, width ≥ 1.8 m, as the Manual states).
  C16 draws one route from each real entry to the nearest accessible seat and one
  turning circle at the seat end, only where the route turns or ends, never at the entry.
  Route = the §8 dashed outline with the pinch dimension; delete the dotted fill and the
  blue rectangle. Entry labels sit outside the deck on the sidewalk side and never
  overlap another label.
- The generator places entries as part of a scheme and never puts a seat in front of one.
- Old designs: inferred entries become real ones at the same positions, logged once.
VERIFY: Robson → a fresh design has two entries at the deck ends, enclosure open only
there, C18 passes; drag one to mid-deck → the gap moves, the route redraws, C18 passes;
delete one → C18 fails "one entry, needs two"; armchair in a route → one pinch dimension,
one circle at the seat, no fill, no blue rectangle, no label overlap; 20 generated
schemes have their entries clear; an old design loads with converted entries.

## 5. Cost estimate that lands (commits 10–12)
Root cause: the structure from Brief 31 §9 is right and honest, but the rate set has no
row for materials the panel offers (terrazzo decking, Corten planter wall), and labour,
joists, pedestals and drawings came back "no public listing that could be checked", so a
19.8 m parklet totals $1,619 with a note that the real total is higher.
- Every material in `FL_MATERIALS` choosable for a priced role has a rate row. Where a
  family has no public figure, the row carries the nearest priced family's rate tagged
  `proxy` with a note ("priced as hardwood decking; terrazzo has no public rate"), never
  a blank.
- Labour: a rate per m² of deck and per m of edge, split out of the published Canadian
  installed ranges already cited (their own stated material/labour proportions), tagged
  `indicative`.
- Joists and pedestals: priced from the lumber yards already cited (treated 2×6 at the
  Canadian big-box sites; adjustable pedestals at Bison's Canadian distributors); a line
  still unsourced after a second attempt gets a `proxy` from the nearest line.
- Design and permit drawings: an allowance of 8–12 % of build, tagged `indicative`.
- Tags: `sourced`, `indicative`, `proxy`, `user`. The summary tile counts by tag ("4
  sourced · 3 indicative · 2 proxy"), not by blanks. "Not priced" only for furniture
  awaiting a quote. The sentence under the title drops "the real build is higher".
- Quantities: omit rows whose quantity is zero because the type isn't used (no "Enclosure
  posts 0" on a planter-wall design).
VERIFY: the Granville design → every build line priced, tags counted in the tile, total
in the tens of thousands with its position against $40,000–60,000 stated; deck to cedar
→ the decking row becomes `sourced`; a steel-picket + softwood design has no `proxy`
rows; zero-quantity rows absent; Excel balances; the rate-sources table in the report
lists every new row with its basis.

---

## VERIFY sites (every section)
Robson & Burrard · Commercial & 1st · W 41st & Dunbar · W 4th at Yew · Main 2000/2500
block · Granville at Robson · blank street.

## Report
Per section: VERIFY results as numbers; "Decisions I made"; before/after screenshots
named by section; `published` or `local` stated for §1; the §5 rate-sources table; file
size of `parklet-checker.html` at start and end; peer-review issues with outcomes; "Needs
Jenna". Update `docs/process/HANDOFF.md`; write `docs/process/HANDOFF_SESSION_10.md`.
Do not merge.
