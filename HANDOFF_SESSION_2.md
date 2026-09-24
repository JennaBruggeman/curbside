# Parklet Checker — Handoff for New Chat

**Context:** This picks up from a long debugging session on `parklet-checker.html`
(the Vancouver Parklet Compliance Checker, a single-file HTML/JS app — Plan,
Section A–A, and 3D views over a shared design model, plus a chat-based design
assistant). Project's own `HANDOFF.md` (living in the project folder, tracking
R1–R11) covers the feature history; this file covers what happened in the most
recent session specifically: a run of real, found-and-fixed bugs, plus a
broader structural audit.

**Tell the new chat to read the project's own `HANDOFF.md` first if it exists,
then this file for what's currently in flight.**

---

## Where things stand right now

- **Git is set up** in the project folder (first real safety net after a lot
  of "something broke and nobody knows what changed"). Standing instruction
  given to Claude Code: commit after every distinct change, with a message.
- **A structural audit prompt was just sent to Claude Code and may still be
  running** (see "Task in flight" below). **Do not send the second prompt
  below until that one finishes, is verified, and is committed** — they touch
  overlapping code (`renderCrossSection`/`renderPlanView`'s reads of
  `SIDEWALK_W`/`BLDG_L`/`BLDG_R`) and running them concurrently risks a
  conflicting edit undoing a fix.
- User was advised to consider `/model opus` in Claude Code for this kind of
  architectural/cross-file work (context is preserved across a model switch;
  can switch back to Sonnet for narrower follow-up edits).

---

## Task in flight (sent to Claude Code, may be mid-run)

**"Complete the migration to `DESIGN_MODEL`"** — the big one. Summary of what
it asks for:

- `DESIGN_MODEL.landmarks` exists and is correctly structured (sidewalk
  extents, building inner/outer face X, deck X0/X1, scene min/max X) but was
  only ever wired into `renderMassView` (3D). **Confirmed via direct grep**
  that `renderPlanView` (Plan) *and* `renderCrossSection` (Section A–A) both
  still read `SIDEWALK_W`, `BLDG_L`, `BLDG_R` **directly**, independently of
  the model — e.g. `const _pvBL0 = BLDG_L.buildings[0];` in Plan.
- Task: audit every direct read of those globals outside `buildDesignModel()`,
  migrate all three renderers to read `DESIGN_MODEL.landmarks` exclusively,
  delete the old duplicate local computations (not just add model reads
  alongside them — delete the old code).
- Add a standing console-warning consistency check comparing what Plan/3D
  actually rendered against what the model says, so future drift is loud
  instead of silent.
- **Verification the new chat should confirm actually happened:** grep the
  file afterward for direct `BLDG_L`/`BLDG_R`/`SIDEWALK_W` reads outside
  `buildDesignModel()` — should be none left in the three renderers. Change
  sidewalk width + building depth on both sides; Plan/Section/3D should all
  agree with no drift. Console should show no consistency-check warnings.

---

## Second task — ready to send, but wait for the above to land + commit first

**"Structural cleanup pass"** — smaller, safe items found during a follow-up
audit:

1. Delete a confirmed-dead code block: search `if (false) { // dead block`
   (old inline 3D-init code, superseded by `ensure3DReady()`, ~58 lines,
   verify the matching closing brace before deleting rather than eyeballing
   it).
2. Delete the first (superseded, 100%-dead) definition of `cadToolsUpdate`
   (~line 10499 in the version audited this session — **line numbers will
   have shifted** after the DESIGN_MODEL migration above, re-locate by
   function name). Confirmed the second definition (~line 10612) is a strict
   upgrade (adds an actions-panel toggle + name-lookup fallback) — it's the
   one actually in effect; the first is never reached.
3. Extend the DESIGN_MODEL migration (see task above) to explicitly cover
   `renderCrossSection` if it wasn't already swept up in that pass.
4. Lower priority, just flag it: `FL3D.placed` and `DESIGN_MODEL.objects` are
   two separate copies of furniture data kept in sync purely by convention
   (every mutation path currently remembers to call `_dmSyncObject()` — but
   nothing enforces that a future one will). Worth a runtime consistency
   check rather than urgent action.

Systematically re-checked the whole file for the `window.X` vs `let/const X`
scoping bug (the exact class that caused three separate real bugs this
session) — **confirmed clean, no more live instances of that specific
mistake** as of this session's audit. Don't re-litigate that class of bug
unless new code introduces it.

---

## Bugs found and fixed this session (for context — already shipped)

All of these followed the *same underlying shape*: a value computed
separately by two different pieces of code that happened to agree, until one
was edited in isolation. Worth keeping this pattern in mind for anything new
found later.

1. **Section-editor writes went to a phantom `window.X` instead of the real
   variable.** `designBikeLane`, `SIDEWALK_W`, etc. are declared with
   top-level `let` — which does **not** attach to `window`. The section
   editor's `_seToGlobals()` was writing `window.designBikeLane = …`, which
   nothing else ever read. Fixed by writing the bare identifiers directly.
2. **A dead startup override silently hid the Section/3D panels** ~400ms
   after every page load, overriding the intended "All panels visible"
   default. Confirmed via headless load-and-check; removed.
3. **3D camera didn't re-frame on bike-lane/buffer size changes** — target
   updated, position didn't. Minor, fixed alongside #2.
4. **`ensure3DReady()`'s own internal guard checked `window._3d`** (always
   `undefined`, same phantom-window mistake as #1) instead of the real `_3d`,
   causing it to unconditionally rebuild the entire 3D scene (fresh camera,
   fresh OrbitControls, orphaned old `<canvas>` left in the DOM) every time
   the user switched to the 3D tab, placed furniture, or dragged a street
   asset — silently discarding any pan/orbit the user had done. Fixed.
5. **Furniture position desync between Plan and 3D after moving (not after
   initial placement).** Root cause: two data stores — `FL3D.placed` (live,
   correct) and `DESIGN_MODEL.objects` (a cache Plan prefers once populated).
   `moveFurnitureWorld()`/`moveFurnCardinal()` (the N/E/S/W move buttons, the
   ΔX/ΔZ apply button) updated the live store but never called
   `_dmSyncObject()` to refresh the cache, so Plan kept drawing furniture at
   its original placement position after any move. Fixed by adding the sync
   call to the move path.
6. **Camera framing attempts (x3) did not, and structurally could not, make
   the 3D view's top-to-bottom or left-to-right reading match Plan's fixed
   orthographic convention.** Verified this empirically each time by
   projecting real world coordinates through the actual Three.js camera math
   (not eyeballing screenshots) — e.g. confirmed the near building was being
   clipped out of frame, then confirmed a later attempt still produced
   screen-left motion for a world "+X / East" furniture move while Plan
   showed the same change along its own (different) axis. **This is not a
   bug that camera repositioning can fix** — an oblique perspective camera
   and a fixed top-down orthographic plan do not have a forced correspondence
   between world axes and screen directions. The agreed fix is a persistent
   compass/orientation indicator drawn directly in the 3D viewport (Plan
   already has one), not further camera tuning. **Check whether this was
   actually built** — it was proposed in the same brief as the sidewalk-width
   bug fix; confirm both landed, since they were bundled together.
7. **`buildDesignModel()`'s sidewalk-width landmark silently defaulted to
   3.0m instead of the real 1.8m** — `var _lmSW = (typeof SW !== 'undefined')
   ? SW : 3.0;` where `SW` is a variable local to a *different* function
   (`renderMassView`), invisible from `buildDesignModel()`'s scope, so the
   check always failed and the hardcoded fallback always fired. This is what
   led directly into the bigger DESIGN_MODEL migration task above — it was
   the smoking gun that proved the model, while well-structured, wasn't being
   fully or correctly consumed. Confirmed fixed as part of that task (verify
   in the new chat: `buildDesignModel().landmarks.sidewalkL` should span
   exactly `-1.8` to `0` for a 1.8m sidewalk, not `-3`).

---

## Working style notes for whoever picks this up

- **The user gets frustrated (rightly) when a fix for one view quietly breaks
  another.** The pattern behind nearly every bug this session was *the same
  fact computed independently in more than one place*. When diagnosing
  anything new, first ask "is this value coming from `DESIGN_MODEL`, or is it
  being recomputed locally in this renderer?" before looking for a sign error
  or off-by-one.
- **Verify claims with real numbers, not screenshots alone.** Several
  "should be fixed now" attempts weren't, because the fix was checked by eye
  rather than by projecting actual coordinates through the actual math (the
  camera issue in particular needed real Three.js projection math run
  headlessly to see clearly what was happening — screenshots alone were
  misleading both ways).
- **Git + commit discipline is the actual fix for "everything feels like
  it's glitching."** Encourage small, frequent, named commits from Claude
  Code sessions from here on, and a `git diff` check before assuming a new
  bug is mysterious — half the time the recent diff makes it obvious.
