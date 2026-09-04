# brisberg.dev — Infrastructure Decisions

This repo is the single source for everything served at `https://brisberg.dev`.
It replaces the former split across `blog.brisberg.dev`, `wiki.brisberg.dev`, and
`recipies.brisberg.dev`.

This file records **decisions and their rationale**, so they don't get re-litigated
or accidentally reversed. For the migration steps, see `IMPLEMENTATION_PLAN.md`.

---

## D1. One repo, one site, one deploy

`brisberg.dev/blog/`, `/wiki/`, `/recipes/` are **sections of one Hugo site**, not
separate sites.

**Why:** The original split assumed different content types need different
*rendering systems*. They don't — they need different *layout templates*, which is
a per-section concern inside one site. The split bought five configs, five CI
pipelines, five drifting Hugo versions, no cross-references, no shared search, and
no shared nav, in exchange for nothing that was actually used.

**Consequence:** Cross-links between any two pages use Hugo's normal page
resolution. Search indexes everything. `hugo server` previews the whole property.

## D2. Subdomains are reserved for different *applications*, not different *content*

The dividing line is **different runtime**, not different look.

- `twine.brisberg.dev` — keeps its own repo. Compiled Twine game artifacts fanned
  in via git submodules + `repository_dispatch`. It works; leave it alone.
- A future SPA or service may claim a subdomain.
- **Markdown content never gets a subdomain.** It gets a section.

## D3. Stay on Hugo

**Why:** Not because Hugo wins on features in 2026 — Astro probably does. Because
this property sat untouched for five years and the Hugo site still builds. A single
static binary with no dependency tree is the right choice for software maintained
by one person a few hours a month. An equivalent Node-based site from 2021 would
not `npm install` today without work.

**Consequence:** Pin the Hugo version in CI and bump it deliberately. No
`node_modules` in the build path.

## D4. Repo stays named `brisberg.github.io`

`<username>.github.io` is GitHub's special user-site repo: it publishes at the root
of `https://brisberg.github.io`, not `https://brisberg.github.io/<repo>`. The custom
domain masks this, but the fallback URL stays clean.

## D5. GitHub Pages, deployed natively

Stay on GitHub Pages — hosting lives where the code lives, and the main alternative
(Cloudflare/Netlify) mostly buys per-PR preview deploys, which are worthless for a
solo author who runs `hugo server`.

But cut parts *within* Pages:

- Use GitHub's native `actions/deploy-pages` + `actions/upload-pages-artifact` with
  OIDC (`permissions: pages: write, id-token: write`).
- **No `gh-pages` branch.** No third-party deploy action holding a token.

## D6. No third-party themes

Own the layouts. `themes/` and theme git submodules are gone.

**Why:** The site previously carried three theme submodules (two unused, one not
even checked out), and the live config still described a theme that had been
swapped out — dead params, dead override files, social icons rendering nowhere.
For a site this size the layouts are ~150 lines of HTML/CSS. Owning them ends the
config-drift class of bug permanently, and removes the `submodules: true`
requirement from CI.

**Revisit:** Only after there is real content to theme. Design work is not a
prerequisite for publishing.

## D7. Obsidian writes standard Markdown links, not wikilinks

In the Obsidian vault used for this site: **Settings → Files & Links → Use
[[Wikilinks]] = off**, **New link format = relative path**.

**Why:** Hugo's maintainer has explicitly declined to support `[[wikilink]]`
syntax, and it isn't in CommonMark. Every workaround is a preprocessing script or
regex render hook — a moving part that fails silently and that we'd own forever.

**Consequence:** Hugo's embedded link render hook resolves the resulting
`[Text](path.md)` links. This requires explicit config, because `auto` only
activates for multilingual projects:

```toml
[markup.goldmark.renderHooks.link]
  useEmbedded = 'always'
```

**Known footgun:** the setting only changes what Obsidian *generates*; Obsidian
still parses hand-typed `[[...]]`. And the embedded hook does not warn on an
unresolved destination — a link to a page that doesn't exist yet renders as a dead
link rather than a build error. Keep placeholder links inside `draft: true` pages,
or add a link checker later (see D10).

## D8. No GitHub Wiki mirroring

The `publish-wiki.yml` workflows are deleted. Developer docs for this site live in
`docs/` in this repo.

**Why:** GitHub Wiki is a separate git repo with no PR review and no coupling to
the code. Docs describing a workflow file must change in the same commit as the
workflow file, or they drift. (This reasoning is specific to *this* repo, where the
wiki is also part of the deliverable — mirroring `docs/` into a repo Wiki remains
reasonable for other projects.)

## D9. Cross-posting is deferred

The hard requirement — static URLs under `brisberg.dev` — is satisfied by the site
itself. Cross-posting to Medium or elsewhere is **not** built until there are posts
worth cross-posting.

Notes for when it's revisited: Medium's publishing API has been effectively
locked down for years — verify before designing around it. Letterboxd is a
film-logging service, not a blogging platform; you can review films you've logged,
but you cannot cross-post arbitrary posts. Whatever the target, `brisberg.dev`
holds the canonical URL and the copy carries `rel=canonical` back to it.

## D10. Content before chrome; no speculative features

Two rules that govern what gets built:

1. **Content before chrome.** Real content ships on plain layouts before any design
   work happens.
2. **No speculative features.** Every addition after the pipeline works must be
   triggered by a piece of content that needed it and didn't have it.

**Why:** There is a five-year record of building publishing infrastructure and not
publishing. The failure mode is not a bad architecture; it's spending the
infrastructure budget on backlink partials, cross-post OAuth, and CSS instead of
writing. Deferred-until-needed by this rule: rendered backlinks/graph view, link
checking in CI, cross-posting, taxonomy pages, comments, analytics.

## D11. DNS

Registrar is Squarespace (migrated from Google Domains), renewed through 2030,
grandfathered pricing. Records:

- Apex `A` → GitHub Pages IPs (`185.199.108-111.153`)
- `www` `CNAME` → `brisberg.github.io`
- `twine` `CNAME` → `brisberg.github.io`

The `blog` and `wiki` records are retired with the consolidation. `recipies` never
resolved at all — and the misspelling dies with it: the section is `/recipes/`.

---

## Working in this repo

- Hugo site root is `site/`. Run `hugo server -s site -D` (or `make serve`).
- Sections: `site/content/blog/`, `site/content/wiki/`, `site/content/recipes/`.
- Layouts use the Hugo ≥0.146 template system: `layouts/baseof.html`,
  `layouts/home.html`, `layouts/page.html`, `layouts/list.html`,
  `layouts/_partials/`, `layouts/_markup/`. There is no `_default/` directory.
- Homepage promotion is driven by `featured: true` + `weight` in a page's front
  matter — not a separate curation file.
- Publishing is `git commit && git push` to `main`. CI builds and deploys.
