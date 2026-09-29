# Publishing

Everything at `https://brisberg.dev` is built from this repo. This is the whole
workflow.

For *why* the setup looks like this, see [CLAUDE.md](../CLAUDE.md). This file is only
how to operate it.

## Prerequisites

- Hugo extended, at the version in [`.hugoversion`](../.hugoversion):
  `brew install hugo`
- Nothing else. No Node, no package manager, no theme submodules.

Check you match CI:

```sh
hugo version                 # compare against .hugoversion
cat .hugoversion
```

## Writing

```sh
./scripts/new.sh blog    "Some Post Title"
./scripts/new.sh wiki    "Some Note"
./scripts/new.sh recipes "Some Dish"
```

This creates the file from the matching archetype and opens it in `$EDITOR`
(falling back to `code`). The archetype title-cases the slug, so fix the `title:`
line if the result is wrong — "Deploying iOS Builds" arrives as "Deploying Ios
Builds".

New blog and recipe pages start as `draft: true`. **Drafts are never published** —
CI builds without `-D`. Remove the line when it's ready; do not set `draft: false`.
Hugo treats every value other than a correct, unquoted `true` as publishable — `fals`
and `"false"` both publish, silently — so the line can only restate the default, never
catch a mistake. Since the archetypes always write `draft: true`, its absence is
already proof it was removed on purpose.

Content headings start at `##`. The layouts render the `<h1>` from the front-matter
`title`; a second one in the body is a duplicate.

### Pages written by Claude

A page whose prose was generated rather than written by hand carries:

```yaml
generated: claude
```

`page.html` and `list.html` both render "This page was written by Claude." under the
title when that field is set. The wording lives in the layouts, not in the body, so
it is identical on every such page and can be changed in one place. Set the field on
the page itself — including a section's `_index.md`, which renders through
`list.html`.

Do not hand-type a disclosure into the body instead; two mechanisms saying the same
thing is how one of them ends up missing.

### Dates

| Field | Meaning |
|---|---|
| `date` | When it was published. **Never change it.** Sets the order of `/blog/`. |
| `lastmod` | When it was last *substantively* revised. Add it by hand, only then. |

`lastmod` is deliberately not in the archetypes — a new post has nothing to update.
Add the line when a revision changes what the post says, and leave it alone for a
typo or a broken link. The byline renders `updated <date>` only when `lastmod` falls
on a different day than `date`, so an unchanged post shows one date.

`enableGitInfo` would set `lastmod` from the commit time automatically, and is not
used here on purpose: it can't tell a rewrite from a whitespace fix, so every post
would claim to have been updated the last time anything in the repo touched it.

## Previewing

```sh
./scripts/serve.sh           # http://localhost:1313, drafts included
```

Or in VS Code: **Run Build Task** (`⇧⌘B`).

## Publishing

```sh
git add -A && git commit -m "Add post about X" && git push
```

Pushing to `main` triggers `.github/workflows/deploy.yml`, which builds with the
pinned Hugo version and deploys to GitHub Pages via OIDC. There is no `gh-pages`
branch. A deploy takes about a minute; watch it under the repo's Actions tab.

## Promoting something to the homepage

Add to that page's front matter:

```yaml
featured: true
weight: 1      # lower sorts first among featured items
```

The homepage picks these up automatically. There is no separate curation file to
keep in sync.

## Linking between pages

Write ordinary markdown links to the `.md` file. Hugo's embedded link render hook
resolves them to real URLs:

```md
[GitHub Pages](github-pages.md)                  <!-- sibling -->
[GitHub Pages](/wiki/web-domains/github-pages.md) <!-- absolute -->
```

Three things to know:

1. **Do not use `[[wikilinks]]`.** Hugo does not support them. Obsidian is
   configured to write standard markdown links instead (Settings → Files & Links →
   Use `[[Wikilinks]]` = off). Obsidian still *parses* hand-typed wikilinks, so one
   typed from muscle memory will look fine in Obsidian and render as literal
   `[[text]]` on the site. Nothing catches this automatically:

   ```sh
   grep -rn '\[\[' site/content     # should return nothing
   ```

2. **Unresolved links fail silently.** The render hook does not warn when it can't
   find the target — it emits the raw `foo.md` as the href, and the build still
   succeeds. So a link to a page you haven't written yet becomes a dead link on the
   live site. Keep those inside `draft: true` pages, and check before publishing:

   ```sh
   hugo -s site --minify
   grep -roh 'href=[^ >]*\.md[^ >]*' site/public/   # should return nothing
   ```

3. **A link with an empty destination is invisible to that check.** `[text]()`
   renders as `<a href="">`, which sends the reader back to the current page. It has
   no `.md` in it, so the grep above cannot see it — it needs its own:

   ```sh
   grep -rn '](\s*)' site/content     # should return nothing
   ```

   This is usually a placeholder left for a page that didn't exist yet. If the target
   still doesn't exist, the sentence should say so in words rather than link nowhere.

## Images

A page that needs its own images becomes a **directory** — a Hugo leaf bundle. The
URL does not change.

```
blog/my-post.md                  →   blog/my-post/index.md
                                     blog/my-post/a-screenshot.png
```

Reference the image by its bare filename:

```md
![A description of what the image shows.](a-screenshot.png)
```

This is the only image layout that renders in **both** Obsidian and Hugo. The
Obsidian vault is rooted at `site/content/`, so it cannot see `site/static/` at
all — an `/img/...` path shows as a broken image while you write. (The wiki images
under `site/static/img/wiki/` predate this and have that problem. Convert them to
bundles if you ever edit those pages; don't do it as a sweep.)

`./scripts/new.sh` creates a flat `.md` file. Converting it later is two commands:

```sh
cd site/content/blog
mkdir my-post && git mv my-post.md my-post/index.md
```

**Missing images fail silently**, exactly like links: Hugo emits the raw filename,
the build succeeds, and the live page shows a broken image. Same check as above,
for `src`:

```sh
grep -roh 'src=[^ >]*\.\(png\|jpg\|jpeg\|gif\|webp\)[^ >]*' site/public/
```

Every hit should be an absolute path starting with `/`. A bare filename means the
hook did not resolve it.

## Obsidian

The vault is rooted at `site/content/`. Required settings under **Files & Links**:

| Setting | Value |
|---|---|
| Use `[[Wikilinks]]` | **off** |
| New link format | Relative path |
| Automatically update internal links | on |

`site/content/.obsidian/` is gitignored.

## Upgrading Hugo

```sh
brew upgrade hugo
hugo version | sed -E 's/^hugo v([0-9.]+).*/\1/' > .hugoversion
./scripts/serve.sh           # confirm the site still builds
```

Commit `.hugoversion` with whatever the upgrade required. Local and CI read the same
file, so they cannot drift — which is how this property once ended up building one
site with 0.78 and another with 0.157.

## Adding a section

1. `site/content/<name>/_index.md` with `title`, `description`, `weight`
2. A `[[menu.main]]` entry in `site/hugo.toml`
3. `site/archetypes/<name>.md`
4. Add the name to the `case` list in `scripts/new.sh`
5. If it needs its own look, `site/layouts/<name>/page.html` overrides `page.html`

Sections are for content. A genuinely different *application* gets a subdomain
instead — see CLAUDE.md D2.

## Adding a game

This repo does not build or host games. Each game repo builds itself and deploys to
its own environment; this repo only points at the result (CLAUDE.md D2).

1. Append an entry to [`site/data/games.yaml`](../site/data/games.yaml):

   ```yaml
   - name: Some Game
     url: https://brisberg.github.io/some-game/
     repo: https://github.com/brisberg/some-game
     description: One sentence on what it is.
   ```

   `name` and `url` are required — the build fails with a named error if either is
   missing. `repo` and `description` are optional.

2. **Open the `url` and confirm it loads.** Nothing validates it. A typo, or a game
   whose Pages site was never enabled, renders as an ordinary link and 404s on click.

3. `git commit && git push`.

Do this when you create the game's repo, or at its first playable build — whichever
comes first. Nothing in the game repo needs to know this file exists.
