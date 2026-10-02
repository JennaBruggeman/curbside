# Curbside — chat handoff, session 6 (2026-09-30)

Read this first in the next chat. Previous handoff: HANDOFF_SESSION_5.md.
Claude Code keeps its own HANDOFF.md in the repo; this file is the chat side.

## Where things stand

- **master**: v0.7 + Brief 19 merged? No. Brief 19 (drawing style) sits on
  `drawing-style`, five commits, reviewed and approved with fixes.
- **Brief 19b** (sheet fixes: trees off A-102, A-201 never below 1:100, key
  text centred, section line only across the section extent, drawing-list
  scales from title blocks, Robson C05 dims the failing hydrant, Site table
  address = cover, dedupe bus routes) was written but NOT applied during 21.
  It is item 1 of Brief 21c.
- **Brief 21** (UX, §1–§13) is complete on `ux`, 17 commits, not merged.
  Report reviewed in chat; every VERIFY passed at the three sites.
- **Brief 21b** (enclosure archetypes §12, City-supplied wheel stops §13) was
  folded into 21 and is done.
- **Brief 21c** (close-out) issued: apply 19b; remove the generator's 0.45 m
  edge band (enclosure + buffer replace it); umbrella = one library
  definition at 2.60 m; migration note for pre-§12 end planters; picket bars
  as Rhino block instances; single "Add a key" prompt; C18 interpretation on
  X-001. Then merge ux → master, tag v0.9-ux.
- **Brief 22** (fixes round, 11 items) issued, runs after 21c on `fixes`.
- **Brief 24** (GIS cells) issued, runs after 22 on `gis`.
- **Brief 23** (stranger test v2) written, waits until 22 and 24 are merged
  and Supabase is set up. Numbering: 24 was pencilled for post-stranger
  fixes; that is now **Brief 25**.
- Claude Code is installing Node + Playwright now (approved); they are needed
  for 22 items 10–11, 24 and 23.

## Order from here
1. 21c → merge → v0.9-ux
2. 22 → merge → v0.10-fixes
3. 24 → merge → v0.11-gis
4. Jenna: run supabase/schema.sql in the Supabase SQL editor; set the invite
   code (`update public.app_settings set invite_code = '…';`); confirm
   Settings › Connections key fields are empty in her own browser; generate
   invite codes for the test accounts (16 if 23 runs 2 passes).
5. 23 (stranger test) — add to its pre-decided list: personas 1–6 on Sonnet,
   parent and 7–8 on Opus; 2 runs per persona, a third only if run 2 found
   something new; skip §6 second round (goes into 25's VERIFY).
6. 25 fixes from 23-triage.md
7. Demo video: tools/demo/walkthrough.js (from 22 item 11) + Jenna's voice-over.

## Decisions made this session (with reasons)
- **Railing height 0.90 m stands.** Parklet Manual E2: enclosure 0.75–1.0 m,
  context dependent; BCBC guard rules don't apply (drop < 600 mm). 1.1 m was
  over the band. A-301 can be trusted.
- **Enclosure is designable; wheel stops are not.** Manual p. 48/59: the
  City supplies and installs wheel stops and flexible bollards; no
  dimension given. Tool draws them as City-supplied symbols in the C13 zone,
  no A-301 detail, not in S-001, layer CONTEXT_CITY in exports.
- **Buffer sits inside the deck** (the Manual fixes the outer edge via P2 and
  C02); it only reduces usable width. The generator's old 0.45 m edge band
  was the same fact twice → removed in 21c.
- **New checks** C17 enclosure height (E2), C18 two 1.8 m openings (E3),
  C19 overhead ≥ 2.1 m (E5). C16 reserved for disability (Brief 20).
- **Site = existing street (read-only, imported, overridable and logged);
  Section = proposed street (fully editable).** C02/C-002 evaluate the
  proposed; X-001 records the existing; new C-002 "Street changes" block.
- **Data sources verified:** City open data has one-way streets, bikeways
  (type/subtype, centreline-based so side is approximate), truck routes,
  right-of-way widths (explicitly NOT curb-to-curb). OSM has oneway (reliable),
  cycleway side, lanes (good but not guaranteed), width (rare). TransLink
  GTFS for bus routes. So: direction, bike lane, route type, ROW are derived;
  curb-to-curb stays a field measurement (Manual says measure it); lane count
  prefilled from OSM, confirmed by the user.
- **Overpass is unreliable at runtime** (Jenna hit 3 failures). Brief 24
  replaces it with pre-built 1 km cells in a `curbside-data` repo, refreshed
  weekly by GitHub Actions, cached in IndexedDB; Overpass only as a manual
  refresh.
- **Three-stage design state**: no site → seed parklet (deck at frontage,
  default enclosure, no furniture) → designing. "+ New" is truly blank;
  sign-in opens no design. The old DEFAULT_STATE carried a demo street.
- **Furniture**: tags smaller with leaders and a toggle; report export
  options (schedule/sources/compliance/renders); user furniture gets a spec
  card (prefilled from GLB/IFC metadata, dimensions from geometry) and prints
  with a provenance marker (F3•) and an "as entered, not verified" note;
  attachments as an appendix sheet.
- **Usage saving**: fold small briefs into the next run; Sonnet for browsing
  agents; paste Claude Code's text report, not screenshots.

## Open questions
- Brief 22 item 8: attachments (photo / product PDF) as an appendix sheet —
  Jenna hasn't explicitly said yes; I put it in.
- Brief 25 scope depends on 23-triage.md.
- Landing page copy for "How it works" (item 10 makes the images only).

## Files this session produced (in the repo's briefs/)
19b-sheet-fixes.md · 21b-enclosure.md · 21c-close-out.md · 22-fixes-round.md ·
23-stranger-test.md (v2) · 24-gis-cells.md

## Working conventions (unchanged)
Root cause → change → VERIFY → commit; one fact one store; three sites for
every VERIFY; Claude Code runs without pausing and logs decisions; Jenna
approves merges after reviewing the report in chat.
