# Curbside — class demo script (ARCH 540, Fri 2 Oct, 3–5 min)

Narration is written as spoken; clicks are in [brackets] where they fall.
Target 4:30. Button labels checked against the live v0.14 on Thu 1 Oct
(Claude Code, signed out, at 1920 × 1080); the ⚠ marks are gone where the
label is now what the app shows. Steps whose expected state does not match
are listed in Claude Code's chat report, not changed here.

## Set-up at your seat (10 min before)

- Chrome, one window, every other window closed. Bookmarks bar hidden
  (Ctrl+Shift+B). Zoom 100 % (Ctrl+0).
- **Tab 1:** signed in with the test account; **My designs** showing
  `Demo backup`. **Tab 2:** the landing page, in front.
- Second window: the walkthrough MP4, paused at 0:00, minimised.
- Sticky note: the demo address, exactly as it autocompletes (checked 7 am).
- Phone hotspot on, laptop not yet on it. Plug in → Win+P → Duplicate.

## Thursday night (must be done)

1. **Build `Demo backup`** on the demo laptop, in the Chrome profile you will
   present from: import the demo address; enter every survey value as
   measured (Site › **4 Survey (optional)** › **Survey template (CSV)**,
   fill its measured column, **Import filled template…**; or type the
   roadway and sidewalk widths straight into Site › **Street widths**, whose
   fields say "measured curb-to-curb — enter from field measurement"),
   plausible passing numbers; confirm **Generate produces layouts**; rename
   the design `Demo backup`; confirm it appears in My designs from a second
   browser.
2. **Renders:** start the local server (`tools/start.cmd`), add your
   Replicate key in Settings, open `Demo backup` → Visualize → **Render
   (photoreal, 4 presets)**. Close and reopen the design; the Gallery must
   still show them. Ask Claude Code whether renders save to the account or
   only to this browser; if browser-only, present from this machine and
   profile, no exceptions.
3. Ask Claude Code: "Does Generate refuse on estimates, and what exactly
   does the message say?" Put its wording into the Site section below.
4. Two timed runs; fill the log. One more Friday 7 am, no changes after.

---

## Landing [tab 2 showing · hands off the mouse]

"So this is Curbside. It's a schematic design and compliance tool for
parklets on Vancouver streets. The idea is simple: you give it an address, it
builds the street from public data, you design a parklet on top of it, and
the whole time it's checking you against the City's Parklet Manual. It's live
at this link, the repo is public, and sign-up is open, so you can go use it
today. Let me show you a block I haven't tried before."

## Site [Ctrl+1 → tab 1]

"I've already signed in. [click **+ New Design** in My designs; with no
dialog open it is **+ New** in the top bar] Two ways to start, a
generic street or a real one; I want a real one. [click **Locate on map**
· type the address · Enter · click the result] It finds the street, I tell it which one and
which side, [click the street · click the side · click **Use this location**]
and it asks what to bring in: City open data, OpenStreetMap, TransLink.
Defaults are fine. [click **Import street context** · count to five]

There's the block. Buildings, trees, the bike lane, the bus stop, the
hydrant. Now this is the part I care most about. [open **Street widths**]
Every number here knows where it came from. The sidewalk it measured from
building data. The road width it's guessing from the lane count, and it tells
me so, in orange. Nothing in this tool pretends to know more than it does.
[close **Street widths**]

And watch what that costs me. [click the **Generate** tab · click the blue
**Generate** button] It won't generate.
[point at its message, in red: "Set these site facts first (the checks
cannot pass without them): 01 Parking restrictions; 03 Intersection
distance; 04 Running slope; 07 Pole; 08 Signal box; 06 Driveway; 09 Manhole
/ valve / grate; 10 FD / utility connections, fire exits; 11 Drainage; 13
Setback to adjacent parking." — the list is whatever the block lacks; this
is Main St & E 26th Ave] It doesn't know the
lane widths, the crosswalk distance, the slope. Those are estimates, and it
refuses to design on estimates. So yesterday I went and measured this block.
[click **My designs** · click `Demo backup`] Same street, with the survey
entered. [open **Street widths**] Now these say measured. [close it]"

## Generate [click the **Generate** tab; after a refusal the blue button is gone: open **Output** in the left panel · click **Generate**]

"And now it will. Generate makes layouts that already fit the clearances and
the accessible route, and you can weight them toward seating, planting or
shade. I'll take the first one. [click **Open in Design** on the first
card]"

## Design and Furniture

"Now I'm designing, and everything's live. [drag the bench a metre along the
deck] Pieces snap to the deck and keep their tags. [click **Furniture**] The
library is generic archetypes with real dimensions, and you can import your
own model, a GLB or an IFC; it gets a spec card and shows up in the schedule
marked unverified. Let me put something somewhere stupid. [drag the
**Planter** card into the middle of the route]"

## Accessibility [click **Accessibility** (the tab reads **Access** in a window under 1700 px wide)]

"It tells me immediately that I've broken the route, where, and by how much.
The Manual wants a metre and a half; I've left it one-point-one. [drag the
planter to the far end of the deck] Fixed. That check runs the whole time
you're designing, not at the end when you've fallen in love with the layout."

## Check [click **Check**]

"Here's the full set: nineteen checks from the Manual, grouped by what they
actually mean. Most are green because I measured. The ones marked provisional
lean on City data nobody has confirmed on site, like where that hydrant
really is. [click the provisional row] It passes, but it tells you it's
trusting the City's dot on a map.

And here's what a guess looks like. [click **My designs** · open the fresh
design · click **Check**] Same block, before I measured. Not one of these is
failing. 'Awaiting measurement' means I owe it a tape measure. [click **C02**]
The lane-width check won't pass or fail me on an estimated road width; it
just says, go measure. [click **C03** · type **8** · click **Save**] The
moment I give it a real number, it commits, and the row moves. [read the
banner aloud] That one line is the whole status, and a café owner can read
it. [click **My designs** · click `Demo backup`]"

## Visualize [click **Visualize**]

"Same model in 3D. [drag once to orbit] Sun by date and time, so you can see
the shade at lunch in June. And because I rendered this one last night,
[click **Gallery**] here's what the image model makes of it: street,
sidewalk, corner, aerial, all from the same geometry. [click one render ·
hold two seconds · close] The tool never holds a key of mine; each person
adds their own in Settings, and on this hosted copy it's off, so these were
made with the local server."

## Export [click **Export**]

"Two packages come out of one model. The schematic one is for showing people:
the axo, these renders, a Rhino model. This is the technical one. [tick
**Technical** under Report · click **↓ Download report (PDF)** · open it] Cover. [page 2] One page that says exactly what
to measure and what fails. [scroll] Plan, sections, a compliance table with
the Manual page for every check, and a sources sheet. That is what you bring
to the City's pre-application meeting."

## Close [Alt-Tab to the slide]

"It's open. Go break it, and send me the reviews as GitHub issues. Thanks."

---

## Fallbacks
- **Import hangs past 15 s:** "That's the one network step." **My designs**
  → `Demo backup` → Generate. You lose the gate, keep everything else.
- **Signed out at the start:** don't sign in on stage. Do the fresh-design
  half signed out: there is no "Work offline" button (signed out, the app
  goes to the landing page), so type
  `jennabruggeman.github.io/curbside/parklet-checker.html?offline` into the
  address bar (have it bookmarked); for the backup half, play the MP4 from
  Generate.
- **Anything else:** Alt-Tab to the MP4, space, talk over it.
- **Blank projector:** Win+P → Duplicate.

## Cuts if over 4:30, in order
the GLB/IFC sentence → the provisional-row click → the orbit → the second
return to the fresh design (instead, on `Demo backup`, clear one Check value
and re-enter it). Never cut the Generate refusal, C02, or the Gallery.

## Rehearsal log
| Run | When | Build | Time | Stumbled at | Fix |
|---|---|---|---|---|---|
| 1 | Thu eve | v0.14 | | | |
| 2 | Thu eve | v0.14 | | | |
| 3 | Fri 7 am | live | | | |

## Agent rehearsal (Brief 23 persona "Demo")
Follow every [bracketed] action in order on the live site, using the test
account's `Demo backup` where the script does. For each: expected state
seen (y/n), seconds to appear, screenshot path. Stop at the first mismatch
after 15 s and report it with the console log. Two runs, second with a
different fresh address. Fix nothing.
