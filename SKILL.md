---
name: simplyforms
description: >-
  Use when connecting an existing website form to SimplyForms (simplyforms.app,
  a form-backend-as-a-service) — wiring an HTML, React, Vue, or other form to the
  SimplyForms submission API so submissions arrive by email, and adding
  SimplyForms spam protection (ALTCHA, Cloudflare Turnstile, or Google
  reCAPTCHA). Triggers: the user supplies a SimplyForms form_id, or asks to
  "connect my form to SimplyForms", "wire up my contact form", "napoj formular",
  or "add SimplyForms protection".
---

# SimplyForms integration

## Overview

SimplyForms is a **form backend as a service**. A site owner registers, gets a
`form_id`, points their form's submit at the SimplyForms API, and every
submission is **relayed to their inbox by email**. Submissions are never stored
(privacy-first relay model). The service also provides CAPTCHA/spam protection.

Your job with this skill: take a user's existing form on their website and wire
it to SimplyForms — submission + protection — end to end.

**Production API base URL:** `https://api.simplyforms.app`
(For a self-hosted/dev instance, swap this base everywhere below.)

**Don't have a `form_id` yet?** Sign up at <https://simplyforms.app> — the
FREE plan (50 submissions/day, no credit card) is enough to wire things up
end-to-end. The dashboard hands you the `form_id` and API key after e-mail
verification.

## Step 1 — Gather what you need

Ask the user for anything not already provided:

- **`form_id`** — required. Their SimplyForms form identifier (issued at
  registration on <https://simplyforms.app>; visible on the dashboard
  account page).
- **Plan** — FREE / STANDARD / EXTEND / ENTERPRISE. Decides which CAPTCHA types
  are available (see matrix below). FREE cannot use any CAPTCHA.
- **API key** — needed only to configure the CAPTCHA from the command line. If
  the user won't share it, they can configure CAPTCHA in the dashboard instead.
- **Success behaviour** — show an inline "thank you" message, or redirect to a
  page (e.g. `/thank-you`). Default: inline message (JavaScript `fetch`). A
  redirect to a page also works with a plain HTML form and `_redirect` (Step 4).
- **Which protection** — default to **ALTCHA** (this is "SimplyForms
  protection": self-hosted, privacy-first, no third-party account, shows a
  "Protected by SimplyForms" badge). Turnstile/reCAPTCHA need external accounts.

The submission recipient is the account's own email — nothing to configure.

## Step 2 — Verify the form_id

Confirm the id is real before editing anything. The challenge endpoint is
public and needs no auth:

```bash
curl -s -o /dev/null -w "%{http_code}\n" \
  "https://api.simplyforms.app/sf/challenge?form_id=YOUR_FORM_ID"
```

`200` = valid and active. `404` = wrong or inactive `form_id` — stop and ask
the user to re-check it. (`form_id` is 16–32 chars: letters, digits, `-`, `_`.)

## Step 3 — Find the existing form

Locate the `<form>` in the codebase. Note every field's `name` attribute and
**keep those names** — they become the labels in the notification email. If the
old form posted to a PHP script, a `mailto:`, or another service, that wiring is
what you replace. Preserve the markup and styling; only change submission +
add the CAPTCHA widget.

## Step 4 — Rewire the submission

Point the form at `POST https://api.simplyforms.app/v1/forms/{form_id}`. Two
ways work:

- **JavaScript `fetch` (recommended)** — the visitor stays on the page and sees
  an inline thank-you. The API answers JSON. Use the worked example below.
- **Plain `<form action="https://api.simplyforms.app/v1/forms/{form_id}"
  method="POST">`** — no JavaScript needed. A browser submit gets a
  `303 See Other` to the hosted thank-you page (`https://simplyforms.app/sent`
  for Czech/Slovak browsers, `/en/sent` otherwise), which links back to the
  site; a failed submit lands on the same page with a plain explanation. For
  the user's own thank-you page add
  `<input type="hidden" name="_redirect" value="https://their-site.example/thanks">`
  (a path such as `/thanks` works too). `_redirect` is honoured only when it is
  on the same origin as the page the form is on and that page is served over
  `https` (`http` only for localhost); otherwise the hosted page is shown.
  Fine when the user wants a redirect, or the site cannot run JavaScript.

`_redirect` applies only to plain browser submits; a `fetch` call always gets
JSON, so redirect from JavaScript there (`window.location.assign(...)`).

Submit with **`FormData`** (multipart): it carries text fields, file uploads,
and the CAPTCHA token automatically, and needs no `Content-Type` header.

### Worked example — plain HTML form with ALTCHA protection

```html
<form id="sf-form">
  <input name="name" type="text" placeholder="Your name" required>
  <input name="email" type="email" placeholder="Your email" required>
  <textarea name="message" placeholder="Your message" required></textarea>

  <!-- SimplyForms protection. MUST sit inside the <form> so its hidden
       `altcha` field is submitted with it. Renders a click-to-verify
       checkbox by default; add auto="onload" for invisible verification. -->
  <sf-captcha
    challengeurl="https://api.simplyforms.app/sf/challenge?form_id=YOUR_FORM_ID">
  </sf-captcha>

  <button type="submit">Send message</button>
  <p id="sf-status" role="status" aria-live="polite" hidden></p>
</form>

<script src="https://api.simplyforms.app/sf/widget.js" defer></script>
<script>
(() => {
  const ENDPOINT = "https://api.simplyforms.app/v1/forms/YOUR_FORM_ID";
  const form = document.getElementById("sf-form");
  const status = document.getElementById("sf-status");
  const button = form.querySelector("button[type=submit]");

  const show = (message, ok) => {
    status.textContent = message;
    status.hidden = false;
    status.style.color = ok ? "#0a7d4b" : "#c0392b";
  };

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    button.disabled = true;
    status.hidden = true;
    try {
      // FormData -> multipart. Don't set Content-Type; the browser adds the
      // multipart boundary itself.
      const response = await fetch(ENDPOINT, {
        method: "POST",
        body: new FormData(form),
      });
      const data = await response.json().catch(() => ({}));
      if (response.ok && data.success) {
        form.reset();
        show("Thanks — your message has been sent.", true);
        // To redirect instead: window.location.assign("/thank-you");
      } else {
        // Errors: {"ok": false, "code": "...", "message": "..."}.
        show(data.message || "Submission failed. Please try again.", false);
      }
    } catch (error) {
      show("Network error. Please check your connection and try again.", false);
    } finally {
      button.disabled = false;
    }
  });
})();
</script>
```

Replace **both** occurrences of `YOUR_FORM_ID` with the real id.

### React / Vue / framework forms

Same approach, adapted:
- Load `https://api.simplyforms.app/sf/widget.js` once (in `index.html`, or via
  a `useEffect` / `onMounted` that injects the `<script>`).
- Render `<sf-captcha challengeurl="...">` inside the form. In **Vue**, mark
  `sf-captcha` as a custom element (`compilerOptions.isCustomElement`) so it
  isn't treated as a component. In **React**, use it directly as a lowercase
  JSX tag.
- In the submit handler call `fetch(ENDPOINT, { method: "POST", body: new
  FormData(formEl) })` and branch on `response.ok && data.success` exactly as
  above. Get `formEl` from a ref.

## Step 5 — Turn on SimplyForms protection

Two parts: embed the **widget** in the page (Step 4's example already embeds
ALTCHA) and enable the CAPTCHA **server-side** for the form.

**Order matters — enable server-side LAST.** While the server-side type is
`none`, the API ignores any submitted token, so a deployed widget is harmless.
Once the type is `altcha`/`turnstile`/etc., a submission with no valid token is
rejected. So: ship the widget first (or in the same deploy), then flip the
server-side type — never enable it before the widget code is live, or the form
breaks in the gap.

### Configure server-side

**Option A — API (do this if you have the API key):**

```bash
curl -X PUT "https://api.simplyforms.app/user/YOUR_FORM_ID/captcha" \
  -H "X-API-Key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"type":"altcha","altcha_difficulty":"medium"}'
```

Verify:

```bash
curl -H "X-API-Key: YOUR_API_KEY" \
  "https://api.simplyforms.app/user/YOUR_FORM_ID/captcha"
```

**Option B — dashboard:** tell the user to open
`https://dash.simplyforms.app` → **CAPTCHA** (`/dashboard/captcha`), pick the
provider, and save.

A response of `403 FEATURE_NOT_AVAILABLE` means the plan doesn't allow that
CAPTCHA type — check the matrix.

### CAPTCHA matrix (what each plan allows)

| Type        | FREE | STANDARD | EXTEND | ENTERPRISE |
|-------------|------|----------|--------|------------|
| `none`      | ✅   | ✅       | ✅     | ✅         |
| `altcha`    | ❌   | ✅       | ✅     | ✅         |
| `recaptcha` v2 | ❌ | ❌      | ✅     | ✅         |
| `recaptcha` v3 | ❌ | ❌      | ✅     | ✅         |
| `turnstile` | ❌   | ❌       | ✅     | ✅         |
| `challenge` | ❌   | ❌       | ✅     | ✅         |

### Provider details

**ALTCHA (recommended — "SimplyForms protection"):** no external account.
Config body: `{"type":"altcha","altcha_difficulty":"easy|medium|hard"}`. Embed
`<sf-captcha challengeurl="https://api.simplyforms.app/sf/challenge?form_id=ID">`
inside the form and load `https://api.simplyforms.app/sf/widget.js`. The widget
submits its proof in a hidden field named `altcha` — `FormData` includes it
automatically. Add `auto="onload"` to the `<sf-captcha>` tag for invisible
(no-click) verification.

The widget bundle bakes in the SimplyForms theme (colors, sizing) and hides
the upstream ALTCHA logo on every embed — bare `<sf-captcha>` looks identical
on every site and matches the dashboard live preview. No extra CSS for the
customer to copy.

**Cloudflare Turnstile:** needs a Cloudflare account. Config body:
`{"type":"turnstile","turnstile_site_key":"...","turnstile_secret_key":"..."}`.
Embed Cloudflare's `<div class="cf-turnstile" data-sitekey="...">` + their
`api.js`. The widget produces a hidden field `cf-turnstile-response`, which the
API reads natively.

**Google reCAPTCHA:** needs a Google account. Config body:
`{"type":"recaptcha","recaptcha_site_key":"...","recaptcha_secret_key":"...","recaptcha_version":"v2"}`
(`v3` adds `"recaptcha_threshold":0.5`). **Gotcha:** Google's widget outputs the
token in a field named `g-recaptcha-response`, but the SimplyForms API only
reads the CAPTCHA token from `cf-turnstile-response` or `altcha`. So you **must**
copy the token into a `cf-turnstile-response` field before submitting — e.g.
before the `fetch`: `formData.set("cf-turnstile-response",
formData.get("g-recaptcha-response"))`. Prefer ALTCHA or Turnstile to avoid this.

**Provider secrets are write-only.** No response ever returns
`turnstile_secret_key` / `recaptcha_secret_key`; reads report
`turnstile_secret_key_set` / `recaptcha_secret_key_set` (`true`/`false`). On
`PUT`, a missing, `null` or empty secret keeps the stored one; to remove it
send `"clear_turnstile_secret_key": true` (or `clear_recaptcha_secret_key`).

## Step 6 — Test it

1. Run the user's site locally and open the page with the form.
2. Submit a valid entry → expect the success message; the email lands in the
   account inbox within a moment.
3. In dev tools → Network, confirm `POST /v1/forms/{form_id}` returns
   `200 {"success": true}` (a plain HTML form instead gets a `303` to the
   thank-you page or the `_redirect` URL).
4. Submit without solving the CAPTCHA → expect a `400` with a CAPTCHA error and
   a visible error message.

## API reference

**Submit:** `POST https://api.simplyforms.app/v1/forms/{form_id}`
(permanent alias: `POST /submit/{form_id}`). Accepts `multipart/form-data`,
`application/x-www-form-urlencoded`, or `application/json`. No API key needed —
the `form_id` is the credential. Embeddable on any origin.

**Success:** `200 {"success": true}` — the notification e-mail was handed to
the mail server. If that fails the API answers `502 DELIVERY_FAILED` and runs
nothing else (no webhook, no autoresponder). Past the monthly e-mail limit
submissions are still delivered within a small grace allowance (10 % by
default), then rejected with `429 MONTHLY_EMAIL_LIMIT_REACHED` until the limit
resets.

**Success vs error — how to test it:** a successful response is the only one
that carries `success: true`. Error responses have **no `success` key**. So
`response.ok && data.success` (as in the Step 4 handler) is the reliable
happy-path check — do not rewrite it to test `data.success === false`, which is
never sent.

**Plain HTML form posts** (no JavaScript) never see JSON: success is a `303` to
`_redirect` or the hosted thank-you page, an error a `303` to
`https://simplyforms.app/sent?error=CODE`.

**Field rules:**
- Every field whose `name` does **not** start with `_` appears in the email.
- `name`s starting with `_` are kept out of the email body (use for hidden
  client-side fields).
- `subject` — if present and non-empty, becomes the email's `Subject:` header
  (every plan, no configuration). Without it, falls back to "New form
  submission". EXTEND plans can override with a Jinja-rendered template in
  the dashboard (e.g. `custom_subject = "{{ subject or 'Lead received' }}"`).
- `from_name` — the sender name shown in the owner's inbox, as
  "`<from_name>` via SimplyForms" (the address stays SimplyForms'). Use a
  hidden field with the site or form name, e.g. `<input type="hidden"
  name="from_name" value="Acme website">`. Not listed in the email body.
  On Standard and up the owner can instead set a fixed sender name in the
  dashboard (Forms → Sender name): it replaces `from_name` and is shown
  without "via SimplyForms". Prefer that over `from_name` on paid plans.
- `email` (or `_replyto`, which wins) — a valid address becomes the
  notification's `Reply-To`, so the owner can answer the visitor with a plain
  "Reply". Name the visitor's address field `email`.
- `ccemail` — **deprecated, do not use.** Only addresses already configured
  under Recipients in the dashboard pass the filter, and those receive every
  submission anyway, so the field cannot add a recipient. Extra recipients go
  under Recipients in the dashboard.
- File `<input type="file">` fields are emailed as attachments. Per-submission
  cap: FREE 1 MB · STANDARD 5 MB · EXTEND 50 MB.
- CAPTCHA token fields (`altcha`, `cf-turnstile-response`) are consumed by the
  server and never appear in the email.

**Default notification e-mail:** every plan gets the polished SimplyForms
Clean Card layout out of the box — no template configuration. EXTEND plans can
override the body and the subject in the dashboard Email Template Studio
(`custom_body` HTML + Jinja-rendered `custom_subject` against the submission
fields, e.g. `{{ subject or "Lead received" }}`).

**Error responses** have one shape — `{"ok": false, "code": "...", "message":
"...", ...extra}` at the top level. Show `data.message`, branch on `data.code`:

- Request / form: `INVALID_FORM_ID_FORMAT` (400), `INVALID_FORM_ID` (401),
  `EMPTY_PAYLOAD`, `UNSUPPORTED_CONTENT_TYPE`, `INVALID_JSON`,
  `INVALID_PAYLOAD` (400), `INVALID_REQUEST` (422, `errors`),
  `VALIDATION_FAILED` (400, `errors`), `DOMAIN_LIMIT_EXCEEDED` (403, the form's
  plan does not accept this domain — FREE allows one, paid plans unlimited).
- CAPTCHA: `CAPTCHA_FAILED` and the other CAPTCHA codes (400, may add
  `"challenge_required": true`).
- Limits: `FILE_SIZE_LIMIT_EXCEEDED` (413, over the plan's attachment limit),
  `FILE_TOO_LARGE` / `PAYLOAD_TOO_LARGE` (413, over 50 MB),
  `DAILY_LIMIT_EXCEEDED` (429, `reset_date`), `MONTHLY_EMAIL_LIMIT_REACHED`
  (429, the owner's monthly e-mail limit and its grace are used up;
  `reset_date`, `Retry-After`), `RATE_LIMIT_EXCEEDED` (429, `Retry-After`
  header).
- Server: `SUBMISSION_FAILED`, `INTERNAL_ERROR` (500), `DELIVERY_FAILED` (502,
  the e-mail could not be sent — let the visitor try again).

Every error body also carries `detail`, a copy of the same object for older
clients. It is **deprecated** and will be removed — do not read
`data.detail.code` in new code.

## Common mistakes

- Adding `_redirect` to a form submitted with `fetch` → ignored; `fetch` always
  gets JSON. Redirect from JavaScript instead, or use a plain form.
- Reading `data.detail.code` / `data.detail.message` → works only during the
  deprecation period. Read `data.code` / `data.message`.
- Placing `<sf-captcha>` **outside** the `<form>` → its `altcha` field is not
  submitted → every submission fails the CAPTCHA. Keep it inside.
- Embedding the widget but never configuring the CAPTCHA server-side (or vice
  versa) → mismatch. Do **both** in Step 5.
- Setting `Content-Type: application/json` while sending a `FormData` body →
  broken request. With `FormData`, set no `Content-Type` at all.
- reCAPTCHA: leaving the token in `g-recaptcha-response` → the API never sees it.
  Copy it to `cf-turnstile-response` (see provider notes).
- Renaming existing field `name`s → the notification email labels change. Keep
  the user's original names unless asked.

## Resources

- **Dashboard** — <https://dash.simplyforms.app> — manage CAPTCHA, e-mail
  template (EXTEND), view usage, manage subscription.
- **Full integration guide** — <https://simplyforms.app/docs> — HTML / JS
  recipes, framework adapters, special form fields (`subject`, `_*`),
  webhooks, autoresponder, server-side validation.
- **Machine-readable** — <https://simplyforms.app/llms-full.txt> (full
  integration guide in plain text) and <https://simplyforms.app/openapi.json>
  (public API specification).
- **Pricing & plans** — <https://simplyforms.app/#pricing> — plan limits
  (submissions/day, e-mails/month, file size, CAPTCHA types).
- **Status** — <https://status.simplyforms.app> — service health.
- **Source of this skill** — <https://github.com/simplyforms/public-claude-skill>
  — issues, PRs, changelog. Update locally with
  `cd ~/.claude/skills/simplyforms && git pull`.
