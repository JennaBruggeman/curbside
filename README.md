# Curbside

Schematic parklet design for Vancouver streets. Draw a parklet on a real street, check it live against the
Vancouver Parklet Manual and the Engineering Design Manual, furnish it, see it in plan, section and 3D, and
export a drawing set.

The code is public; **nothing in this repository or the deployed site holds a key.** Every paid service is the
user's own account, entered by them and stored only in their browser.

## Run it

1. Clone the repository.
2. Windows: double-click `tools\start.cmd`. It starts the local server (`tools/serve.ps1`, PowerShell 5.1, no
   other install) on <http://localhost:8766/> and opens the landing page. `tools\stop.cmd` stops it.
   Any static web server also works for everything except photoreal renders, which go through the relay in
   `tools/serve.ps1`.
3. Open the app, sign in (or use it signed out: designs are then kept in this browser).

## Developer prerequisites

Running the app needs none of this. The developer scripts in `tools/` (the landing-page screenshots, the demo
walkthrough, the city data build) need:

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

## Add your keys (optional)

Settings (account menu) › **Connections**. Each row has a key field, **Test** (one free call that says whether
the key works) and **Remove**. Keys are stored only in this browser, never sent to Curbside's servers and never
saved with a design, an export or a log.

| Service | Used for | Get a key | Pricing |
|---|---|---|---|
| Replicate | Photoreal renders (Visualize › Photoreal) | <https://replicate.com/account/api-tokens> | <https://replicate.com/pricing> |
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
   signed-out request reads nothing), the invite-code check, and the private `user-furniture` storage bucket.
3. Project Settings › API: copy the **Project URL** and the **anon / publishable key** into the `CONFIG` block at
   the top of `parklet-checker.html`. Only the anon key belongs there — never the service-role key or a
   database password.
4. Authentication › URL Configuration: add your site's address.

### Invite-only sign-up

Sign-up asks for an invite code, checked by the database when the account is created (never in the page):

```sql
update public.app_settings set invite_code = 'your-code-here';   -- set the code
update public.app_settings set invite_only = false;              -- open sign-up to anyone
```

When you open sign-up, also set `CONFIG.INVITE_ONLY = false` so the form stops asking for a code, and set
`CONFIG.INVITE_CONTACT` to whoever hands out codes. Existing accounts are never affected.

## Repository

- `parklet-checker.html` — the app (one file). `index.html` — the landing page.
- `tools/` — the local server and relay, start/stop scripts, bundled report libraries (`tools/vendor`), and the
  Node developer scripts (`tools/package.json`; see Developer prerequisites).
- `supabase/schema.sql` — the database, with its security policies.
- `demo/` — the sample design and its renders (rendered with the author's Replicate account).

Before publishing: the reference PDFs and images in the root (the City of Vancouver manuals and drawings,
manufacturer catalogues, precedent images) are third-party documents kept here for development; remove them
from the public repository (and its history) unless you have the right to redistribute them.

## Licence

MIT (see [`LICENSE`](LICENSE)). Third-party components and data: [`THIRD_PARTY.md`](THIRD_PARTY.md).
