# Curbside: handoff, session 10 (Brief 32, the second walkthrough, 2026-10-04)

## Where things stand
- **Branch `second-walkthrough`**, from `walkthrough-round`: 17 commits, one per change: the brief, 14 code changes (two of them fixes), the README and these notes. **Not merged, not pushed.**
  Master, origin, GitHub Pages, curbside-data's published cells and Supabase were not touched.
- **`parklet-checker.html`:** 2,726,358 bytes at the start, 2,762,945 at the end (+36,587).
- **Peer-review issues:** `gh issue list --state all --search "Review:"` returns none.
- **Final regression** at Robson, Commercial, Dunbar, W 4th, Main, Granville and the blank street:
  - keys 1–7 walk all seven steps;
  - a piece placed gives 0 consistency issues;
  - 2 entries each, and C18 passes;
  - buildings import (Robson 9 / 9);
  - Check shows 19–20 cards;
  - A-102 is at 1:150 or 1:200, and every bar agrees with its scale;
  - layout check: 0 overlaps, 0 outside;
  - 0 errors.
- **Data runs:** VERIFY runs read curbside-data's `friday-round` checkout, which is **local**. The §1 published check
  read the live cells (`?gis=published`), which is **published**.

## What each section did (commit, VERIFY in numbers)

### §1 The picker opens on the answer (19665f5, fe1a96f, fix e706f91) — local, and published where marked
- **Before:**
  - The map opened at zoom 16 with 699 dots, plus the buildings, streets and bikeways layers.
  - At zoom 14 there were 0 band pieces: the band started at zoom 15, and 12 cells was the limit.
  - A click on a green band picked the street only, so two clicks were needed.
  - The published build showed no band and said nothing about it.
- **After, on open:** Vancouver at zoom 14. The band is the only layer drawn: 5,749 pieces in view, 0 dots, Layers
  closed. The legend under the search box reads "could go here · excluded · measure first".
- **Robson & Burrard, in view:**

  | Zoom | Pieces: green / grey / hatched | Block faces: green / grey / hatched |
  |---|---|---|
  | 14 | 480 / 3,817 / 937 | 456 / 520 / 826 |
  | 15 | 129 / 1,346 / 409 | 121 / 121 / 360 |
  | 13.4 | — | 692 / 892 / 1,005, one tone per face (built in 9.3 ms) |

- **Hover on a grey face:** "Excluded here — Within 6 m of the corner at Alberni Street (C03)".
- **Click on a green face:** one click picks Alberni Street (way 1316288289), sets the south-west side and enables Use
  this location. The footer gets the sentence, and the pick card says "Could go here, on the estimates".
- **Grey face:** the first click picks the street, the second picks the side (south-east). The pick card gives the
  C03 reason.
- **`?gis=published` (published):** the footer says "Where a parklet could go is not in this site data yet: click a
  street, then the side of it." No legend, 0 dots at zoom 15.
- **Regression found and fixed (e706f91):**
  - The import's default ticks were derived from the map's layer defaults, so turning Buildings off on the map stopped
    buildings from importing. Robson went to 0 / 0 buildings (it was 9 / 9).
  - The import now keeps its own defaults, and the set of imported layers is the same as before, layer by layer.
  - §2's first VERIFY ran before this fix and was run again after it.

### §2 Generator: rectangles only, and say what didn't pass (4ea4e14, 74c7dff, fix b17e755)
- **The decks:**
  - 72 generated schemes at the three sites that generate (Robson, W 4th, Main; 3 seeds × 8).
  - Vertices: 4 on 31 decks, 5 on 19, 6 on 22. The only angles are 90° and 135°; 0 bad.
  - The footprints are full-length, shortened, cuts at both traffic corners, and a cut at the far end.
- **"Split":** absent from the UI, from `GEN.PATTERNS` and from the footprints, and the Deck shape control is gone. A
  saved split deck opens in the shape editor with "This shape was drawn with an older tool."
- **Robson on a bus/truck route:** "6 asked · 6 passed every check" and no toggle. Everything passes there, so this is
  the all-pass case; it is not a shortfall.
- **A shortfall:** W 4th with the Generate frontage set to z 4.90–11.86.
  - 6 asked: "6 asked · 4 passed every check · 2 failed: 2 on C16 accessible route".
  - 8 asked: 5 passed and 3 failed. "Show the schemes that didn't pass (3)" draws them, each named "Fail: C16
    accessible route".
  - The old stats line is the tooltip.
- **None passing:** frontage z 6.0–11.0 gives "6 asked · none passed · 6 failed: 6 on C16 accessible route", with the
  6 nearest misses shown at once.
- **Commercial and Dunbar:** the generator refuses both: "Parking all day = Bus zone present".

### §3 Cover camera and A-102 scale (3f1731c, d57bb99)
- **Covers:** the deck's share of the sheet width went from 0.333 (the old axon) to 0.60 at both Robson and Granville.
  The view is the Street preset's, with the host building behind and road under the title panel.
- **A-102, chosen by measuring the sheet as drawn:**
  - Robson 1:150; Commercial, Dunbar, W 4th, Main and Granville 1:200. All were 1:250.
  - Robson's drawing is 306 × 125 mm in a 340 × 216 mm area.
- **Text:** the smallest on any page is 2.0 mm. Before, it was 1.44 mm, with tags at 1.8 and the hydrant's H at
  1.875.
- **Layout check:** 0 overlaps, 0 outside at all six sites.

### §4 Entries are designed (cbcb806, 520faf8, ae961d8)
- **A fresh Robson design:**
  - Entries at z 1.40 and 18.40, each 1.8 m.
  - One sidewalk-side run from 2.30 to 17.50, so the gaps are the entries and nowhere else.
  - C18 passes.
- **Drag** the second entry to mid-deck with the mouse: it lands at z 6.00.
  - The runs become 2.30–5.10 and 6.90–19.30.
  - Routes run from 1.40 and 6.00.
  - C18 passes; consistency 0.
- **Delete** an entry with the Edge card's Remove: "✗ one entry, needs two (1.80 m at z 1.40). Fails."
- **+ Add an entry** places it at z 11.80, the clear spot nearest the middle; C16 and C18 pass.
- **An armchair in a route:**
  - 1 pinch dimension ("0.83 m · min 1.50 m").
  - 1 turning circle (at the seat).
  - 0 fills, 0 accent rectangles.
  - "F2 armchair in the way".
  - 2 entry labels, overlapping nothing. The page's one text overlap is a tree tag against the north arrow, from
    before.
  - C16 reads "0.45 m at z 3.75, beside the armchair at z 4.00".
- **20 generated schemes:** 2 entries each; 0 pieces in front of an entry; 0 on the sidewalk-side run; 0 C18 fails.
- **A design saved before:**
  - Its 3 inferred entries (z 3.30, 8.30, 16.50) become its own.
  - `entriesFrom: inferred`; the sidewalk side stays open.
  - One console line logs the conversion.

### §5 A cost estimate that lands (679a192, a0e06c6, 88f4ce1)
- **Granville design** (terrazzo deck; Corten planter walls at the ends; steel picket on the traffic and sidewalk
  sides; 6 pieces):
  - **Before:** 3 of 9 lines priced, total $6,935–11,624, "below … the real build is higher". A "Screens 0" row was
    shown.
  - **After:** 9 of 9 priced.
    - The tile reads "3 sourced · 4 indicative · 2 proxy; 6 furniture pieces awaiting a quote".
    - The total is $52,855 – $80,885: "within the Parklet Manual's typical range for 4 parking spaces ($40,000 –
      $60,000)".
- **Deck to cedar:** the decking row becomes sourced (proxies 2 → 1). The total is $35,882 – $61,650.
- **Steel picket on every side, softwood deck:** 0 proxy rows; $33,992 – $60,108.
- **Planter walls on every side:** the posts row is absent, and there are 0 zero-quantity rows.
- **Workbook:**
  - 36 formulas, 0 #REF, 0 that disagree when recomputed.
  - Its total equals the screen: $52,855.17 / $80,885.03.
  - Quantities: 14 rows, none zero. Rates: 20 rows, each with its basis.

**Rate sources** (read 2026-10-04):

| Line | Rate (CAD) | Tag | Basis |
|---|---|---|---|
| Decking, softwood | $23.42–26.30 / m² | sourced | Turkstra $12.38 to Kent $13.90 per 12 ft board, 0.5285 m² a board |
| Decking, cedar / thermowood | $53.49–53.89 / m² | sourced | BMR 14 ft $32.98; RONA 12 ft $28.48 |
| Decking, hardwood (ipe) | $294.02–316.73 / m² | sourced | Patio Etc. Clôture Nationale $12.95–13.95 a linear foot |
| Decking, composite | $55.17–74.93 / m² | sourced | Home Depot Canada Trex $29.16; Patio Etc. $39.60 |
| **Decking, mineral** (terrazzo, concrete, granite, fibre cement) | $294.02–316.73 / m² | proxy | priced as hardwood decking |
| **Joists, pressure-treated 2 x 6** | $5.16–5.60 / m | sourced | 2 x 6 x 12 ft: RONA $18.88, Kent from $20.48. Read from search listings: the product pages refuse automated reads |
| **Levelling pedestals, adjustable** | $18.14–25.87 each | sourced | Bison Versadjust V1–V4 at DeckMart, Vaughan ON (sale to regular; Level.It $21.12) |
| **Deck installation labour** | $208.60–387.39 / m² | indicative | derived: Decksforlife (23 Feb 2026) pressure-treated installed at $30–50 / sq ft ($323–538 / m²), less this set's own materials per m² ($114–151) |
| Edge, steel picket, installed | $229.66–426.50 / m | indicative | Builders Ontario 2026 $70–130 / ft; DecksForLife $83–120 |
| Edge, horizontal cable, installed | $196.85–820.20 / m | indicative | $60–150 / ft (Builders Ontario); $180–250 (DecksForLife) |
| Edge, timber slats or boards, installed | $98.42–246.06 / m | indicative | $30–75 / ft (Builders Ontario) |
| Edge, glass, installed | $492.12–984.24 / m | indicative | $150–300 / ft |
| **Edge, perforated panel** | $229.66–426.50 / m | proxy | priced as picket railing |
| **Edge, bench back** | $98.42–246.06 / m | proxy | priced as wood railing |
| **Planter wall** | $229.66–426.50 / m | proxy | priced as picket railing |
| **Screens / knee wall** | $98.42–246.06 / m | proxy | priced as wood railing |
| Planter soil | $82.21–95.92 / m³ | sourced | Arts Nursery $44 a scoop of 60–70 % of a cubic yard |
| **Design and permit drawings** | 8–12 % of the build lines | indicative | the brief's allowance; no published Vancouver figure |
| Contingency | 20 % | indicative | NerdWallet Canada, Feb 2026 |

Bold rows are new or changed in this brief.

## Decisions I made
- **§1:**
  - The dot layers (stops, hydrants, trees) stay on but draw from zoom 16. Buildings, streets and bikeways are off by
    default; the streets' data still loads for the pick.
  - A new layer-toggle storage key, so the base state reaches everyone once.
  - The band has its own cell budget, 48 cells, beyond the heavy layers' 12.
  - A block face's tone is its best piece's.
  - The map opens on Vancouver at zoom 14, or at the site at zoom 16 when there is one.
  - The zoom chip shows on the map only while Layers is open.
- **§2:**
  - The variants are full-length, shortened, cuts at both traffic corners (0.6 m legs), and a cut at the far end.
  - A miss is a rejected candidate that was built and run through the real checks (layout rejects included), fewest
    failing checks first.
  - The envelope joined the tooltip.
- **§3:**
  - The Street preset rather than Corner, which looks along the deck almost end-on.
  - 1:150 added to the ladder.
  - The measured fit applies to A-101, A-102 and A-202. A-103 keeps its own fit and split; A-201 stays at 1:100.
  - A-102's C03 run is cropped 8 m past the setback; a longer measured distance is dimensioned to the crop's edge.
- **§4:**
  - Entries live with the enclosure (`ENCLOSURE.entries`), read as `DESIGN_MODEL.parklet.entries`.
  - The sidewalk-side enclosure defaults to steel picket.
  - A design saved before keeps its sidewalk side open, so its geometry doesn't change.
  - Its old entries become its own once its pieces load.
  - Generated pieces are kept 0.1 m clear of each entry's span.
  - The duplicate turning circle at each seat was removed.
- **§5:**
  - No Canadian source states the labour share, so deck labour is derived (the installed range less this set's own
    materials) and tagged indicative, saying so.
  - Edge labour stays inside the installed edge rates, labelled "installed", not on a second line that would count it
    twice.
  - The design allowance applies to the build lines; the contingency applies to build, furniture and design.
  - City fees are tagged sourced (the Manual's 2016 figures).
  - Furniture: a suggested price is indicative, a quote is user.

## Needs Jenna
- **§5 rates:**
  - Confirm the proxies.
  - Supply a Vancouver deck labour rate if you have one; the derived one is a residual.
  - Confirm the pedestal rule: every 0.6 m across each joist at 0.40 m gives 200 for a 19.8 m deck.
  - The RONA and Kent joist prices came from search listings, because their product pages refuse automated reads.
- **§4:**
  - Is a picket on the sidewalk side the right default?
  - Should designs saved before also be enclosed on the sidewalk side?
  - The Access card's pinch (0.83 m) and C16's sentence (0.45 m) use different measures, from before; they could be
    made one.
- **§2:** Commercial & 1st and W 41st & Dunbar refuse to generate ("Bus zone present"). Is that the data, or should
  the site facts say otherwise?
- **§1:** the bands show on the live site only once curbside-data's `friday-round` is published.
- **Merge:** the branch is ready for your walkthrough. Nothing is merged or pushed.

## Working conventions (unchanged)
- Headless runs use Playwright's own timeouts and close the browser in a `finally` (`H.run`).
- A VERIFY that depends on published data runs on the published URL and says so.
- Patch scripts are written with the Write tool. A Bash heredoc turns `\b` into a backspace; it struck again this
  session.
