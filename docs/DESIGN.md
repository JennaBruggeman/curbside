---
name: Curbside
description: Schematic parklet design and compliance for Vancouver streets: a dark working chrome around light drawing sheets.
colors:
  accent: "#3AA8E4"
  app-ground: "#17191C"
  panel: "#202328"
  raise: "#2A2E34"
  rule: "#2E3338"
  text: "#F2F2F0"
  text-dim: "#9EA3A8"
  paper: "#FFFFFF"
  ink: "#1A1A1A"
  ink-mid: "#616161"
  paper-rule: "#D8D8D8"
  paper-tint: "#F1F1F1"
  pass: "#4CB87A"
  fail: "#F07070"
  warn: "#D69A1E"
  pass-ink: "#23704A"
  fail-ink: "#B42C2C"
  warn-ink: "#8A5A00"
typography:
  title:
    fontFamily: "DM Sans, Inter, Helvetica Neue, Arial, sans-serif"
    fontSize: "18px"
    fontWeight: 600
    lineHeight: 1.3
  heading:
    fontFamily: "DM Sans, Inter, Helvetica Neue, Arial, sans-serif"
    fontSize: "15px"
    fontWeight: 600
    lineHeight: 1.35
  body:
    fontFamily: "DM Sans, Inter, Helvetica Neue, Arial, sans-serif"
    fontSize: "13px"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "DM Sans, Inter, Helvetica Neue, Arial, sans-serif"
    fontSize: "12px"
    fontWeight: 500
    lineHeight: 1.35
  numeric:
    fontFamily: "ui-monospace, SF Mono, Cascadia Mono, Consolas, monospace"
    fontSize: "12px"
    fontWeight: 400
rounded:
  sm: "3px"
  md: "4px"
  pill: "12px"
spacing:
  "1": "4px"
  "2": "8px"
  "3": "12px"
  "4": "16px"
  "6": "24px"
components:
  button-primary:
    backgroundColor: "{colors.accent}"
    textColor: "#0E1114"
    rounded: "{rounded.md}"
    padding: "8px 16px"
  button-secondary:
    backgroundColor: "transparent"
    textColor: "{colors.text}"
    rounded: "{rounded.md}"
    padding: "6px 12px"
  tab:
    backgroundColor: "transparent"
    textColor: "{colors.text-dim}"
    height: "40px"
  tab-active:
    textColor: "{colors.text}"
  input-dark:
    backgroundColor: "{colors.app-ground}"
    textColor: "{colors.text}"
    rounded: "{rounded.sm}"
    padding: "6px 8px"
  badge-pass:
    backgroundColor: "#EEF6F0"
    textColor: "{colors.pass-ink}"
    rounded: "{rounded.sm}"
---

# Design System: Curbside

## Overview

**Creative North Star: "The Drafting Table"**

Curbside is a working tool on a dark bench with the drawings laid out on paper in the middle of it. The chrome (top bar,
step strip, left panel, status bar) is a quiet dark grey that steps back; the Plan, the Section, the report sheets and the
Check table are light paper with ink linework, because those are what the user and the City read. Colour is information,
never decoration: one blue marks what is selected, focused or the primary action; three status colours say pass, fail and
wait; everything else is grey.

The density is that of a desktop CAD or GIS tool: compact rows, small type, many controls in reach, but every text at
least 12 px and every control at least 24 px (36 px for the main actions). The voice of the interface is the product's:
plain words, the names the screen shows, rule IDs as the only capitals.

The drawings themselves (the canvases and the sheets, governed by `DRAW_STYLE`, `DRAW_SYMBOLS`, the renderers and the
report engine) have their own system and are out of scope here.

**Key Characteristics:**
- Dark chrome, light drawings; the paper is the hero.
- One accent, used sparingly: selection, focus, primary action.
- Status colour only where a result is stated (pass / fail / awaiting / estimate).
- One face (DM Sans) at a small set of sizes; numbers in the monospace only where they are measurements.
- Mixed-case labels; no letter-spaced capitals except the rule IDs (C01–C19) and sheet numbers.

## Colors

A neutral dark-grey chrome and a neutral paper, with a single blue and three status hues.

### Primary
- **Survey Blue** (#3AA8E4): the one accent. The active tab's underline, the current step, a selected list item or
  segment, focus rings, the primary button. 6.9:1 on the panel grey, so it may also be text.

### Neutral
- **Bench Black** (#17191C): the app ground and the inputs on the dark chrome.
- **Panel Grey** (#202328): the top bar, the step strip, the left panel, dialogs.
- **Raised Grey** (#2A2E34): hover on dark rows and buttons.
- **Hairline** (#2E3338): 1 px rules between dark regions; outlines of secondary buttons.
- **Chalk** (#F2F2F0): text on the dark chrome (15.6:1).
- **Pencil** (#9EA3A8): secondary text on the dark chrome, the dimmest text allowed (6.9:1).
- **Sheet White** (#FFFFFF), **Ink** (#1A1A1A), **Graphite** (#616161), **Light Rule** (#D8D8D8), **Tint** (#F1F1F1): the
  paper side (the Check table, report previews, dialogs that hold a drawing).

### Status
- **Pass** (#4CB87A on dark, #23704A on paper), **Fail** (#F07070 / #B42C2C), **Wait** (#D69A1E / #8A5A00): only on a stated
  result (a badge, a verdict line, a chip saying how a fact is known).

### Named Rules
**The One Accent Rule.** Survey Blue marks selection, focus and the primary action, and nothing else. A screen with three
blue things has two too many.

**The Status Means Result Rule.** Green, red and amber appear only where a check result or a fact's standing is stated,
never to decorate a heading or a button.

## Typography

**Body Font:** DM Sans (with Inter, Helvetica Neue, Arial)
**Numeric Font:** the system monospace (ui-monospace, SF Mono, Cascadia Mono, Consolas), for measurements in readouts only

**Character:** one quiet grotesque at a few sizes; weight (500 / 600) and colour carry the hierarchy, not size jumps.

### Hierarchy
- **Title** (600, 18 px, 1.3): a step's question (Site facts), a dialog title.
- **Heading** (600, 15 px, 1.35): a panel or section heading in the workspace.
- **Body** (400, 13 px, 1.5): running text, rows, values. Long text at most 72ch.
- **Label** (500, 12 px, 1.35): field labels, tab and button text, hints, table headers, the status bar.
- **Numeric** (400, 12 px, monospace): readouts of measured values (lane widths, Along / Across).

### Named Rules
**The Twelve Pixel Floor.** No interface text is smaller than 12 px. (Drawing annotations on the canvases and sheets
follow `DRAW_STYLE`, not this rule.)

**The Mixed-Case Rule.** Labels, tabs, buttons and headings are sentence case. Capitals are reserved for rule IDs
(C01–C19), sheet numbers (A-101) and the CURBSIDE wordmark.

## Layout

A fixed application frame: the top bar (40 px), the step strip (28 px, hidden after the first export), a left panel of
270 px, the workspace filling the rest, a status bar of 28 px. The left panel scrolls on its own; a selected piece's
panel scrolls in its own box (at most half the window) so the panels below stay reachable at 200 % zoom. The tabs tighten
from 1700 px and all nine fit from 1280 px; below 1024 px the tab row scrolls inside itself as a last resort. Spacing
follows a 4 px base (4 / 8 / 12 / 16 / 24). Dialogs are centred, at most 560 px wide unless they hold a drawing.

## Elevation & Depth

Flat. Depth comes from tone (Bench Black under Panel Grey under Raised Grey on hover) and 1 px hairlines, not shadows.
The only shadows are on overlays that float over the workspace: dialogs and the confirm drawer.

**The Flat Bench Rule.** Panels and cards sit flat on the chrome; a shadow means "this floats above your work" and is
used only for dialogs and drawers.

## Shapes

Small, consistent radii: 3 px on inputs, badges and chips; 4 px on buttons and cards; 12 px pills for the step strip's
steps and segmented toggles. Square corners on the drawing panels' edges where they meet the frame.

## Components

### Buttons
- **Primary:** Survey Blue fill, near-black text (#0E1114), 4 px radius, 8 × 16 px padding, at least 36 px high in
  dialogs and steps. One per view.
- **Secondary:** transparent, Chalk text, a Hairline outline; hover Raised Grey.
- **Focus:** a 2 px Survey Blue outline, 2 px offset, on every control (`:focus-visible`).

### Tabs and the step strip
- **Tabs:** 12 px labels in Pencil, Chalk when active with a 2 px Survey Blue underline; a locked tab at 42 % opacity with
  its reason as its tooltip.
- **Steps:** numbered pills; the current one outlined in Survey Blue with its number filled.

### Inputs
- **Dark fields:** Bench Black, Chalk text, a Hairline border, 3 px radius; focus border Survey Blue.
- **Typed numbers** are text fields (decimal comma and units accepted), refused values say why in a line under them.

### Status chips and badges
- Pass / fail / awaiting badges on the Check rows; chips for how a site fact is known (measured on site, estimate, not
  known yet) in the paper status tints.

### Site facts card (signature)
- One question per card: the rule ID small, the question as a Title, the source of the value in a line with a Survey
  Blue left rule, the input, the required "How do you know it?" choice, the reason in Pencil, Back / Next.

## Do's and Don'ts

### Do:
- **Do** keep every interface text at 12 px or more, and every control's hit area at least 24 × 24 px.
- **Do** use Survey Blue only for selection, focus and the one primary action.
- **Do** write labels in sentence case with the screen's own names for things.
- **Do** say why a control is disabled (its title or a line beside it).

### Don't:
- **Don't** set letter-spaced capitals on labels or headings (only rule IDs and sheet numbers are capitals).
- **Don't** use status colours outside a stated result.
- **Don't** change the canvases or the sheets from here: `DRAW_STYLE`, `DRAW_SYMBOLS`, the renderers and the report
  engine are out of scope for UI work.
- **Don't** add shadows to panels or cards on the bench.
