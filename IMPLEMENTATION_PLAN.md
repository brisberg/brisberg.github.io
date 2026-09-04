# brisberg.dev — Consolidation Implementation Plan

Migrate five repos and three deployed sites into one Hugo site served at
`https://brisberg.dev`. Decisions and rationale live in `CLAUDE.md`; this file is
the execution order.

**Budget:** ~9 hours of infrastructure across 5 working blocks. Everything after
Block 5 is writing, not building.

---

## Starting state (verified 2026-09-04)

| Thing | State |
|---|---|
| `brisberg.dev` | Live. Hugo 0.157. One content file (`apps.md`), no `_index.md`, empty h-card, `/cv.pdf` in nav 404s. `config.toml` still carries `minimal` theme params while `black-and-light` is active — social icons render nowhere; `layouts/partials/head-open.html` overrides a partial the active theme doesn't have. |
| `blog.brisberg.dev` | Live, **publicly serving private scratch notes** via Jekyll's default theme (`Blog.md`, `CustomDomainPost.md`). Zero posts. |
| `wiki.brisberg.dev` | Live. Hugo 0.78. Homepage is still the theme's **lorem ipsum**. 15 real content files, ~500 lines. |
| `twine.brisberg.dev` | Live and working. Not in scope. |
| `recipies.brisberg.dev` | No DNS record. Never resolved. Misspelled. Empty repo. |
| Deploys | `gh-pages` branch + `JamesIves/github-pages-deploy-action`, theme git submodules, Hugo versions drifted 0.78 vs 0.157. |

**Total content across the property: ~500 lines of markdown.** This is why the
migration is cheap and why it should happen now rather than after writing more.

---

## Block 1 — Scaffold (≈2h)

Work in `brisberg.github.io`, on a branch. Nothing deploys yet.

1. **Strip the dead theme machinery.**
   ```
   git rm -r --cached site/themes
   rm -rf site/themes .gitmodules
   rm site/layouts/partials/head-open.html   # overrode a partial the active theme lacks
   ```

2. **Rename config** `site/config.toml` → `site/hugo.toml` and rewrite it. Drop
   every `minimal`-era param (`font`, `accent`, `showBorder`, `[[menu.icon]]`),
   drop `theme`. Target:

   ```toml
   baseURL = 'https://brisberg.dev/'
   languageCode = 'en-us'
   title = 'Brandon Risberg'

   [params]
     author = 'Brandon Risberg'
     description = 'Notes, recipes, and writing by Brandon Risberg.'

   # Required: 'auto' only activates for multilingual projects, so be explicit.
   # This is what resolves Obsidian's [Text](path.md) links to real permalinks.
   [markup.goldmark.renderHooks.link]
     useEmbedded = 'always'

   [markup.goldmark.renderer]
     unsafe = true          # carried over from the wiki site (mermaid/katex shortcodes)

   [markup.tableOfContents]
     startLevel = 2

   [[menu.main]]
     name = 'Blog'
     url = '/blog/'
     weight = 1
   [[menu.main]]
     name = 'Wiki'
     url = '/wiki/'
     weight = 2
   [[menu.main]]
     name = 'Recipes'
     url = '/recipes/'
     weight = 3
   [[menu.main]]
     name = 'Apps'
     url = '/apps/'
     weight = 4
   ```

   Do **not** re-add `/cv.pdf` to the menu until a `cv.pdf` exists in
   `site/static/`.

3. **Write minimal layouts.** Hugo ≥0.146 template system — no `_default/`
   directory:

   ```
   site/layouts/
     baseof.html          # <html>, <head>, nav from .Site.Menus.main, footer
     home.html            # bio + section links + featured list
     page.html            # single page: title, date, content, TOC
     list.html            # section index: title, description, page list
     blog/page.html       # only if the blog needs a different single layout
     recipes/page.html    # only if recipes need one (ingredients/method split)
     _partials/head.html
     _partials/nav.html
     _markup/             # empty for now; embedded link hook is doing the work
   ```

   Target ~150 lines of HTML and one stylesheet in `site/static/`. Plain, legible,
   `prefers-color-scheme` aware. **Do not spend this block on design** — see D10.

4. **Section skeletons.** Create `site/content/{blog,wiki,recipes}/_index.md` with a
   title and one-line description each.

5. Verify: `hugo server -s site -D` builds clean with no theme.

## Block 2 — Migrate content (≈2h)

1. **Wiki** — copy `wiki.brisberg.dev/site/content/docs/**` → `site/content/wiki/**`
   (drop the `docs/` level; `/docs/hugo/themes/` becomes `/wiki/hugo/themes/`).
   Copy `wiki.brisberg.dev/site/static/img/docs/**` → `site/static/img/wiki/**` and
   fix the image path in `web-domains/_index.md`.

   **Delete** `wiki.brisberg.dev/site/content/_index.md` — it is theme lorem ipsum
   and has been live for five years. Write a real `site/content/wiki/_index.md`.

   Discard `wiki.brisberg.dev/site/content/posts/` (empty stub) — the blog section
   supersedes it.

2. **Blog** — `blog.brisberg.dev/CustomDomainPost.md` is a genuine half-written post
   and is the natural first published piece. Move it to
   `site/content/blog/hosting-a-custom-domain-on-github-pages.md` with real front
   matter, and mark it `draft: true` until finished. `Blog.md` is a scratch idea
   list — it does **not** get published; keep it locally or fold it into a notes
   file outside `content/`. Same for `brisberg.github.io/wiki/{Blog,Hugo,Home}.md`,
   which duplicate it.

3. **Root** — keep `site/content/apps.md`. Write `site/content/_index.md`: who you
   are, what the site is for, links to the three sections.

4. **Known-stale content to fix while you're in there:**
   `wiki/web-domains/google-domains.md` documents a registrar that no longer exists
   (sold to Squarespace in 2023). Update it, or retitle it as a historical note.

5. Delete `brisberg.github.io/wiki/` and both `publish-wiki.yml` workflows (D8).
   Move build/deploy docs to `docs/publishing.md`.

## Block 3 — CI and cutover (≈2h)

1. Replace `.github/workflows/deploy-site.yml` (and delete
   `publish-wiki.yml`) with a native Pages deploy — no `gh-pages` branch, no
   third-party action, no submodules:

   ```yaml
   name: Deploy
   on:
     push:
       branches: [main]
     workflow_dispatch:

   permissions:
     contents: read
     pages: write
     id-token: write

   concurrency:
     group: pages
     cancel-in-progress: false

   jobs:
     build:
       runs-on: ubuntu-latest
       env:
         HUGO_VERSION: 0.157.0
       steps:
         - uses: actions/checkout@v4
           with:
             fetch-depth: 0        # for .GitInfo / .Lastmod
         - uses: peaceiris/actions-hugo@v3
           with:
             hugo-version: ${{ env.HUGO_VERSION }}
             extended: true
         - run: hugo -s site --minify --baseURL "https://brisberg.dev/"
         - uses: actions/upload-pages-artifact@v3
           with:
             path: site/public

     deploy:
       needs: build
       runs-on: ubuntu-latest
       environment:
         name: github-pages
         url: ${{ steps.deployment.outputs.page_url }}
       steps:
         - id: deployment
           uses: actions/deploy-pages@v4
   ```

   Note: the old workflow built with `-D` (include drafts). **Drop `-D`** — drafts
   must not publish. That flag is why unfinished content has a habit of going live
   here.

2. **Repo Settings → Pages → Source: GitHub Actions** (currently "Deploy from a
   branch"). Without this the workflow succeeds and nothing changes.

3. Keep `site/static/CNAME` containing `brisberg.dev`.

4. Merge to `main`, confirm the deploy, then delete the `gh-pages` branch.

## Block 4 — Retire the old sites (≈1.5h)

1. **Redirect stubs.** GitHub Pages has no server-side redirects. Old wiki URLs are
   indexed. In `wiki.brisberg.dev`, replace the site with static stubs carrying
   `<meta http-equiv="refresh">` + `<link rel="canonical">` to the matching
   `brisberg.dev/wiki/...` URL, and leave that deploy in place. Mapping:
   `wiki.brisberg.dev/docs/<path>/` → `brisberg.dev/wiki/<path>/`.

   Traffic is near zero, so "accept the breakage" is a defensible alternative —
   but decide it deliberately rather than by omission.

2. **`blog.brisberg.dev`** — take it down first and without ceremony; it is
   currently publishing unfinished private notes. Disable Pages on the repo, then
   archive it.

3. **`recipies.brisberg.dev`** — delete or archive. It has no DNS, no content, and a
   typo in its name.

4. **DNS (Squarespace):** remove the `blog` and `wiki` CNAMEs (or point `wiki` at
   the stub deploy until the stubs are retired). Keep apex A records, `www`, and
   `twine`. Add nothing.

5. Add a short note to the archived repos' READMEs pointing at the new URL.

## Block 5 — Authoring ergonomics (≈1.5h)

The target flow is: open the file in VS Code or Obsidian → write → `git commit &&
git push`. Everything here serves that and nothing more.

1. **Obsidian vault** — point it at `site/content/`. Set **Files & Links → Use
   [[Wikilinks]] = off**, **New link format = relative path**, **Automatically
   update internal links = on**, and set the default new-note folder per section.
   Add `site/content/.obsidian/` to `.gitignore`.

2. **Archetypes** — `site/archetypes/{blog,wiki,recipes}.md`, each with the front
   matter that section actually needs (blog: title/date/draft/summary/tags;
   recipes: title/date/draft/servings/time; wiki: title/weight).

3. **Makefile**:
   ```make
   serve:  ; hugo server -s site -D --navigateToChanged
   build:  ; hugo -s site --minify
   post:   ; hugo new -s site content/blog/$(SLUG).md --kind blog
   recipe: ; hugo new -s site content/recipes/$(SLUG).md --kind recipes
   note:   ; hugo new -s site content/wiki/$(SLUG).md --kind wiki
   ```

4. **`docs/publishing.md`** — how to run locally, how to publish, how to promote a
   post to the homepage (`featured: true` + `weight`). This replaces the GitHub
   Wiki.

5. Replace `.vscode/tasks.json` with a task that runs `make serve`.

---

## Stop here.

The pipeline is done. The remaining ~10 hours of the two-month budget are **writing
hours, not building hours**.

**Definition of done for the infrastructure:** you can create a new post in
Obsidian, push, and have it live under `brisberg.dev` in under two minutes, with no
step you had to look up.

### First content targets

- Finish `hosting-a-custom-domain-on-github-pages` — updated for the Squarespace
  migration, which is now the more interesting half of the story.
- One recipe. Any recipe. It establishes the recipe layout's real requirements,
  which is the only honest way to design it.
- One wiki page on something learned in the last month.

### Deferred backlog — do not build these preemptively (D10)

Each is unblocked only by a real piece of content that needed it:

- Rendered backlinks / graph view for the wiki (~20-line partial over `.Site.Pages`).
- Link checking in CI (the embedded render hook fails silently on unresolved
  destinations — worth adding once there are enough cross-links to break).
- Cross-posting to Medium or elsewhere. Do the first five by hand.
- Real theming and design work.
- Tags/taxonomy pages, search, RSS-per-section, analytics, comments.
- Image optimization pipeline for recipes (Hugo `resources` image processing) —
  add when a recipe post is actually slow.
