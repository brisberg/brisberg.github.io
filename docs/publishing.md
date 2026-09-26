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
CI builds without `-D`. Remove the line when it's ready.

Content headings start at `##`. The layouts render the `<h1>` from the front-matter
`title`; a second one in the body is a duplicate.

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

Two things to know:

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
