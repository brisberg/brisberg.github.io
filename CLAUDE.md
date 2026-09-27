# brisberg.dev — Infrastructure Decisions

This repo holds everything served at `https://brisberg.dev`: the homepage, the blog,
the knowledge wiki, and recipes. One Hugo site, one deploy.

This file records **decisions that still apply**, and why. It describes what exists
now — not how it got here. Git history holds the migration that consolidated
`blog.brisberg.dev`, `wiki.brisberg.dev`, and `recipies.brisberg.dev` into this repo.

A closing section records **open questions** — things deliberately not decided,
kept here so a later attempt starts from what was already learned rather than
from zero.

For how to operate the site, see [`docs/publishing.md`](docs/publishing.md).

---

## D1. One repo, one site, one deploy

`brisberg.dev/blog/`, `/wiki/`, `/recipes/` are **sections of one Hugo site**, not
separate sites.

**Why:** Different content types need different *layout templates*, not different
*rendering systems*. Templates are a per-section concern inside one site. The
alternative — a repo and a subdomain per content type — costs a config, a CI
pipeline, and an independently drifting Hugo version each, and gives up
cross-references, shared search, and a shared nav in exchange for nothing.

**Consequence:** Links between any two pages use Hugo's normal page resolution.
`./scripts/serve.sh` previews the whole property at once.

## D2. Subdomains are for different *applications*, not different *content*

The dividing line is **different runtime**, not different look.

- `twine.brisberg.dev` — its own repo. Serves compiled Twine game artifacts, fanned
  in via git submodules and `repository_dispatch`. It works; leave it alone.
- A future SPA or service may claim a subdomain.
- **Markdown content never gets a subdomain.** It gets a section.

Adding a section is five steps, documented in `docs/publishing.md`.

## D3. Hugo, pinned in one place

**Why Hugo:** Not because it wins on features — Astro probably does. Because this
site is maintained by one person a few hours a month, and a single static binary with
no dependency tree still builds after years of neglect. A Node-based site of the same
age would not `npm install` without work.

**Consequence:** The version lives in `.hugoversion` at the repo root, read by both
the developer and CI. There is exactly one number. No `node_modules` in the build
path, and no task runner — there is no build graph here, so `make` and `just` would
add a dependency (or a footgun) to run what are really two shell aliases. Hence
`scripts/serve.sh` and `scripts/new.sh`.

## D4. The repo stays named `brisberg.github.io`

`<username>.github.io` is GitHub's special user-site repo: it publishes at the root
of `https://brisberg.github.io` rather than under a `/<repo>` path. The custom domain
masks this, but the fallback URL stays clean.

## D5. GitHub Pages, deployed natively

Hosting lives where the code lives. The main alternative (Cloudflare, Netlify) mostly
buys per-PR preview deploys, which are worth little to a solo author who runs
`hugo server`.

Within Pages, the deploy uses as few parts as possible:
`actions/upload-pages-artifact` + `actions/deploy-pages` with OIDC
(`pages: write`, `id-token: write`). **No `gh-pages` branch, no third-party deploy
action holding a token.** The Pages source is set to "GitHub Actions" — changing it
back to "Deploy from a branch" silently breaks deploys.

CI builds **without `-D`**. Drafts must never publish.

## D6. No third-party themes

Layouts are owned by this repo, under `site/layouts/`. There is no `themes/`
directory and no theme submodule.

**Why:** For a site this size the layouts are ~150 lines of HTML plus one
stylesheet. A third-party theme means its params, its partial structure, and its
shortcodes leak into content, and config drifts out of sync with whichever theme is
actually active. Owning the layouts ends that class of bug and keeps CI free of
`submodules: true`.

**Consequence:** `site/layouts/_shortcodes/details.html` exists because wiki content
uses a `details` shortcode that a theme used to provide. Content must not depend on
shortcodes this repo does not define.

**Revisit:** Only once there is enough content to be worth designing around. Design
is not a prerequisite for publishing.

## D7. Obsidian writes standard Markdown links, not wikilinks

The vault is rooted at `site/content/`. Required settings under **Files & Links**:
**Use `[[Wikilinks]]` = off**, **New link format = relative path**, **Automatically
update internal links = on**.

**Why:** Hugo's maintainer has explicitly declined to support `[[wikilink]]` syntax,
and it isn't in CommonMark. Every workaround is a preprocessing script or a regex
render hook — a moving part that fails silently and that we would own forever.

**Consequence:** Hugo's embedded render hooks resolve the resulting
`[Text](path.md)` links and `![alt](image.png)` images. Both must be explicit,
because `auto` only activates for multilingual projects:

```toml
[markup.goldmark.renderHooks.link]
  useEmbedded = 'always'
[markup.goldmark.renderHooks.image]
  useEmbedded = 'always'
```

**Two silent failure modes**, both with a grep in `docs/publishing.md`:

1. The Obsidian setting only changes what Obsidian *generates* — it still parses
   hand-typed `[[...]]`, which renders as literal text on the site.
2. Neither hook warns on an unresolved destination. It emits the raw `foo.md` or
   `foo.png` and the build still succeeds, so a reference to something that doesn't
   exist yet becomes a dead link or a broken image. Keep placeholders inside
   `draft: true` pages.

**Consequence:** a page with its own images is a **leaf bundle** — a directory with
`index.md` and the images beside it — referenced by bare filename. Images do not go
in `site/static/`, which is outside the vault and therefore invisible while writing.

## D8. Layouts own the `<h1>`; content starts at `##`

`page.html` and `list.html` render `<h1>` from the front-matter `title`. A second H1
in the body is a duplicate. `markup.tableOfContents.startLevel = 2` depends on this.

**Why:** One source of truth for a page's title. A hand-typed in-body H1 drifts from
the `title` used in lists, nav, and `<title>`, and has to be typed every time.

## D9. No GitHub Wiki mirroring

Developer docs live in `docs/` in this repo.

**Why:** GitHub Wiki is a separate git repo with no PR review and no coupling to the
code. Docs describing a workflow file must change in the same commit as the workflow
file, or they drift. (This reasoning is specific to this repo, where the wiki is also
the deliverable — mirroring `docs/` into a repo Wiki remains reasonable elsewhere.)

## D10. Taxonomies are disabled until there is enough content to need them

```toml
disableKinds = ['taxonomy', 'term']
```

**Why:** They were generating empty `/tags/` and `/categories/` pages. `tags` in
front matter is still recorded and will work retroactively whenever these are
switched back on — so tag as you write, and enable the pages when there are enough
to be navigable.

## D11. Cross-posting is deferred

The hard requirement — static URLs under `brisberg.dev` — is satisfied by the site
itself. Cross-posting is **not** built until there are posts worth cross-posting.

Notes for whenever it is revisited: Medium's publishing API has been effectively
locked down for years; verify before designing around it. Letterboxd is a
film-logging service, not a blogging platform — you can review films you have
logged, but not cross-post arbitrary posts. Whatever the target, `brisberg.dev`
holds the canonical URL and the copy carries `rel=canonical` back to it.

## D12. Content before chrome; no speculative features

1. **Content before chrome.** Real content ships on plain layouts before design work.
2. **No speculative features.** Every addition must be triggered by a piece of
   content that needed it and didn't have it.

**Why:** The failure mode for this site is not a bad architecture. It is spending the
available hours on backlink partials, cross-post OAuth, and CSS instead of writing.

Deferred under this rule until content demands them: rendered backlinks and graph
view, link checking in CI, taxonomy pages (D10), search, per-section RSS, analytics,
comments, and image processing for recipes.

## D13. Generated pages disclose it, from front matter

A published page whose prose was written by Claude rather than by hand carries
`generated: claude` in its front matter. `page.html` and `list.html` render the
disclosure line from that field; the body never states it.

**Why:** A reader weighing how much to trust a page should not have to guess whether
a person stood behind the words, and git history is not where they will look. Making
it a structured field rather than a typed sentence means the wording is identical on
every such page, changes in one place, and can be listed with a `grep` of front
matter instead of a search for prose.

**Consequence:** The field is all-or-nothing — it marks a page that is *entirely*
generated. A page mixing generated and hand-written prose does not get it, because a
reader cannot tell which half is which, so editing a generated page into your own
words means deleting the line. Both layouts must keep the check: a section's
`_index.md` renders through `list.html`, and dropping it there would ignore the field
on every section landing page without failing the build.

**Not covered:** this says nothing about whether generated content should be
published — only that it is labeled when it is. The bar for publishing it is the
same as for anything else here: it has to be worth reading, and worth standing
behind.

---

## Open questions

### Q1. How is published content reviewed for typos and grammar?

A sweep on 2026-09-26 read all of `site/content` — about 5,300 words across 21
pages — and fixed 30 errors, some of which had been live for years. That rate is high
enough to want something repeatable, and nothing is in place.

The errors split into classes that need different tools, which is the whole
difficulty:

- 11 plain misspellings (`beneith`, `disctates`, `autimatically`)
- 6 grammar slips where every word is correctly spelled (`I an investigating`,
  `These isn't a clean declaration`, `summarized the it better`)
- 9 style inconsistencies (`Wifi`, `github pages`, `E.x.`)
- 2 British spellings in an otherwise American-spelled repo
- 1 markdown link with an empty destination

**The option on the table** is [`typos`](https://github.com/crate-ci/typos)
(`brew install typos-cli`): one Rust binary, no config, no dependency tree — the same
property that chose Hugo in D3. It addresses only the first class. `aspell` covers
more but needs a maintained wordlist to stop flagging `gh-pages`, `osxkeychain` and
`DMARC` on every run. `vale` is the only thing that would catch the style class, at
the cost of a styles directory and a vocabulary file, to find nine errors
accumulated over roughly five years.

The exact catch rate is **unverified** — the pre-sweep content is in git history, so
installing `typos` and running it against that revision would measure it rather than
assume it.

**The unresolved part is grammar**, which is also the part that embarrasses:
`I an investigating` was the first line of a published page. No spellchecker finds
it, because every word is real. The realistic answer is a read-through by a person or
a model at writing time, one page at a time — a habit, not a tool — and that is what
this question is actually about.

**Constraint on any answer:** it does not go in CI. D12 defers link checking there
for the same reason, and a deploy that fails over `Wifi` is worse than the typo. A
pre-push check or a git hook is the ceiling.

Already settled, so not part of this question: empty-destination links have a grep in
`docs/publishing.md` alongside the wikilink and unresolved-link checks.

---

## Working in this repo

- Hugo site root is `site/`. Preview with `./scripts/serve.sh`; create content with
  `./scripts/new.sh <blog|wiki|recipes> "<Title>"`.
- Sections: `site/content/{blog,wiki,recipes}/`, plus `site/content/apps.md`.
- Layouts use the Hugo ≥0.146 template system — there is no `_default/` directory:
  `layouts/baseof.html`, `home.html`, `page.html`, `list.html`, `_partials/`,
  `_shortcodes/`. A section needing its own look gets `layouts/<section>/page.html`.
- Homepage promotion is `featured: true` + `weight` in a page's front matter, not a
  separate curation file.
- Publishing is `git commit && git push` to `main`. CI builds and deploys.
- DNS specifics for the domain are documented as content, in
  [`/wiki/web-domains/`](site/content/wiki/web-domains/).
