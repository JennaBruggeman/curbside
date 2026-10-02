# Brief 27 — Friday fixes (from the Brief 23 full pass)

Branch `fixes-3` from master (v0.12-fixes). Source: `docs/process/23-triage.md`, 44
rows. Only what a classmate would hit on Friday is here; everything else is
Brief 28 (after Oct 9) and is listed at the end so it is not lost. Cite the
triage row in each commit. Five sites plus the blank street for VERIFY. Merge
on Jenna's approval, tag v0.13.

## Decisions (Jenna)
- C16 route width: the Manual's 1.5 m (G19, p. 60). BCBC's 1.1 m noted in
  the row text, not used.
- Deck width: default 2.5 m; no hard cap; an advisory when wider than 2.5 m
  ("Parklet Manual: typically 2.3–2.5 m; wider to be confirmed by the City").
- Deck level: modelled flush with the top of curb (within 12 mm); C14 judges
  the modelled gap. The +0.07 m goes.
- Persona 7 touch re-run: not now.
- Persona 6 (signed-in save path): Jenna runs it herself with the steps in
  the triage file.

## §1 Blocks (do first, in this order)

1. **Typed numbers lose keystrokes.** Check tab: the row re-groups on the
   first keystroke and the field loses focus. Re-group only on blur or
   Enter, never while a field has focus; keep focus and caret across any
   re-render. Section width field: same rule (older code, same fix). VERIFY:
   type 12, 1.25, 0.5 in each, mouse and keyboard, and once in a 1024 × 768
   touch context — the value entered is the value stored and printed.
2. **Header unreachable below ~1360 px.** The top bar must fit 1024 px: tabs
   collapse into fewer labels or a menu before anything is pushed off-screen;
   Sign in, + New and the design name are always visible. VERIFY at 1024,
   1280, 1366, 1920.
3. **Opening a generated scheme wipes the imported site.** The scheme is
   furniture and layout only; site, trees, street objects and all facts
   stay. VERIFY: import → Generate → open a scheme → trees still drawn, C02
   still "Awaiting", Export works without "Locate a site first".
4. **Signed-out edits not saved.** Furniture and Check entries must trigger
   the same local save as site/name/Edge. Also show a one-line note when
   signed out: "Saved in this browser only — sign in to keep designs."
5. **"+ New" discards the open design without asking.** Confirm if the open
   design has unsaved changes; otherwise proceed. And "+ New" shows the same
   Blank / Vancouver choice as a first visit (Jenna's bug from last night).
6. **Sign-in dialog cannot be closed.** Escape and an × close it; the
   account menu works by keyboard.
7. **"Place" is unclear.** Rename the button "Place on deck", show a one-line
   hint on first use ("click a spot on the deck; drag to move"), and give it
   a keyboard path: arrow keys nudge the selected piece, Enter confirms.

## §2 PDF honesty

8. Rule zones ("6.00 (≥6.00 C03)") are drawn as if measured. Any dimension
   that comes from a rule, not a measurement, is drawn in the provisional
   style (dashed, "req." suffix) and the legend says so.
9. Legend says red = fail, but passing zones are drawn red. Red only when the
   check fails; passing zones neutral.
10. The failing bus stop appears at two positions on two sheets — one
    object, one position; find the second source and delete it.
11. Checks passing on typed numbers with nothing drawn (driveway, pole,
    drainage) print "value entered, not drawn" in the measured column.
12. C06 cites the wrong page; it is p. 62. Check every C-row's page against
    the Manual once.

## §3 Small, visible

13. The confirmation-email redirect: add the Pages URL to Supabase redirect
    allow-list (Jenna does the Supabase step; the app side is done).
14. C04 slope printed "0.1 %" in three runs — find the formatting path (likely
    a unit mix-up on entry) even if it cannot be reproduced from the logs.

## VERIFY
All of §1 at five sites + blank street, with a 1024 × 768 viewport once; the
README steps on the live site after merge; the technical PDF at Commercial &
1st read through once for §2.

## Brief 28 (after Oct 9) — carried over, not lost
From this triage: everything in the 44-row table not listed above (keyboard
street pick, tablet polish, remaining PDF notes). From Brief 25: item 24
(full-city 3D), persona 7 touch re-run, hosted photoreal relay. Plus the
peer-review issues from Friday.
