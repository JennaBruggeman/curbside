# Curbside

**Use it: <https://jennabruggeman.github.io/curbside/>** · [a sample report](https://jennabruggeman.github.io/curbside/demo/sample-technical.pdf) (the technical set, PDF; no account needed)

Schematic parklet design for Vancouver streets. Draw a parklet on a real street, check it live against the
Vancouver Parklet Manual and the Engineering Design Manual, furnish it, see it in plan, section and 3D, and
export a drawing set.

## Purpose

Curbside is a schematic design and compliance tool that helps turn an idea for a Vancouver parklet into a site-specific, reviewable proposal. Designed for anyone who might initiate a parklet, from a café owner to a designer preparing a first sketch, it builds the street from the address using City open data, OpenStreetMap and TransLink, incorporating lanes, bike routes, transit stops, hydrants, trees and buildings. Users can generate and refine furnished layouts according to their priorities, such as seating, planting or shade, while the Parklet Manual's clearance and access requirements are checked throughout. Each value is identified as measured, imported or estimated; only a measured value settles a check (an estimate or imported data gives a provisional result), and a survey sheet lists what must still be measured on site. From one model, Curbside produces both a schematic package for communicating the proposal and a technical package documenting compliance, assumptions and sources for pre-application review.

## How to use it

Curbside runs in the browser at the link above. Nothing to install. Button and step names below are shown *in italics* exactly as they appear on screen.

**Before you start.** Open the link above; the landing page explains the steps, and *Try the sample report* opens a finished technical report (no account needed). Click *Sign in* or *Create account* (during the class review, until 9 October 2026, sign-up asks for no invite code), or *Try without an account* to work in this browser only. Every change saves itself; *Save* saves at once; the header reads *Saved ·* and the time, or *Browser only* when signed out. Your other designs are in the account menu (*your name ▼*) › *My designs*.

The top bar is the seven steps, in working order: *1 Site · 2 Site facts · 3 Design · 4 Access · 5 Check · 6 Visualize · 7 Export*. The keys 1 to 7 go to them. Steps 3 to 7 open once every site fact has an answer.

### 1. Site

Click *Locate on map* and search an address with its house number (`2000 Main St`) or an intersection (`Main St & E 20th Ave`). Pick a result, click the street, then click the parklet's side of it, and click *Use this location*. To pick another street, click it; to change the side, click the same street on its other side.

- Without a mouse: after a search result, the streets near it are listed under the results as buttons, one per side (*Robson Street, south-west side*). Enter on one picks it.
- *Layers* on the map shows what the import will read (streets, buildings, bikeways, bus stops, hydrants, trees) and, along the curbs, *Where a parklet could go*: an estimate from City and OSM data, with the reason on hover.
- No real site? *Start a blank street* gives a generic two-way street to sketch on; its report says it is not a real location.
- If you locate a different street, side or block later, the tool asks *Replace the site data?* Replacing clears the imported data and site values; the deck and furniture stay.

Then click *Import street context*. The tool reads the street (lanes, direction, route type, bike lane), the buildings and the site objects (hydrants, trees, bus stops) within 150 m, from City of Vancouver open data, OpenStreetMap and TransLink, and places a 19.8 m deck at the host building's frontage. Every value shows where it came from.

### 2. Site facts

One card per fact the checks read (parking, curb to curb, lanes, route type, the distances to the intersection, hydrant, driveway, pole, signal box and manhole, the slope, connections, drainage, the boulevard, the parking setback), then one card per group of imported objects. Each card shows the value found and where it came from; confirm or change it and say how you know it: *Measured on site*, *Estimate* or *Don't know yet*. *Review site facts* in step 1 opens them again; *I've measured on site* opens them with *Measured on site* chosen, for after the site visit.

### 3. Design

Three sub-tabs at the top of the left panel: *Generate*, *Layout* and *Furniture*. Work in *Plan*, *Section* or *3D*.

- **Generate** (the quick start; Design opens on it while the deck is empty) proposes layouts from *Site constraints*, *Programme* (each use weighted 0–3), *Character and materials* and *Output*. A fact you don't know yet leaves its check *Awaiting measurement*, not the layout. *Lock* keeps a scheme through *Regenerate*; *Open in Design* takes it into your design. The *Design assistant* below it uses your own Anthropic key.
- **Layout:** *Parklet shape editor* → *Edit the deck's shape*: type the rectangle's length and width (or drag one on the parking segment), cut any corner at 45°, *Reset to rectangle*; *Apply*. *Edge*: choose *Traffic side*, *Start end* or *Far end*, then an enclosure type, its *Height*, *Buffer* and *Material*. *Materials* sets the deck, the edge and the furniture finishes.
- **Furniture:** the library. *Place on deck* on a card, then click a spot on the deck (Enter places it at the centre; Esc cancels), or drag a card onto the deck in the Plan or 3D. Drag a placed piece to move it; it never leaves the deck. *Import 3D model…* adds your own (GLB, glTF or OBJ) to *My furniture*.
- **Street:** in the *Section*, drag a chip from *Add segment* into the section; click a width to type it (a decimal comma and m, cm or mm are fine). A typed width counts as an estimate until you mark it measured in *Site facts*.
- **Undo:** Ctrl+Z works in the Section and in the shape editor.

### 4. Access

A 1.5 m clear route from each entry to an accessible seat (a bench end, or a table 0.70–0.80 m high). Drag a piece on the Plan and the route follows; a pinch is dimensioned across the narrow point, with the piece in the way named.

### 5. Check

The verdict in one sentence with one next step and the count by result, then every check as a card, grouped under *Fails*, *Awaiting measurement*, *Not entered*, *Provisional pass*, *Pass* and *Advisory*. A card shows its rule, its result and the value with how it is known; open it (click, or Enter) for the rule in plain words, the Manual page (a link that opens it), how the result was found and the fix. Esc closes it. Every result says how it is known: *Pass (measured)* on a site measurement, *Pass (design)* where only the design is read, *Provisional pass (estimate)* or *(imported)* until it is measured, *Awaiting measurement* while a fact is not known.

- **Change a value:** open the card and click *Change* next to the fact: the same inputs as its Site facts card open in it. Change the value and how you know it, then *Save*; the check runs again and the card moves to its new group.
- **See it on the drawing:** *Show me in the Plan ›* in any open card. A check read from the design alone (C14, C16 to C19) has *Go to Design ›*.
- **Measure on site:** the report's S-002 lists every site fact with its value now, how it is known and a blank column for the measurement.

### 6. Visualize

The parklet in 3D, with the sun at any date and time. Photoreal renders are optional and use your own Replicate key and the local server (`tools/start.cmd`).

### 7. Export

In *Report*, choose *Schematic* (colour, renders on the title sheet) or *Technical* (line and hatch, no images), tick what to *Include*, and click *Download report (PDF)*. Page two is *What to do next*. *Accessible route (A-104)* adds the route sheet; it is printed anyway when C16 fails. Sheet scales are the largest of 1:20, 1:25, 1:50, 1:75, 1:100, 1:200 and 1:250 that fits.

*Cost estimate* (beside *Report*) prices the design as a range from a stated rate set: *Vancouver indicative 2026* by default, each rate with its source and date, and a line without a checkable source shown as *—* and counted. *Download (.xlsx)* gives the same estimate as a workbook with live formulas. *More formats* holds the 3D model (*Rhino (.3dm)*, glTF, IFC, Collada, STL, OBJ, DXF) and the animation.

### Settings

Account menu (*Sign in ▼* or *your name ▼*) → *Settings*.

- **Connections:** your own Replicate key for photoreal renders, Anthropic key for the Design assistant, Mapillary token for street photos. Paste a key and press Enter; *Test* checks it, *Remove* deletes it. Keys live only in this browser, at this address: signing out, a new design or clearing your data keeps them; another browser, a private window, or the app at another address starts with none.
- **General**, **Units** (Metric / Imperial), **Grid & Snap**, **Project North**, **Data** (*Clear all saved data* keeps your keys).
- **Sign out** is in the account menu; it saves the open design first.

## Source

Every check cites the page of the City of Vancouver **Parklet Manual, Version 1.0 (June 2016)** it comes from;
travel lanes also use the City's **Engineering Design Manual (2026)**. The same references print on the report's
C-001 and X-001 sheets.

| Check | Requirement | Parklet Manual | Other |
|---|---|---|---|
| C01 | All-day parking permitted (no rush-hour, bus, taxi or loading zone) | p. 20 | |
| C02 | Adjacent travel lane ≥ 3.0 m (3.2 m on bus / truck routes) | p. 20 | EDM Table 8-10, §8.7.3.1, pp. 275–277 |
| C03 | ≥ 6 m from the nearest intersection or crosswalk edge | p. 20 | |
| C04 | Street running slope ≤ 5 % | p. 20 | |
| C05 | ≥ 5 m either side of a fire hydrant | p. 21 | Standard Detail Drawing W4.1 |
| C06 | ≥ 1.5 m from an adjacent driveway or lane | P2, p. 62 | |
| C07 | ≥ 1 m from poles (2.4 m with trolley wires) | p. 21 | Standard Detail Drawing E5.19C |
| C08 | ≥ 2 m from signal controller boxes and electrical kiosks | p. 21 | Standard Detail Drawing E1.3 |
| C09 | ≥ 1 m from manhole lids, valves, grates, access chambers | p. 21 | Standard Detail Drawing WW1 |
| C10 | Fire department and utility connections and fire exits not blocked | p. 21 | |
| C11 | Curb and roadside drainage maintained | p. 21 | |
| C12 | Pedestrian clearances on the boulevard / utility strip maintained | p. 20 | |
| C13 | ≥ 1.5 m from adjacent parking spaces | p. 62 | |
| C14 | Deck flush with the sidewalk (gap ≤ 12 mm, connector ≤ 13 mm) | p. 62 | |
| C15 | Deck load capacity ≥ 7.2 kPa | p. 62 | |
| C16 | Accessible route 1.5 m clear from the sidewalk to an accessible seat; a 1.5 m turning area | G19, p. 60 | |
| C17 | Enclosure 0.75–1.0 m high on the traffic side and both ends | E2, p. 64 | |
| C18 | At least two unobstructed openings of 1.8 m or more to the sidewalk | E3, p. 65 | |
| C19 | Overhead elements ≥ 2.1 m clear above the deck and within the footprint | E5, p. 65 | |

Section numbers for C01–C15 are still to be added from the Manual (the app records their pages). C16 follows the Manual's
G19 (p. 60), 1.5 m, not the BC Building Code's 1.1 m route. Bike lane and buffer widths follow EDM §8.5.4.5. Site data comes from City of Vancouver Open
Data, OpenStreetMap (© OpenStreetMap contributors, ODbL) and TransLink's GTFS feed, prepared weekly in 1 km cells by
[curbside-data](https://github.com/JennaBruggeman/curbside-data); the report's X-001 lists each dataset and the date
of its data.

## One example

![A 90-second walkthrough of Curbside on the live site, with captions](demo/walkthrough.gif)

Ninety seconds on the live site, captions and no sound ([MP4](demo/walkthrough.mp4)): Main Street at East 26th Avenue
located and imported, the curb-to-curb estimate, Generate refusing until the site facts are set; a saved design (West
Georgia Street) opened from My designs, generated and opened in Design; one Check value saved; the technical report
downloaded and paged through: cover, What to do next, layout plan, deck plan, both sections, C-001 and sources.

## Skill and limits

- **Schematic, not construction.** The drawings are for the Parklet Manual pre-application; no structural or
  construction feasibility is assessed.
- **Imported data is a starting point.** Street facts, buildings and site objects come from City open data and
  OpenStreetMap. Curb-to-curb width is an estimate to measure; a result that rests on an estimate or imported data stays
  *provisional* until you mark the fact measured in *Site facts*.
- **Checks need inputs.** A check whose value is neither imported nor entered reports *not entered*, never a pass.
- **Vancouver only**, and a browser with WebGL: a desktop or laptop, or a tablet (taps and one-finger drags work).
- **Open a design in one tab at a time.** Two tabs (or two browsers) on the same design do not merge: the one that saves
  second is asked first whether to reload the newer version or overwrite it.
- **Photoreal renders and the Design Assistant use the visitor's own keys** (Replicate, Anthropic), entered in
  Settings › Connections and kept only in that browser. The site ships with none.
- **The render relay is absent on the Pages build.** Photoreal renders go through the relay in `tools/serve.ps1`,
  which only exists when you run the app locally; on the hosted site Visualize says so, and everything else works.
- Site data is rebuilt weekly, so it can be a week behind OpenStreetMap. **live** in the Layers tab refreshes an
  OpenStreetMap layer on the map; the site's values change at the next import. Outside the City of Vancouver there is
  no site data: the import then runs on estimates.

---

## Run it locally

1. Clone the repository.
2. Windows: double-click `tools\start.cmd`. It starts the local server (`tools/serve.ps1`, PowerShell 5.1, no
   other install) on <http://localhost:8766/> and opens the landing page. `tools\stop.cmd` stops it.
   Any static web server also works for everything except photoreal renders, which go through the relay in
   `tools/serve.ps1`.
3. Enable the repository's pre-push check once: `git config core.hooksPath tools/hooks` (it refuses PDF, DWG
   and ZIP files and anything over 5 MB; the exceptions are the two sample reports below and the README's walkthrough clip,
   `demo/walkthrough.gif` and `.mp4`, which may be up to 10 MB).

## Developer prerequisites

Running the app needs none of this. The developer scripts in `tools/` (the landing-page screenshots and the city
data build) need:

- **Node.js 24 LTS or later** — <https://nodejs.org/> (the Windows installer, or the portable `win-x64` zip).
  Check with `node --version`.
- **Playwright 1.63.0** (pinned in `tools/package.json`) and its Chromium:

  ```
  cd tools
  npm install
  npx playwright install chromium
  ```

  `npm install` fetches Playwright into `tools/node_modules` (git-ignored); the second command downloads its
  Chromium, headless shell and ffmpeg (for recorded video) into Playwright's user cache, about 150 MB.

`node tools/screenshots.js` redraws the landing images from the recorded site data in `tools/fixtures/`
(`--record` fetches it again).

`node tools/build-sample-pdfs.js` rebuilds the two sample reports (`demo/sample-schematic.pdf` and
`demo/sample-technical.pdf`, with their counts in the matching `.json`) from `demo/sample-design.json`, with the
local server running. Run it after any change to the report or to the sample design: `sample.html` shows these files
as they are (without them it builds the sample in the browser, which takes several seconds).

`node tools/bump-version.js v0.17` bumps the version in one step, with the local server running. It sets the
sheets' stamp in `parklet-checker.html` and the landing page's version, then rebuilds both sample reports at that
version. The pre-push hook refuses a push whose sample reports carry a different version from the app.

## Add your keys (optional)

Settings (account menu) › **Connections**. Each row has a key field, **Test** (one free call that says whether
the key works) and **Remove**. Keys are stored only in this browser, never sent to Curbside's servers and never
saved with a design, an export or a log.

| Service | Used for | Get a key | Pricing |
|---|---|---|---|
| Replicate | Photoreal renders (Visualize › Photoreal; local server only) | <https://replicate.com/account/api-tokens> | <https://replicate.com/pricing> |
| Anthropic | The Design Assistant; reading furniture cut sheets | <https://console.anthropic.com/settings/keys> | <https://www.anthropic.com/pricing#api> |
| Mapillary | Street context photos for renders | <https://www.mapillary.com/dashboard/developers> | free |

Without a key the feature says so and links to Connections; everything else works.

How the keys travel: the Anthropic key goes from the browser straight to Anthropic. The Replicate key is sent
with each render request to the local relay (`tools/serve.ps1`), which forwards it to Replicate for that one
request; the relay never stores or logs keys, headers or bodies, and only calls the models on its allow-list.

## Your own backend

Accounts and saved designs use [Supabase](https://supabase.com). To run your own copy without touching anyone
else's data:

1. Create a free Supabase project.
2. In its SQL Editor, run [`supabase/schema.sql`](supabase/schema.sql). It creates the `profiles` and `designs`
   tables, turns on Row Level Security for every table (each user reads and writes only their own rows; a
   signed-out request reads nothing), the invite check, and the private `user-furniture` and `design-renders` storage
   buckets (one folder per user: your imported furniture, and each design's render gallery).
3. Run [`supabase/invite-codes.sql`](supabase/invite-codes.sql) for one invite code per person (see below), and
   [`supabase/invite-status.sql`](supabase/invite-status.sql) if your database was set up before it was part of `schema.sql`.
4. Project Settings › API: copy the **Project URL** and the **anon / publishable key** into the `CONFIG` block at
   the top of `parklet-checker.html`. Only the anon key belongs there — never the service-role key or a
   database password.
5. Authentication › URL Configuration: set the Site URL to your site's address and add it to the Redirect URLs.

### Invite-only sign-up

Sign-up asks for an invite code, checked by the database when the account is created (never in the page). With
`invite-codes.sql`, each code has a label, a number of uses (one by default) and an optional expiry:

```sql
insert into public.invite_codes (code, label, expires_at)
select upper(encode(gen_random_bytes(5), 'hex')), 'Reviewer ' || g, now() + interval '30 days'
from generate_series(1, 3) g
returning code, label, expires_at;                                  -- three codes, one account each

select code, label, uses, last_used_at from public.invite_codes;    -- which were used
update public.app_settings set invite_only = false;                 -- open sign-up to anyone
```

The landing page's "invite code required" line and the sign-up form's code field follow `app_settings.invite_only`, read
through `public.signup_invite_only()` (`invite-status.sql`: the yes / no flag only, never the code), so the one-line
toggle above is all it takes. `CONFIG.INVITE_ONLY` is only the form's fallback when that function cannot be reached. Set
`CONFIG.INVITE_CONTACT` to whoever hands out codes. Existing accounts are never affected.

## Repository

- `parklet-checker.html` — the app (one file). `index.html` — the landing page (the site's root).
- `tools/` — the local server and relay, start/stop scripts, bundled report libraries (`tools/vendor`), the
  pre-push check (`tools/hooks`), and the Node developer scripts (`tools/package.json`).
- `supabase/` — the database and its security policies; the invite codes.
- `demo/` — the sample design and its renders (rendered with the author's Replicate account).
- `docs/landing/` — the landing page's images; `tools/fixtures/` — the site data they are drawn from;
  `tools/test/gis-fixtures/` — the site data cells for offline checks (`?gis=fixtures`).
- `briefs/` — the design briefs. `docs/process/` — the handoff notes and the stranger-test triage.
- `docs/` — also `THIRD_PARTY.md`, the furniture library page and reference images; `tools/rhino-web-control/` — a
  Rhino web-control experiment.

Third-party reference documents (the City's manuals and drawings, manufacturer catalogues, precedent images)
are not in this repository: keep local copies in `reference/`, which is git-ignored.

## Licence

MIT (see [`LICENSE`](LICENSE)). Third-party components and data: [`docs/THIRD_PARTY.md`](docs/THIRD_PARTY.md).
