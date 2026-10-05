# Curbside — chat handoff, session 7 (2026-09-30 → 2026-10-02)

Read this first in the next chat. Previous handoff: docs/process/HANDOFF_SESSION_6.md.
Claude Code keeps its own HANDOFF.md in the repo (now docs/process/); this is the
chat side. Session 7 ran from Wednesday afternoon to Thursday night and closed
with the code freeze for the ARCH 540 Assignment 1 demo on Friday 2 Oct.

## Where things stand

- **Live:** v0.17.2 on master, tagged, pushed, GitHub Pages serving it at
  https://jennabruggeman.github.io/curbside/. Repo public at
  https://github.com/JennaBruggeman/curbside (MIT). Data repo
  https://github.com/JennaBruggeman/curbside-data (ODbL / CoV OGL / TransLink
  terms), Pages serving the cells, weekly Actions workflow green.
- **Code freeze** until after 9 Oct. README text edits are allowed; code is not.
  Anything found goes in HANDOFF under Brief 30.
- **Assignment deliverables:** repo public ✓ · Pages link at top of README ✓ ·
  Purpose (Jenna's words) ✓ · nine-step How to use it (tested on live) ✓ ·
  Source section ✓ · One example = demo/walkthrough.gif + MP4 link ✓ · Skill and
  limits ✓ · class slide: deck was view-only for Jenna; if not fixed, a
  one-page PDF to the instructor before 1:30 with: Curbside · one sentence ·
  screenshot · repo link · demo link (live site + MP4
  https://jennabruggeman.github.io/curbside/demo/walkthrough.mp4).
- **Demo:** live, 3–5 min, from briefs/demo-script.md (also demo-script.pdf,
  printed). Uses Jenna's saved design "West Georgia Street" as the measured
  backup (script calls it `Demo backup`); fresh import at Main St & E 26th Ave
  for the gate moment. No renders in the demo (Gallery line cut).
- **Sign-up open** (app_settings.invite_only = false) for the review period;
  turn back on after 9 Oct: `update public.app_settings set invite_only = true;`
- **Supabase:** policies for designs (4), missing designs columns added
  (`version` etc.), invite_codes table + invite-status.sql run, storage bucket
  `design-renders` + policies created (render-to-account UNTESTED — Jenna
  skipped the render test to avoid Replicate cost). Site URL and redirect
  wildcard `https://jennabruggeman.github.io/curbside/**` set.
- **Test account:** jenna.bruggeman27@gmail.com (password in Claude Code's
  chat; change or delete after the review).
- **Usage:** Jenna had a weekly reset Thursday; Claude Code's time estimates run
  ~20–30× high (a "20–28 h" brief took ~2.5 h; "4 h" sidebars took 8 min).
  Plan by that, not its numbers.

## Briefs this session (all in briefs/)
24-gis-cells.md (v2) · 23-stranger-test.md (file edition) · 25-fixes-round.md ·
26-demo-walkthrough.md (Claude Code's) · 27-friday-fixes.md · 28-clarity-round.md
· 29-clarity-round-2.md · 29c-last-round.md · demo-script.md. Briefs 22 and
original 23 exist only in session-6 chat. Tags: v0.10-fixes → v0.11-gis →
v0.12-fixes → v0.13 → v0.14 → v0.15 → v0.16 (+.1) → v0.17 (+.1 list fix,
+.2 idle-save fix).

## Order from here
1. **Fri 2 Oct, 7 am:** one rehearsal on the live site. Slide/PDF in before
   1:30. Laptop plugged in, signed in at the seat, tab 2 on the landing page.
2. **Fri in class:** demo; use two classmates' tools; file their reviews.
3. **By 9 Oct:** read reviews on the repo; for each, fix and retest or explain
   in the thread; close the issue (never delete). Collect them into Brief 30.
4. **Brief 30 (after 9 Oct), already logged:** persona 7 touch re-run;
   hosted photoreal relay; C03 not reading the map corner;
   two-tab last-save-wins; access gaps (no signed-out entry, no keyboard site
   pick, no touch drags, left panel won't scroll at 200 %, forced-colours
   states); Duplicate makes an empty copy; Section Undo after import rolls
   back the import; README step 7 wording (Survey (optional)); sample renders
   show the old 2.5 m umbrella; in-app report viewer clips notes column
   (`#view=Fit`); render-to-account test; the rest of the three triage tables
   in docs/process/23-triage.md.
   Removed from scope by Brief 30: full-city 3D (25-24), not needed; survey CSV
   validation, the survey import itself is removed (Brief 30 §10); any notch or
   free-polygon shape-editor work, replaced by Brief 30 §3 (rectangle + 45° corners).
5. **Then:** the voice-over demo video (Brief 26 full cut + Jenna's audio
   muxed with ffmpeg, now installed); a standalone user guide once reviews
   show where people got lost.

## Decisions made this session (with reasons)
- **Provenance drives every check result.** Estimate → Awaiting measurement
  (never Pass/Fail); imported unconfirmed → Provisional; measured/confirmed/
  typed ("You") → Pass/Fail. Verdict banner counts by those states. Generate
  refuses on *missing* site facts (not estimates) and names them.
- **Typed values count as measured** (29c-2); C16 route width = Manual's 1.5 m
  (G19 p. 60), BCBC 1.1 m noted only; deck default 2.5 m with advisory above,
  no cap; deck modelled flush with curb (C14).
- **Accessibility is a step** (tab between Furniture and Check, labelled
  *Access*); route-only overlay, no turning squares; Check's C16 row links to it.
- **Drawing language:** flat silhouette trees in plan and section (grey
  technical / pale green schematic, behind everything); no leaders in the
  live Plan, leaders on sheets; zoom-dependent detail (Far/Mid/Near); two-line
  clearance dimensions in plain words, red only on fail; context streets as
  surfaces; real OSM footprints; A-201 street section 1:100 + A-202 parklet
  section 1:50; A-301 removed; plain bottom-left drawing label; report ≤ ~12
  pages (C-002 folded into C-001, tree inventory gone); G-001 What to do next.
- **Onboarding:** Blank street / Vancouver street opening choice with layer
  picker; six-card first-sign-in walkthrough; step strip Site → Design →
  Access → Check → Export; all Done cards fold to one line; single viewport
  landing in 3D Cover view; Check sidebar = filters only.
- **Saving:** one status element, debounced 2 s, "Saved to your account ·
  time" / "Browser only" / "Save failed — retry"; offline designs offered to
  the account on next sign-in; design list no longer fetches thumbnails and
  shows the real error on failure.
- **Data:** cells from curbside-data (BBBike Vancouver OSM extract, CoV, GTFS),
  zero live requests during import; Overpass only via a per-layer "live"
  button; dual carriageways not merged; buildings sorted by distance to pick.
- **Repo hygiene:** third-party PDFs/images purged from history (repo deleted
  and re-created clean); .gitignore + pre-push hook (no PDF/DWG/ZIP, 5 MB cap,
  exceptions only for demo/walkthrough.{mp4,gif} ≤ 10 MB, sample PDFs must
  match app version); root tidied, process files in docs/process/.
- **Demo:** live only; 90-s silent GIF for README; no robot voice; Jenna's
  voice-over later. Pre-signed-in on stage, never type a password on a
  projector.

## Open questions
- Did the class deck get opened for editing, or did the PDF route get used?
- Render-to-account: works in simulation only; needs one real render on the
  hosted site and a second browser.
- Peer reviewers' issues (Friday) → scope of Brief 30.

## Working conventions (unchanged, plus)
Root cause → change → VERIFY → commit; one fact one store; five sites + blank
street for VERIFY (rb, cd, dn, W 4th at Yew, Main 2000/2500; demo address Main
St & E 26th Ave); Claude Code runs without pausing and logs decisions; Jenna
approves merges after reading the text report; Jenna's own walkthrough → chat
turns it into a numbered brief; briefs are files in briefs/, never chat-only;
agents never sign in on the live site (Jenna runs persona 6 herself); borderline
or structural items go last in a brief so the rest can merge if they overrun.
