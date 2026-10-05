# Product

<!-- impeccable:product-schema 1 -->

<!-- Written for Brief 30 §12 (commit 19) from the brief's pre-decided answers and the repository (README, landing page,
     app). No interview was held: the session ran unattended by instruction, so every line below is either stated in
     Brief 30 §12 or read from the repository, and marked where it is an inference. -->

## Platform

web

## Users

- **Café and shop owners** who want a parklet in front of their business: first-time, non-technical, deciding whether
  it is worth applying (Brief 30 §12).
- **BIA staff** (Business Improvement Areas) comparing sites and helping members prepare applications (Brief 30 §12).
- **Students** (architecture, planning) sketching and testing proposals (Brief 30 §12).
- **City reviewers** reading the exported report for the Parklet Manual pre-application; most never open the app, they
  read the PDF (Brief 30 §12; the report's audience per README).

## Product Purpose

Turn an idea for a Vancouver parklet into a site-specific, reviewable proposal: build the real street from the address
(City open data, OpenStreetMap, TransLink), design and furnish a deck on it, check it live against the City's Parklet
Manual (v1.0, 2016) and Engineering Design Manual (2026), and export a schematic package (to communicate) and a
technical package (compliance, assumptions and sources) from the one model. Success: the user knows whether the site can
work, what to measure on site, and leaves with a drawing set a reviewer can read.

## Positioning

The street is real and every number says how it is known. Each site fact is measured, an estimate, imported, or not
known yet, and that provenance decides every check result (only a measured value settles a check). One design model
drives the Plan, the Section, 3D, the generator, the checks and the report, so the drawings and the verdict cannot
disagree.

## Operating Context

- Steps: Site (locate, import) → Site facts (one card per fact, how it is known) → Design (Plan / Section / 3D, shape,
  edge, furniture, Generate) → Access → Check → Export (PDF report, 3D model). Parklets 101 is a reference, not a step.
- Used at a desk on a laptop or desktop browser; a tablet is supported for drags and taps. The S-002 sheet goes to the
  site visit on paper; the measurements come back through "I've measured on site".
- Signed in (designs in an account) or signed out (`?offline`, the design in this browser only).
- Reviewers work from the PDF: cover, What to do next, A-sheets, C-001 Compliance, S-002, X-001 Sources.

## Capabilities and Constraints

- A single-file app (`parklet-checker.html`), no build step; vanilla JS, MapLibre, three.js, jsPDF in `tools/vendor`
  (Brief 30 §12; repository).
- The drawings are governed by `DRAW_STYLE` / `DRAW_SYMBOLS` and the report engine; they are out of scope for UI work
  (Brief 30 §12).
- Vancouver only; schematic, not construction; no structural feasibility (README).
- Photoreal renders and the Design Assistant use the user's own keys (Replicate, Anthropic), stored only in the browser.
- One term per concept (Brief 21 §2): the copy uses the names the UI shows; rule IDs (C01–C19) are the only capitals.

## Brand Commitments

- Name: Curbside. Voice: plain and brief (Brief 30 §12): short sentences, the user's words, no jargon, no exclamation.
- The UI tokens in the app (one face, 12 px minimum text, mixed-case labels, rule IDs the only caps, one blue accent
  `#3AA8E4` on neutral greys) are the incumbent system; DESIGN.md records them.

## Evidence on Hand

- `demo/sample-technical.pdf`, `demo/sample-schematic.pdf`: the bundled sample reports (19 of 19 pass).
- `demo/render-*.jpg`: AI-assisted renders of the sample design (indicative; the umbrella is the older 2.5 m one).
- `demo/walkthrough.mp4` / `.gif`: a 90-second walkthrough.
- `docs/process/23-triage.md`: stranger-test findings by persona. No testimonials, customers or usage numbers exist;
  none may be invented.

## Product Principles

1. Say how every number is known; never let a guess pass.
2. One model, one answer: every view and the report read the same design.
3. The next step is always visible: what to measure, what fails, how to resolve it.
4. Plain words for a shop owner; the Manual's page for the reviewer.
5. Nothing is lost silently: refusals say why, and a change of site asks first.

## Accessibility & Inclusion

Keyboard-only and 200 % zoom users, touch tablets and forced-colours mode were tested in the stranger test (personas 5
and 7; Brief 30 §8B). Text 12 px minimum; every control reachable by keyboard; focus visible; WCAG 2.1 AA as the
working standard (inferred from the access work in Briefs 27–30, not stated as a requirement).
