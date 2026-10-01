# Brief 29 — Clarity round 2 (Jenna's v0.14 walkthrough, 2026-10-01)

Branch `clarity-2` from master after the v0.14 smoke pass is read. Eight items
plus a bug list. Five sites plus the blank street for VERIFY. Merge on approval,
tag v0.15. Order below is the run order; §1–§2 are what Friday's reviewers see
first. Item 8 (render gallery to the account) is the only structural one: if it
runs long, stop it, keep the gallery UI reading browser-cached renders, and log
the account-storage half for Brief 30.

## §1 Landing and first view

1. **One viewport, landing in 3D.** Remove the **All** split view; the switcher
   is Plan · Section · 3D. A design opens in 3D on the Cover camera; the chosen
   view persists per browser. The Plan **Key** starts collapsed (a "Key ▸"
   chip). The Section's Add-segment toolbar appears only when Section is the
   active view.
1b. **Cover camera vs real footprints.** With real OSM footprints extruded, the
   Cover view at Smithe St put a building face across the top half of the
   frame. The Cover preset frames the deck with the host building *behind* it:
   pull back or raise the camera until no building face is nearer than the
   far curb, at every one of the five sites.
2. **Restore the animated hero.** The previous landing animation returns as the
   top section with the title and the two buttons over it. The render moves
   down; "What it can look like" stays as built. Headline: drop "compliant by
   construction" (the tool is compliant only once measured) and use the first
   sentence of the README Purpose. Keep the "AI-assisted visualisation ·
   indicative" caption on every render.

## §2 Sidebars and tags

3. **Every Done step folds.** Import context and Place parklet collapse like
   Locate: one line plus Edit — "Smithe Street · 3 lanes one-way · bus/truck
   route · 103 items · Edit"; "Host: Tenant Resource & Advisory Centre ·
   19.8 m deck · Edit". The explanatory paragraph under Import goes behind ⓘ.
   Only the current, not-done step is open on arrival.
4. **No leaders in the interactive Plan; tags unique.** Live Plan: tags sit on
   or beside their object, collisions resolved by nudging, no leader lines.
   Sheets keep leaders. One renderer flag (`leaders: false` live, `true`
   sheets). Bugs: two pieces both tagged F1 (tags must be unique per piece);
   "Parklet" printed over a piece of furniture; "19.80 deck" inside the deck —
   deck labels sit outside the deck outline.
5. **Zoom-dependent detail in the live Plan and Section.** Three levels by
   on-screen scale: **Far** (< ~1:500) deck, ground, buildings, canopies,
   C-hexagons only; clearance zones as faint fills; no text. **Mid**
   (1:500–1:150) add furniture tags and two-line clearance dimensions for
   failing / awaiting checks only. **Near** (> 1:150) everything the sheets
   show, minus leaders. Hover shows the full label at any level. Text never
   drops below a readable minimum; if it can't fit it drops a level.
7. **Check sidebar: filters and counts only.** Keep Show (All / Failing /
   Provisional / Passing) and the one-line count. The "Confirm on site" list
   leaves the sidebar: one button **Confirm imported items (n)** opens a
   drawer, and each provisional row carries its own Confirm. Nothing in the
   sidebar repeats a row. Bugs: the sidebar says both "Nothing imported to
   confirm" and "90 imported items still to confirm" — fix the condition;
   C16 fails "no accessible seat" on a deck with a table — a table at
   0.70–0.80 m counts as an accessible seat, else the state is Not entered,
   never Fail.

## §3 Accessibility

6. **Route only.** In the Accessibility tab: one continuous shaded band from
   each entry to the accessible seat at its actual clear width, coloured by
   state (clear / blocked), the pinch point marked with its width when
   blocked. No turning squares, no dashed rectangles. C16 checks any turning
   requirement silently; the band just widens there. Entry openings marked in
   the enclosure line, labelled "Entry". The sidebar card (verdict, rule, Fix
   list) is visible on arrival. Design tab shows none of this.

## §4 Renders

8. **Gallery.** Replace "Cached renders · n for this design (design 47d231b1)"
   with a **Gallery** section in the Visualize sidebar: thumbnail grid of the
   open design's renders, each with preset, date, size, and open · re-export
   (PNG at chosen scale) · delete. Renders persist with the design to the
   account (Supabase storage), so they appear on any machine; the browser
   cache stays as a fast path. Design ids never appear in the UI. Render still
   / Render all presets add to the gallery and still download.

## VERIFY
Open any design: 3D Cover, no building face in the frame, at five sites ·
Site sidebar after import: three one-line cards, current step open · live
Plan at three zooms: no leaders, no overlapping text, F-tags unique ·
Accessibility tab: band from entry to seat, blocked state when a planter is
dropped on it · Check sidebar: no duplicate list, no contradictory sentence ·
C16 Not entered on an empty deck, Pass with a table reachable · landing page:
animation on top, renders below, headline is the Purpose sentence ·
Gallery: render on machine A appears on machine B after sign-in.

## Brief 30 (after Oct 9)
Full-city 3D; persona 7 touch; hosted relay; any item 8 overflow; the peer
review issues.
