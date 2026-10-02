# Curbside

**Use it: <https://jennabruggeman.github.io/curbside/>** · [a sample report](https://jennabruggeman.github.io/curbside/demo/sample-technical.pdf) (the technical set, PDF; no account needed)

Schematic parklet design for Vancouver streets. Draw a parklet on a real street, check it live against the
Vancouver Parklet Manual and the Engineering Design Manual, furnish it, see it in plan, section and 3D, and
export a drawing set.

## Purpose

Curbside is a schematic design and compliance tool that helps turn an idea for a Vancouver parklet into a site-specific, reviewable proposal. Designed for anyone who might initiate a parklet, from a café owner to a designer preparing a first sketch, it builds the street from the address using City open data, OpenStreetMap and TransLink, incorporating lanes, bike routes, transit stops, hydrants, trees and buildings. Users can generate and refine furnished layouts according to their priorities, such as seating, planting or shade, while the Parklet Manual's clearance and access requirements are checked throughout. Each value is identified as measured, imported or estimated; estimates cannot satisfy compliance checks, and a survey sheet lists what must still be verified on site. From one model, Curbside produces both a schematic package for communicating the proposal and a technical package documenting compliance, assumptions and sources for pre-application review.

## How to use it

1. **Open** the site at the link above. *Try the sample report* opens a finished technical report without an account.
2. **Sign in** with *Sign in*, or *Create account* (no invite code during the class review, until 9 October 2026).
   Your most recent design opens.
   - *My designs* in the account menu (your name ▼) lists the others: *Open*, *Rename*, *Delete*.
   - Every change saves itself; *Save* saves at once. The bar says *Saved ·* and the time, or signed out,
     *Browser only*.
3. **Choose a site.** *Locate on map*, search an address with its house number or an intersection, pick a result,
   click the street, then click the parklet's side, and *Use this location*. Or *Start a blank street*.
   - *Layers* on the map shows what the import will read.
   - Locating another street, side or block later asks *Replace the site data?*; the deck and furniture stay.
4. **Import.** *Import street context* reads the street, buildings, hydrants, trees and stops within 150 m and
   places a 19.8 m deck at the host's frontage (*Place parklet*). Each value shows its source (*imported*,
   *estimate*); *Edit* on a step changes it.
5. **Design** in the *Design* tab, in *Plan*, *Section* or *3D*.
   - *Add a piece:* in the *Furniture* tab, *Place on deck* on a card, then click a spot on the deck (Enter places it
     at the centre; Esc cancels).
   - *Move a piece:* drag it on the Plan; it never leaves the deck, and the edge it meets flashes. Or use the
     *Move* arrows (0.25 m steps), the arrow keys, or *Across* / *Along* and *Apply*. *Duplicate* and *Delete* are
     under *Actions*.
   - *Import 3D model…* (Furniture tab or library) → *Choose a file…* (GLB, glTF or OBJ) → *Add to My furniture*:
     it joins the library, in this browser.
   - *Parklet shape editor* → *Edit the deck's shape*: *Rectangle*, *Polygon*, *Edit*, *Notch* or *Reset to
     rectangle*, then *Apply* (*Cancel* discards).
   - *Edge*: choose *Traffic side*, *Start end* or *Far end*, then an enclosure (*Steel picket*, *Planter wall* …),
     its *Height*, *Buffer* and *Material*.
   - *Section*: drag a chip from *Add segment* (*Bike Lane*, *Planting* …) into the section; it is refused, with the
     reason, when the roadway has no room. Click a width to type it: a typed width counts as
     measured.
   - *Undo* (Ctrl+Z) works in the Section and in the shape editor. A furniture move has no undo: move it back.
   - *Generate* proposes layouts from *Site constraints*, *Programme* (each use weighted 0–3), *Character and
     materials* and *Output* (*Schemes*, *Seed*). If a site fact is missing it says *Set these site facts first*,
     with a link to the first one; the button stays. *Lock* keeps a scheme through *Regenerate*; *Open in Design*
     takes it.
6. **Accessibility.** The *Access* tab checks a 1.5 m clear route from each entry to an accessible seat (a bench end,
   or a table 0.70–0.80 m high); drag a piece on the Plan and the route follows.
7. **Check.** The *Check* tab gives the verdict and its next step, then every check under *Fails*, *Awaiting
   measurement*, *Not entered*, *Provisional pass* and *Pass*. A check passes only on measured or confirmed values;
   imported data gives a provisional result, and estimates never pass.
   - *Enter a value:* open a group, open the row, type it (*Not saved yet: Save (or Enter) keeps it, Esc discards
     it*) and *Save*; the row moves.
   - *Confirm imported items* opens a list: *Confirm* per group, or *Confirm all visible*.
   - *Show me in the Plan ›* in an open row shows where the check applies.
   - Site › *Survey (optional)* › *Survey template (CSV)*: fill its measured column, then *Import filled template…*.
8. **Export.** In *Report*, choose *Schematic* (colour, renders on the title sheet) or *Technical* (line and hatch,
   no images), tick what to *Include*, and *Download report (PDF)*: a few seconds.
   - *3D Model*: *Rhino (.3dm)* (or glTF, IFC, Collada, STL, OBJ, DXF), then *Export 3D Model*.
9. **Settings**, from the account menu (*Sign in ▼* or your name ▼) → *Settings*.
   - *Connections*: your own Replicate key for photoreal renders, Anthropic key for the Design Assistant, Mapillary
     token for street context photos. Paste it and press Enter; *Test* checks it, *Remove* deletes it. Keys are stored only
     in this browser, never sent to Curbside's servers or saved with your design. On the hosted copy renders also
     need the local server (`tools/start.cmd`); *how?* beside *Render (photoreal, 4 presets)* says so.
   - *General* (name, email, organization, in this browser), *Units* (*Metric* / *Imperial*), *Grid & Snap*,
     *Project North* (*Set in Site*), *Data* (*Clear all saved data*).
   - *Sign out* is in the account menu; it saves the open design first.

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

Commercial Drive at East 1st Avenue, east side (the images are made by `tools/screenshots.js`; the landing page
shows them too).

| | |
|---|---|
| ![Choosing the site on the map](landing/how-1-site.png) | ![The seeded parklet in plan, section and 3D](landing/how-2-seed.png) |
| **Choose a site:** the parklet on the east side of Commercial Drive, between Graveley Street and East 1st Avenue. | **Seed the parklet:** a 19.8 × 2.65 m deck at the host frontage (Liberty Wine Merchants), with its enclosure. |
| ![The checks](landing/how-3-design.png) | ![The Export tab](landing/how-4-report.png) |
| **Design and check:** with seven pieces placed, the preliminary verdict is *does not pass*: C01 fails (a bus stop beside the deck makes it a bus zone) and C02 fails (three lanes of 3.12 m on a bus route, where 3.2 m is required); 12 checks await site measurements. | **Report:** the drawing set, with the options to include or leave out the schedule, the sources, the compliance detail and the renders. |

A recorded walkthrough of the whole journey is planned (Brief 26).

## Skill and limits

- **Schematic, not construction.** The drawings are for the Parklet Manual pre-application; no structural or
  construction feasibility is assessed.
- **Imported data is a starting point.** Street facts, buildings and site objects come from City open data and
  OpenStreetMap. Curb-to-curb width is an estimate to measure, and every imported object stays *provisional* until
  confirmed on site.
- **Checks need inputs.** A check whose value is neither imported nor entered reports *not entered*, never a pass.
- **Vancouver only**, and a desktop browser with WebGL.
- **Open a design in one tab at a time; the last save wins.** Two tabs on the same design do not merge: whichever
  saves last replaces the other's edits.
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
   and ZIP files and anything over 5 MB; the one exception is the two sample reports below).

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
- `landing/` — the landing page's images; `tools/fixtures/` — the site data they are drawn from.
- `briefs/` — the design briefs.

Third-party reference documents (the City's manuals and drawings, manufacturer catalogues, precedent images)
are not in this repository: keep local copies in `reference/`, which is git-ignored.

## Licence

MIT (see [`LICENSE`](LICENSE)). Third-party components and data: [`THIRD_PARTY.md`](THIRD_PARTY.md).
