# Brief 26 — Demo walkthrough and video prep (runs after Brief 25)

Moved here from Brief 22 item 11 (2026-10-01, Jenna). Root cause → change → VERIFY → commit;
log decisions; the three sites where a check needs a site.

## 1. Demo walkthrough script (was Brief 22 item 11)
`tools/demo/walkthrough.js` drives the hosted tool through the whole journey at human pace
(a PACE constant, the mouse moved along paths, pauses at each stage) and prints a timestamped
step log. Playwright's recordVideo on; a real screen recorder can run over it.
VERIFY: one run produces a video and a log; the log's stage times are within 10 % of the PACE
targets.

## 2. Video prep
The run Jenna records her voice-over against: the stage order and timings she needs, a
headed run for the screen recorder, the output files named for the edit.

## Where it stands
- A draft is committed on the local branch `demo-draft` (b77441b), not pushed. It was not run
  to completion: the first run was stopped during the site import.
- What the draft does: opens `parklet-checker.html?noauth` at stage 0; Locate on map, clicks the
  street and the side at Commercial & 1st, Use this location, Import street context (Retry on
  a server that does not answer); the seeded parklet in All views; Generate, hover two schemes,
  Open in Design; the Check tab, scrolled; Export, Download report (PDF). Each stage is padded
  to its PACE target (open 8, site 70, seed 16, design 45, check 18, report 40 s;
  PACE_SPEED scales them). A cursor is drawn in the page (a headless video shows none);
  `--headed` runs in a window. Writes tools/demo/out/ (to be git-ignored): walkthrough.webm,
  walkthrough.log, the PDF.
- Open points for this brief:
  - Site data is live, so a slow Overpass answer makes the site stage run over its target.
    After Brief 24 the import reads the curbside-data cells and this goes away; the stage
    targets should be re-timed then.
  - The draft skips sign-in with `?noauth`. For the video, decide: a signed-in demo account,
    or the signed-out mode (see the README's answer on reviewers and invite codes).
  - Item 10's fixtures (tools/fixtures/commercial) cannot be reused as they stand: the map
    click's coordinates key the Overpass query, so a human-paced click misses them.
