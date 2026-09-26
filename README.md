# brisberg.github.io

Everything served at **[brisberg.dev](https://brisberg.dev)** — the homepage, the
blog, the knowledge wiki, and recipes — built with [Hugo](https://gohugo.io) and
deployed to GitHub Pages.

This repo keeps its `<username>.github.io` name because that is GitHub's special
user-site repo: it publishes at the root of `brisberg.github.io` rather than under a
`/<repo>` path.

## Layout

```
site/            Hugo site root
  content/       blog/ · wiki/ · recipes/ + apps.md   (Obsidian vault root)
  layouts/       own layouts — no theme
  archetypes/    per-section front matter templates
  static/        css/, img/, CNAME
scripts/         serve.sh · new.sh
docs/            how to operate this
.hugoversion     Hugo version, read by CI
```

## Quick start

```sh
brew install hugo
./scripts/serve.sh                        # http://localhost:1313
./scripts/new.sh blog "A Post Title"      # new content
git push                                  # publishes
```

## Docs

- **[docs/publishing.md](docs/publishing.md)** — writing, previewing, publishing,
  linking, upgrading Hugo, adding a section
- **[CLAUDE.md](CLAUDE.md)** — the infrastructure decisions and why they were made

## Related

- [twine.brisberg.dev](https://github.com/brisberg/twine.brisberg.dev) — Twine games,
  a separate repo because it serves compiled game artifacts rather than markdown

`blog.brisberg.dev`, `wiki.brisberg.dev`, and `recipies.brisberg.dev` were folded into
this repo as sections and are archived.
