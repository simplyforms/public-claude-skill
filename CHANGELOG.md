# Changelog

All notable changes to the SimplyForms Claude Code skill follow
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and use semantic
versioning ([semver](https://semver.org)).

## [Unreleased]

### Added
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
