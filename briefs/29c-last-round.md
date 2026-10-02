# Brief 29c — Last round before Friday (from the v0.16 full pass)

Branch `fixes-5` from master. Ten items; nothing else. Cite the triage row.
VERIFY with real mouse drags at the demo address and the blank street. Merge
on approval, tag v0.17. Code freeze after this: anything found later is logged
for Brief 30, not fixed.

## Demo path
1. **Drag moves the wrong piece.** Hit-testing uses the drawn outline of the
   piece, not an inflated grab area; on overlap, the topmost (most recently
   selected, else most recently placed) wins and is highlighted on hover
   before the drag starts. Move arrows stay as the keyboard path.
2. **Typed values count as measured.** A width or distance the user types in
   Check, the Site survey or the Section editor is source "You" and is
   treated as measured for every check and for Generate's gate. Only
   imported-and-unconfirmed values are provisional; only tool-derived values
   are estimates. VERIFY: `Demo backup` with all survey values entered shows
   0 awaiting and Generate runs.
3. **Generate button vanishes after a refusal.** After "can't generate: site
   facts missing", the button stays, labelled "Generate", with the refusal
   reason beside it and a link to the first missing fact.
4. **Deck-edge cue.** When a drag reaches the deck edge, the edge line
   flashes solid and the piece snaps back; the amber halo alone was not seen.
5. **PDF: C-001 continuation page contradicts the C02 verdict.** One source
   for the compliance table; the second page reads from the same result as
   the first.
6. **Sample report stamped v0.14.** Rebuild the two sample PDFs on every
   version bump (hook it into the bump script) so this cannot recur.

## Data integrity (reviewers will hit these)
7. **Moving the site keeps the old site's data.** Changing street, side or
   address resets everything derived from the site — imported objects,
   facts, confirmations, hand-entered survey values — after one confirm
   ("This replaces the site data for this design"). A fresh import does the
   same. The deck and furniture stay.
8. **Section edits lost on reload.** Segment edits trigger the same save as
   furniture; persona 6 journey includes one Section edit.
9. **Report carries the search text or a neighbour's address.** The report's
   address is the host building's address from the pick, never the search
   string or the nearest OSM match; the sheet header and the design list
   read the same field.

## Note (no code)
10. HANDOFF and README "Skill and limits": "Open a design in one tab at a
    time; the last save wins." Two-tab merge is Brief 30.

## VERIFY
At the demo address, with a real mouse: drag a bench past the deck edge (snaps
back, edge flashes); drag a bench beside a planter (the bench moves); Generate
refuses on a fresh import and the button stays; enter the survey values →
0 awaiting, Generate runs; move the site to the next block → old trees and
confirmations gone, deck intact; edit one Section segment, reload, it's there;
report header shows the host address; C-001 page 2 agrees with page 1; sample
PDFs say v0.17.

## Deferred to Brief 30 (after Oct 9)
Survey template validation; the four access gaps; forced-colours states;
two-tab merge; C03 reading the map corner; everything else in the v0.16 table.
