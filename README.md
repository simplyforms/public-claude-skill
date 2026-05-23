# SimplyForms — Claude Code skill

<p align="center">
  <img src="docs/demo.gif" alt="60-second demo: a plain PHP contact form gets wired up to SimplyForms in one Claude Code prompt" width="760">
</p>

Wire any HTML, React, or Vue contact form to [SimplyForms](https://simplyforms.app)
in one prompt. Claude Code reads the skill, finds the form in your project,
repoints submissions to the SimplyForms API, embeds the spam-protection widget,
and walks through end-to-end verification with you.

## Install

```bash
git clone https://github.com/simplyforms/public-claude-skill ~/.claude/skills/simplyforms
```

That's it. Open Claude Code in any project and say something like:

> Here's my old contact form at `./about.html`. Wire it to SimplyForms. My
> `form_id` is `Kf83hd02Lpzq7Xn1`, I'm on the FREE plan.

Claude follows the steps in [`SKILL.md`](SKILL.md) — locates the form, keeps
your field names, replaces the submission with a `fetch` to
`POST https://api.simplyforms.app/v1/forms/{form_id}`, embeds the SimplyForms
`<sf-captcha>` widget, optionally configures the CAPTCHA server-side via the
admin API, and runs the test checklist.

## Update

```bash
cd ~/.claude/skills/simplyforms && git pull
```

## What it does

- Finds the existing `<form>` and preserves field names (they become the labels
  in the notification e-mail).
- Replaces the submission handler with a `fetch` to the SimplyForms relay
  endpoint — supports inline thank-you messages and client-side redirects.
- Embeds `<sf-captcha>` — SimplyForms-branded, self-styled, no third-party
  account, GDPR-friendly. Cloudflare Turnstile and Google reCAPTCHA are also
  documented for EXTEND plans.
- Configures the CAPTCHA type for your form via the admin API (if you supply
  the API key) or walks you through the dashboard.
- Walks through a verification checklist: real submission, network tab status,
  CAPTCHA failure path, error UX.
- Works with plain HTML, React, Vue / Nuxt, and other framework forms.

The polished default notification e-mail (Clean Card layout) is enabled for
every plan out of the box — no template configuration needed. EXTEND plans can
override the body and the subject (Jinja-rendered) in the dashboard Email
Template Studio.

## Don't have a `form_id` yet?

[Sign up at simplyforms.app](https://simplyforms.app). The FREE plan gives you
50 submissions/day and is enough to wire things up end-to-end.

## Resources

- [Dashboard](https://dash.simplyforms.app) — manage CAPTCHA, e-mail template,
  view usage, manage subscription.
- [Full integration guide](https://simplyforms.app/docs) — HTML, JS, framework
  recipes, special form fields (`subject`, `ccemail`, `_*`), webhooks,
  autoresponder.
- [Status](https://status.simplyforms.app) — service health.

## Demo / contributing

See [`demo/STORYBOARD.md`](demo/STORYBOARD.md) for the three-act script
behind the GIF above. To re-record after a skill change:

```bash
brew install asciinema agg     # one-time
./demo/record.sh               # opens asciinema, do the demo, exit; writes docs/demo.gif
```

The script copies [`demo/contact-form.html`](demo/contact-form.html) into a
fresh working dir, records your terminal at 120×32, and converts the cast to
a small sharp GIF via [`agg`](https://github.com/asciinema/agg).

Issues and pull requests welcome.

## License

MIT — see [LICENSE](LICENSE).
