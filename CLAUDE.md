# brisberg.dev — Infrastructure Decisions

This repo holds everything served at `https://brisberg.dev`: the homepage, the blog,
the knowledge wiki, and recipes. One Hugo site, one deploy.

This file records **decisions that still apply**, and why. It describes what exists
now — not how it got here. Git history holds the migration that consolidated
`blog.brisberg.dev`, `wiki.brisberg.dev`, and `recipies.brisberg.dev` into this repo.

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

**Consequence:** Hugo's embedded link render hook resolves the resulting
`[Text](path.md)` links. This must be explicit, because `auto` only activates for
multilingual projects:

```toml
[markup.goldmark.renderHooks.link]
  useEmbedded = 'always'
```

**Two silent failure modes**, both with a grep in `docs/publishing.md`:

1. The Obsidian setting only changes what Obsidian *generates* — it still parses
   hand-typed `[[...]]`, which renders as literal text on the site.
2. The render hook does not warn on an unresolved destination. It emits the raw
   `foo.md` as the href and the build still succeeds, so a link to a page that
   doesn't exist yet becomes a dead link. Keep placeholder links inside
   `draft: true` pages.

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
