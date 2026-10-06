# Changelog

All notable changes to the SimplyForms Claude Code skill follow
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and use semantic
versioning ([semver](https://semver.org)).

## [Unreleased]

## [0.4.0] — 2026-10-06

### Added
- `from_name` field: the owner's inbox shows "`<from_name>` via SimplyForms".
- The visitor's `email` (or `_replyto`) becomes the notification's `Reply-To`.

## [0.3.0] — 2026-10-05

### Changed
- Error responses have one shape: `{"ok": false, "code", "message", ...}` at
  the top level. The worked example and the error reference read `data.code` /
  `data.message`; `data.detail ?? data` is no longer needed.
- A used-up monthly e-mail limit is an error now: past the plan's limit and a
  small grace (10 % by default) the API answers
  `429 MONTHLY_EMAIL_LIMIT_REACHED` instead of `200` with a `warning`.
- A notification e-mail that cannot be sent is an error too:
  `502 DELIVERY_FAILED` instead of `200 {"success": true}`.
- `DOMAIN_LIMIT_EXCEEDED` and `DAILY_LIMIT_EXCEEDED` no longer carry the
  owner's domains or usage counts.

### Deprecated
- `detail` in error bodies: the API repeats the error object there for older
  clients during a transition period and will drop it. Do not read
  `data.detail.code` in new code.

## [0.2.0] — 2026-10-05

### Changed
- Step 4: a plain HTML `<form action>` now works — the API redirects browser
  submits (`303`) to a hosted thank-you page or to the page in a `_redirect`
  field (same https origin as the form). `fetch` stays the recommended way for
  an inline thank-you and still gets JSON.

### Fixed
- Error responses are described as they arrive: some wrapped in
  `{"detail": {...}}`, others flat, and the rate-limit body without `ok`. The
  worked example reads `data.detail ?? data`.
- CAPTCHA matrix: reCAPTCHA v2 is an Extend feature like v3; Standard has
  SimplyForms protection (ALTCHA) only.

### Added
- Links to `llms-full.txt` and the public OpenAPI specification.
- `demo/contact-form.html` — sample "old PHP form" used as the demo target.
- `demo/record.sh` — orchestrates a clean asciinema recording and converts
  it to `docs/demo.gif` via `agg`.
- `demo/STORYBOARD.md` — three-act script for the README demo GIF.
- README demo section with regenerate instructions.

## [0.1.0] — 2026-05-23

Initial public release.

### Added
- Step-by-step guide to wire an existing HTML / React / Vue form to the
  SimplyForms submission API (`POST /v1/forms/{form_id}`).
- `<sf-captcha>` (SimplyForms Protection) embedding — widget is self-styled
  by the served bundle, no extra CSS to copy.
- Server-side CAPTCHA configuration via the admin API or dashboard.
- 3-tier subject resolution documented: EXTEND `custom_subject` Jinja →
  submitted `subject` field → static fallback.
- Conventions for `ccemail` (CC, max 5), file uploads, and underscore-prefixed
  hidden fields.
- End-to-end test checklist.
- Cloudflare Turnstile and Google reCAPTCHA configuration notes, including
  the `g-recaptcha-response` → `cf-turnstile-response` field-rename gotcha.
