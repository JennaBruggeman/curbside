# Brief 28 — Clarity round (Jenna's walkthrough, 2026-10-01 morning)

Branch `clarity` from master after Brief 27 merges (v0.13). Twelve items from
Jenna's own pass on v0.12. Five sites plus the blank street for VERIFY. Merge on
approval, tag v0.14. Order below is the order to run; §1 is the first thing a
reviewer sees, §4 is the largest. If anything in §4 runs long, stop it and note
it — §1–§3 merge on their own.

Style references Jenna supplied (tree silhouettes in plan, grey and green) are
style targets shown in chat only; nothing from them goes in the repo.

## §1 First use

1. **First-sign-in walkthrough.** Six-card modal the first time an account
   opens the tool, and from the ? menu as "How it works". Cards, each with
   one image (reuse the landing-page images; or a short looping clip of the
   tab), one sentence on what the step is, one line on what the user does:
   Site (pick a Vancouver street or start blank; what was measured vs guessed)
   · Design (deck, enclosure, furniture) · Accessibility (route check runs
   live) · Check (19 Manual checks; estimates never pass — go measure what it
   asks) · Visualize (3D, sun, renders with a key) · Export (sheets, survey
   sheet, What to do next). Progress dots, Next, Back, Skip; last button
   "Start with Site". Shown once per account (profile flag). Fold the 32b
   pass-rule sentence into the Check card, so first run has one
   interruption, not two. Match the landing page's look.
1b. **Landing page audit.** Hero: one of the demo renders (ours, from the
    repo) at full width, with the one-line description and Sign in / Try the
    sample report. "How it works": the Brief 22 images, retaken from v0.14
    after this brief lands so the trees, sidebar and Check tab are current;
    draft the copy for each step (one sentence, plain words — Jenna edits).
    A short strip of three renders further down ("What it can look like").
    Remove the invite-code line (reads app_settings). Links: README, repo,
    sample reports. Check it at 1024 px and on a phone. Everything shown on
    it must be ours: renders, screenshots, our own photos — no stock images.
2. **Locate card collapses when done.** After import, the card shows one line
   — "Howe Street · south-east side · runs 45° · Edit" — until Edit. When
   open: keep address, Locate on map, parklet side, the orientation diagram
   with compass. Bearing to one decimal. Behind a "Set manually" expander:
   the N-S/E-W preset buttons, bearing field, latitude/longitude, Paste
   coordinates. The "Search an address, click the street…" instruction only
   before locating.
3. **Check inputs commit on Save.** Each row input gets a Save button (Enter
   does the same). Until saved: row stays put, nothing recalculates, focus
   kept. On Save: value stored, result updates, row moves to its group with a
   brief highlight. Saved values stay visible and editable (value + Edit).
   Escape / click-away discards the draft and says so. Section width field:
   same. Replaces the interim fix from Brief 27 item 1. Also: remove the
   stray "?:" on question rows.

## §2 Accessibility as a step

4. **Accessibility tab** between Furniture and Check. View: the deck plan with
   the route overlay always on — route band, turning spaces at the ends,
   entry openings, any blocking piece highlighted with its pinch dimension.
   Sidebar: one card — verdict ("Route clear — 1.5 m maintained" /
   "Blocked at F2 — 1.1 m, needs 1.5 m"), the rule with its reference
   (Manual G19 p. 60), and a Fix list naming what to move and by how much.
   Furniture is draggable here. Live update. The Check tab's C16 row reads
   the same result; its button is "Open Accessibility". Step strip becomes
   Site → Design → Accessibility → Check → Export. The route overlay no
   longer appears in the Design tab's Plan at all; A-103 keeps printing it.

## §3 Drawing language (app Plan and sheets alike)

5. **Plan trees → flat silhouettes.** One filled, lobed canopy shape per tree,
   one flat tone, no outline, no inner rings, no dots; two or three lobe
   patterns at random rotation; scaled by canopy diameter; small filled
   trunk dot at centre. Technical: the same pale grey token as section
   trees; schematic: the same pale green. Drawn behind everything; the genus
   tag on top.
6. **Tree genus tags and object labels.** Trees within ~3 m share one tag
   ("AC ×6") with one short leader to the group centre; leaders never cross.
   In the app, genus tags belong to the Tags toggle; hover a canopy for
   "Acer — red maple". Sheets tag only trees within the sheet extent. The
   "Hydrant" and "Bus stop" text labels go — the H and B symbols are the
   label; text on hover / in the key. Genus codes in the Plan key.
7. **Clearance dimensions rewritten.** The measurement as an ordinary
   dimension, one decimal (29.4), with a small plain-words note beneath and
   a result mark: "to hydrant · min 5 m · C05 ✓" / "to crosswalk · min 6 m ·
   C03 ✗ short 0.8 m". Neutral colour on pass, red only on fail — app Plan
   and sheets. Legend line: "Clearance: measured · rule · check". The
   C-hexagon stays as the anchor to the Check row.
8. **Ground fills follow edited deck shapes.** Sidewalk, parking lane and
   road are continuous surfaces; the deck polygon sits on top; nothing is
   cut from the ground. Same in 3D and on sheets. Fix the colliding strings
   around the deck ends ("1.50 (≥1.50 C13)" over the symbol; "19.80 deck"
   struck by the section line) with the collision rule from 25-20c.
9. **Surrounding streets as surfaces, not centrelines.** Each OSM way becomes
   a road-surface polygon from centreline + width by class (cell `lanes` or
   `width` where present, City standard widths otherwise), drawn as a flat
   fill matching the main road. Footways: one faint thin line or nothing.
   Clipped cleanly to the plan extent. Buildings above roads, trees above
   both. Same geometry drives the 3D ground. Host-side buildings use their
   real OSM footprints with the model's height/setback applied.
10. **Protected bike-lane separation runs the full street.** Flex-posts,
    buffer or curb are a property of the street segment: full modelled
    length in 3D and Plan, at the City's standard spacing (cite it), gaps
    only at driveways and crossings. The C13 wheel stops and bollards at the
    parklet ends are unchanged.

## §4 Sheets

11. **Drawings fill the drawing area** (sheet minus margins, notes column,
    label strip). A-103: add 1:75 to the scale set — order 1:50, 1:75,
    1:100. A-102: keep 1:250 (1:200 if it fills better) and extend the extent
    to the full block face — buildings both sides, trees, the hydrant and
    stop the clearances reference. A-101: same at its scale. VERIFY: every
    plan sheet's drawing ≥ 70 % of the drawing-area width at five sites.
    Also fix: notes column clipped at the right page edge; "2.65" over the
    level symbol on A-103.
12. **Sample report.** One header bar (title · counts · pages · Schematic
    sample · Download PDF · Back), no tooltip repeating it. Pre-build the two
    sample PDFs as static files so "Sample report" opens instantly; if it
    must generate, show a blank page with "Building sample… 6 of 17", never
    the editor behind a viewer. Confirm where the sample cover photograph
    comes from and that it is licensed for the public repo; if it is not,
    replace it with a render.

## VERIFY
Walkthrough shows once, then never (new account vs existing) · Locate card
one line after import · type 12, edit to 1.2, Save, in Check and Section ·
Accessibility tab verdict changes live when a bench is dragged onto the route ·
a Plan at Commercial & 1st: silhouette trees, grouped tags, two-line
clearances, no red on passing · chamfer the deck: parking fill continuous ·
context roads are surfaces at all five sites · bollards full length · the
three plan sheets fill their area · sample report opens in < 1 s.

## Later (Brief 29, after Oct 9)
Full-city 3D (25-24); persona 7 touch re-run; hosted photoreal relay;
remaining 23-triage rows; Friday peer-review issues.
