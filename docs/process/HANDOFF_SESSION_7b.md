# Curbside — chat handoff, session 7b (2026-10-03)

Read docs/process/HANDOFF_SESSION_7.md first; this is the short addendum from
the end of that chat. Next chat: the post-review clean-up round (Brief 30).

## State on 3 Oct
- Repo clean, master = origin at `cfd4b63`, v0.17.2 live on Pages, hooks path
  tools/hooks, `gh` signed in as JennaBruggeman. Claude Code was reinstalled
  on 3 Oct (desktop app errors); the old session is gone, nothing else was.
- HANDOFF_SESSION_7.md committed to docs/process/; root copy and the two
  scratch scripts (tools/_d.js, _x.js) deleted. HANDOFF.md's stale "v0.4
  candidate" header replaced with a pointer to v0.17.2 and the freeze.
- Code freeze holds until after 9 Oct. README edits only.
- Demo outcome: not recorded in this chat — ask Jenna.

## Next chat: Brief 30, the clean-up round
Inputs, in this order:
1. The peer-review GitHub issues ("Review: <name>") on the repo. Each must be
   fixed-and-retested or answered in the thread, then closed, by 9 Oct.
2. The Brief 30 list in HANDOFF.md and HANDOFF_SESSION_7.md (full-city 3D,
   persona 7 touch, hosted relay, survey CSV validation, C03 map corner,
   two-tab saves, the five access gaps, Duplicate, Section Undo after import,
   README step 7 wording, sample renders' umbrella, viewer notes clipping,
   render-to-account test).
3. The unaddressed rows in docs/process/23-triage.md (three tables).
4. Jenna's own next walkthrough, same method as before: one item per message
   in chat, chat numbers them, builds the brief as a file in briefs/.

Shape it like 25/28: sections ordered by what users see first; structural items
last so the rest can merge if they overrun; five sites + blank street for
VERIFY; Claude Code runs without pausing; Jenna approves merges from the text
report. Expect it to finish in a fraction of its own estimate.

After Brief 30: Brief 26 full cut with Jenna's voice-over (ffmpeg needs
re-downloading from gyan.dev); a standalone user guide; turn invite_only back
on and retire the test account.

## Chat-side habits worth keeping
- Briefs are files, never chat-only; decisions get reasons.
- Her walkthrough → numbered list → brief; smoke pass (2 personas + Demo
  persona) after every merge; full stranger pass before anything public.
- Supabase changes are hers, run in the SQL editor, "add/if not exists" only;
  never run the whole schema.sql on a live table.
- Never paste secrets into chat; nothing third-party into the repo.
