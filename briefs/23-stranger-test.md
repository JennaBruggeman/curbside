# Brief 23 (v2, file edition) — Stranger test

Runs against the hosted site, https://jennabruggeman.github.io/curbside/, after
v0.11-gis. Reconstructed from the session-6 chat decisions; where the original
text had detail this file lacks, the decisions below win. Nothing is fixed during
this brief: the output is `briefs/23-triage.md`, and the fixes are Brief 25.

## Two modes

- **Smoke pass** (run first, now): parent persona and persona 1, one run each,
  Sonnet. Purpose: catch anything that would make every later run report the
  same thing. Output `23-triage.md` with a `## Smoke pass` section.
- **Full pass** (run when Jenna says): personas 1–6 on Sonnet, parent and 7–8
  on Opus; two runs per persona; a third run only if run two found something
  run one did not. Append to the same triage file under `## Full pass`.

Browsing agents use Playwright. Sign-up is open (no invite code during the review
period). Each agent creates its own account with a throwaway address of the form
`curbside-test-<persona>-<run>@example.invalid` and a generated password; record
nothing but the email in the log. Agents never enter API keys; the render and
assistant features are expected to be unavailable and that is not a defect.

## The rule for every agent

The agent knows only what is on the landing page and in README.md. It has not
read the code, the briefs, or HANDOFF.md, and it does not get hints. It works
from its persona's goal, picks its own site (not Robson & Burrard, Commercial &
1st, or W 41st & Dunbar — those are the VERIFY sites and are already known to
work), and stops when it has either a printed sheet or has been stuck for ten
minutes on one step. It records, for each step: what it expected, what it saw,
what it did next. Confusion is data; it does not retry a step more than twice.

## Personas

- **Parent** — the full journey. A café owner on a Vancouver street who has
  read nothing about parklets and wants to know whether one is allowed outside
  the shop and roughly what it would look like. Ends with the schematic PDF.
- **1** — BIA coordinator comparing two blocks on the same street; cares about
  which block passes and why.
- **2** — M.Arch student who reads the Parklet Manual references; tries to match
  each failing check to the Manual section and says whether it could.
- **3** — Landscape designer; ignores compliance at first, goes straight to
  furniture, planters and the 3D view, then discovers the checks.
- **4** — Sceptical engineer; tries to break the inputs (zero lanes, 40 m
  curb-to-curb, a site in Burnaby, a site in the middle of a park).
- **5** — Accessibility advocate; keyboard only, screen zoomed to 150 %, looks
  for the disability-related checks and whether the sheets say anything.
- **6** — Returning user; signs up, saves a design, signs out, signs back in on
  a new browser context, expects the design to be there. (Second round of §6
  is deferred to Brief 25's VERIFY.)
- **7** — Tablet user: 1024 × 768 viewport, touch events; tries the whole
  journey.
- **8** — City staff reviewer: opens a finished PDF and tries to verify three
  dimensions on the sheets against the Manual without using the app.

## What each run records (`23-triage.md`)

One block per run: persona, run number, model, site chosen, minutes to first
sheet or point of abandonment. Then three lists:

1. **Broke** — errors, blank states, actions with no response, wrong numbers
   (say which number and what the Manual implies). Include console errors.
2. **Confused** — any step where expectation and result differed, in the
   agent's own words, with what it tried next.
3. **README / landing wrong** — a step in "How to use it" that did not match
   the interface, or a term the page uses that the agent could not find.

Screenshots go in the scratchpad, not the repo; the triage file links them by
path. End the file with a **Triage** table: one row per distinct issue, columns
`issue · seen by (personas) · severity (blocks / misleads / annoys) · suggested
fix · brief` where brief is 25 unless it is a one-line README fix, which is 25
too but marked `readme`.

## Scope guard

Do not fix anything, do not re-run a persona to confirm a fix, do not touch
master. If an issue blocks every persona (nobody can sign up, the map never
loads), stop the pass, report, and wait.

## Usage

Sonnet for agents unless listed as Opus. Text report in chat, not screenshots.
