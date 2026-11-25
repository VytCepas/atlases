# atlases

Learning atlases and study guides, published with GitHub Pages so they open on a phone.
The main page (`docs/index.html`) links to every page.

**This repository is public.** It holds university and personal learning material only.
Work material (MBD, clients, internal systems) never goes here; it belongs in the MBD wiki.

## Adding a page

1. Add a row to `pages.tsv`: slug, group, title, one-line blurb, and the source path under `~/Deliverables`.
2. Run `sh bin/sync.sh`. It copies only the listed files into `docs/<slug>/index.html`, runs the guard on the
   copies, and rebuilds the main page. A guard hit stops the sync and nothing reaches `docs/`.
3. Commit (the pre-commit hook runs the guard tests and the guard on every staged page) and push. GitHub Pages serves `docs/` from `main`.

## The guard

`bin/guard.sh` refuses a page that carries an absolute home path, a `.claude` path, an email address, a GTM,
GA4 or Google Ads id, a ClickUp link or the word harbor. Locally it also refuses any client name from the
private roster (`ATLASES_ROSTER`, default `~/port/azimuth/roster`). That list is confidential, so it is read
at run time and never committed. The sync and the pre-commit hook both run it; enable the hook once per
clone with `git config core.hooksPath .githooks`. On a machine without the roster the guard says so and
checks the generic patterns only.

`sh tests/guard-test.sh` plants each kind of leak and expects the guard to refuse it.

## Decisions

- 2026-11-25: one public repo on the personal account, separate from MBD; one main page linking every
  atlas; first batch the CCBD, GenAI and UX in AI guides; MBD and client material goes to the MBD wiki.
