# Demo recording storyboard

Three acts, ~60 seconds end-to-end. The point is to show value in the first
ten seconds — viewer sees an obvious "before" form, types one prompt, Claude
does the rest.

## Setup (before pressing record)

- [ ] Terminal full-screen, large font (14–16 pt), dark theme.
- [ ] Window aspect ratio close to 16:9 (≈ `120 × 32` chars).
- [ ] Hide noisy shell prompt — minimal `PS1`, no git branch indicator.
- [ ] Open `contact-form.html` once in a browser tab on a second screen so
      you can switch to it for the "before / after" visual at the end.
- [ ] Make sure the SimplyForms skill is installed:
      `ls ~/.claude/skills/simplyforms/SKILL.md`.

## Act 1 — Before (0:00 – 0:08)

Goal: show the "old" form so the viewer understands what's about to change.

```
$ cd ~/demo-acme
$ cat contact-form.html | grep -A1 "<form"
    <form action="/send-mail.php" method="POST">
$ claude
```

Beat: a PHP form. Claude Code starts.

## Act 2 — The prompt (0:08 – 0:20)

In Claude Code, type (or paste) **exactly one prompt**:

```
Here's my contact form at ./contact-form.html. Wire it up to SimplyForms.
My form_id is YOUR_REAL_FORM_ID, I'm on the FREE plan. Show an inline
thank-you message on success.
```

Beat: short, conversational, no jargon.

## Act 3 — Claude works (0:20 – 0:55)

Goal: let the viewer SEE the skill being invoked. Don't over-narrate. Let
the natural Claude Code TUI carry it:

- "Using simplyforms skill to wire up the form…"
- Read the form, find `<form action>`, replace with fetch handler.
- Insert `<sf-captcha>` widget + script tag.
- Diff preview, accept.
- (Optional but high-value) "Configure CAPTCHA server-side?" — paste your
  API key, Claude runs the `PUT /user/{form_id}/captcha` curl in-session.
- Test summary printed.

## Act 4 — After (0:55 – 1:00)

Switch to browser, reload `contact-form.html`, show the new "I'm not a
robot" widget rendered inside the form. **Hold the frame for 1.5 seconds**
so the viewer's brain catches up.

End recording (`exit` in the shell).

## Tips for a tight final GIF

- Pause asciinema's idle-time compression with `--idle-time-limit=2`.
- Speed up the result by ~1.4× during conversion (`agg --speed 1.4`) —
  watching real-time typing is boring.
- Target file size: **< 2 MB**. If above, lower the font size in `agg`
  (`--font-size 14`) or drop the speed to 1.6×.
- Don't show real secrets — use a throwaway form_id from a FREE test
  account, never your production API key on camera.
