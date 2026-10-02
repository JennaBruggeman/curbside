# Curbside — Handoff for New Chat (Session 4)

**Read this first, then the project's own `HANDOFF.md` (in the repo, kept current by Claude Code).**
This file is written by the chat-side Claude for the next chat-side Claude. Jenna works in two places:
Claude chat (diagnosis, briefs, review) and Claude Code (Opus 5.5, implements the briefs).
Her workflow: she pastes screenshots of Claude Code's reports here; chat writes the next brief.

---

## What the tool is

**Curbside** (renamed from "Vancouver Parklet Siting Checker" — the rename is agreed but NOT yet applied in code;
the topbar still says PARKLET VANCOUVER). A single-file HTML app (`parklet-checker.html`, ~20k lines) for
schematic parklet design on Vancouver streets: Site / Design / Visualize / Generate / Check / Furniture /
Settings / Export tabs. Plan, Section and 3D are three viewports over ONE design model. Compliance runs the
City of Vancouver Parklet Manual (C01–C15) and the Engineering Design Manual (EDM 2026) continuously.

One-line description Jenna approved:
> Curbside — schematic parklet design for Vancouver streets, compliant by construction.

Repo: `C:\Users\bangp\Desktop\UBC\Fall_2026\ARCH 540 AI\New folder` (git, branch `master`, tagged releases).
Local server: `tools/serve.ps1 -Port 8766` (or `tools/start.cmd`). App must be opened at
`http://localhost:8766/parklet-checker.html`, never `file://`. Keys: `.render-key` (Replicate, git-ignored,
repo root); Mapillary client token lives in browser localStorage. **Never ask Jenna to paste keys in chat.**

---

## Conventions that now govern the code (do not relitigate)

- **One model.** `DESIGN_MODEL` (built by `buildDesignModel()`) is the only source of truth: landmarks,
  crossSection segments, buildings (with programme/use/name), vegetation, section {z, dir, depth}, site
  {lat, lon, streetBearing, parkletSide, northDeg}, paths (animation), objects (furniture).
- **One mapping per view.** Plan uses `worldToPlan()`; Section uses `worldToSection()`; 3D reads the model.
  World: +X across street toward road, +Z along street, +Y up, right-handed; **N = −Z** (`CAD_CARDINAL`).
  Plan is a true top-down projection (+Z drawn to the LEFT). Never store positions in pixels or fractions.
- **One palette** (`DS.segColor` / `segColor3D`), one lane envelope (`LANE_ENVELOPE`, EDM Table 8-10), one
  materials table (`FL_MATERIALS`), one furniture archetype set (`FL_ARCHETYPES`, ~60 parametric types +
  entourage), one generator ruleset (`GEN.PATTERNS`, access model with flood-filled route, `GEN.ROUTE_W`).
- **Checks are the only compliance logic.** Generator, report, and UI call the existing C01–C15 functions.
- **Nothing measures or renders through the live viewports except the viewports themselves.** Exports,
  report, axon, renders all use offscreen targets. Hidden-panel measurement has caused four bugs.
- **`checkLandmarkConsistency()`** runs after every sync and warns loudly on drift (landmarks, orientation,
  section boxes, vegetation, manholes, buildings). It must skip DOM checks when panels are hidden.
- **Verify with numbers, not screenshots.** Every brief ends with a VERIFY block; Claude Code reports them.
- Git: one commit per distinct change; briefs saved as `briefs/NN-name.md` and read by Claude Code
  (pasting long prompts into the terminal truncates them). `.gitattributes` should force LF — CRLF has crept
  back twice; check `file parklet-checker.html` line endings if diffs look huge.

---

## Branch / merge state at handoff (verify with `git log --oneline -15` and `git branch`)

Merged and tagged on master: viewports, furniture archetypes + materials, entourage, axon animation export
(Brief 06), UI cleanup (07), section depth/direction (08), lane envelope, Generate tab (09), report v1 (10,
superseded), visualize/rendered scene + sun (11), orientation (11a), photoreal via Replicate (11b),
building programme, local-run scripts — tag `v0.4-photoreal` was requested; confirm it exists.

**Unmerged branch: `site-map` (Brief 13)** — map picker (MapLibre + Nominatim), OSM/CoV import with
provenance tags and "confirm on site" flow, Mapillary context photo for renders. Four fixes were requested
before merge (see In-flight). Merge → tag `v0.5-site`.

---

## In flight / next actions (in order)

1. **site-map fixes before merge** (prompt already sent; confirm they landed):
   import must edit Section segments in place, not rebuild; dual-carriageway (two one-way OSM ways) merge
   into one two-way street; far-side parking estimate imports as a 'parking' segment; street trees are an
   advisory, not a numbered check; import button needs step progress / timeout / retry and a "locate on
   map first" disabled state (Jenna reported "nothing happens" — it was a slow Overpass call with no UI).
2. **Merge site-map, tag v0.5-site.**
3. **Rename to Curbside** everywhere: topbar wordmark + subtitle, `<title>`, report title block, HANDOFF,
   Nominatim identifier, captions, start scripts. One prompt; do it before Brief 12.
4. **Photoreal railing fidelity**: Nano Banana Pro drops the traffic-side railing on Street/Sidewalk/Aerial.
   Instruction must describe the railing from archetype params ("galvanised steel railing, two rails,
   posts every 1.5 m, 1.1 m high, must remain"). Re-run 4 presets; railing must read 'kept'.
5. **Brief 12 — Report v2 (NOT BUILT YET).** The current PDF is still Brief 10's: rotated A3 sheets inside
   portrait pages, garbled text extraction (font cmap), cover = schematic axon, no render sheets. Brief 12
   (in `briefs/12-report-v2.md`) specifies: single A3 landscape page size, no rotate transforms, embedded
   font with real text, true-scale plan 1:100 / section 1:50 (scale bar = 100 mm), Parklet-Manual-style
   image-led sheets (cover + design views from ticked photoreal renders, fallback to base render; renders
   that FAIL design fidelity are withheld), Schematic/Technical export option (technical = no photoreal),
   furniture schedule with de-collided tags, compliance rows with rule-first wording and "not entered" for
   defaults, lane-envelope sheet, host-frontage line, Mapillary credit under renders. Render cache is keyed
   by design hash — report must refuse stale renders. Also: Jenna last exported from an EMPTY design; she
   must export from the design she rendered.
6. Then a HANDOFF_SESSION update from Claude Code and a fresh `git tag`.

---

## Photoreal pipeline (state of the art as of today)

- Providers via `tools/serve.ps1` proxy (model allow-list): `fofr/sdxl-multi-controlnet-lora` (strict
  geometry, depth+edge control), `google/nano-banana` and `google/nano-banana-pro` (**default**; best
  results by far — Corner preset matched Jenna's reference photo). Inputs: colour render first, depth pass
  second, optional Mapillary photo third ("appearance only"). Framing check + design-fidelity check
  (per-object kept/moved/missing inside design masks; context scored separately, never failed).
- Camera presets: 49.5 mm equivalent lens, Street from the far side of the road 9–11 m with a 65%-of-deck
  framing rule; Sidewalk 9 m along; Corner 3 m out at 2.2 m; Aerial = axon. Blur by distance from deck
  along the street, never on the adjacent road.
- Cost: SDXL ≈ $0.07 per Render 4; Nano Banana Pro billed per image (price not confirmed — check dashboard).
  Photoreal is manual-trigger only; never called by Generate cards or the report.
- Every AI image carries "AI-assisted visualisation – indicative".
- Alternative route agreed as complementary: glTF export → Twinmotion/Blender (Brief 11b included it;
  confirm it shipped).

---

## Numbers waiting on Jenna (from the Parklet Manual / EDM — chat must not invent these)

- `GEN.ROUTE_W` — accessible route width inside the parklet. Currently 0.92 m (BCBC 3.8 clear width) with a
  "confirm against Parklet Manual" comment.
- Street-tree clearance — advisory only until a Manual page gives a number.
- `SE_TYPES` non-lane segment min/max sources (parking, transit, turn lane, planting, curb) — cite or mark
  "UI envelope".
- Nano Banana Pro per-image price (from her Replicate dashboard).
- (Optional) Nominatim contact email — only needed if the tool is published.

EDM 2026 Table 8-10 (§8.7.3.1, pp. 275–277) is already encoded in `LANE_ENVELOPE` with notes 4 and 8.
C02 (adjacent lane ≥ 3.0 m / 3.2 m bus-truck, Parklet Manual p.20) is the compliance authority for lanes.

---

## Working-style notes for whoever picks this up

- Jenna is an M.Arch student; she judges by looking at drawings and renders, and her eye is right — when
  she says "warped" or "unclear", find the geometric cause (it was camera FOV and blur, not the AI).
- Almost every bug in this project has been the same disease: one fact computed or stored in two places.
  First question for any new bug: "is this value coming from DESIGN_MODEL through the one mapping, or is
  it recomputed / stored locally?" Second: "is a hidden panel being measured?"
- Briefs work best as: root cause stated → what to change → VERIFY with numbers → commit, do not merge.
  Keep Claude Code on branches; Jenna approves merges after looking.
- Don't let the LLM generate geometry. Rules + checks generate; the Assistant may write rationale.
- When Claude Code offers options, chat should pick and explain briefly; Jenna asks "which one?".
- She sometimes pastes secrets by accident — if a token appears in chat, tell her to revoke it immediately.
