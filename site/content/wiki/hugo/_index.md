---
weight: 1
title: "Hugo"
---

[Hugo](https://gohugo.io) is a Static-Site-Generator written in [Go](https://golang.org/). It claims to be the fastest SSG around because it is based on Golang's `html/templating` libraries.

It can be used to generate beautiful static websites and comes with a number of themes to choose from.

## Installation

I chose the simplest installation for macOS, using Homebrew.

```bash
brew install hugo
```

Pin the version somewhere the build reads too, so your machine and CI cannot drift
apart. This site keeps it in a `.hugoversion` file at the repo root.

{{< details "Installing themes" closed >}}
Themes can be vendored as [Git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
or pulled in as [Hugo Modules](https://gohugo.io/hugo-modules/), which is the modern
approach and no longer experimental.

I use neither — this site has no theme, and its layouts live in `site/layouts/`.
Three abandoned theme submodules and a config still describing a theme I had already
swapped out was what finally convinced me that for a site this small, owning ~150
lines of HTML is cheaper than maintaining someone else's abstraction.
{{< /details >}}

### Customizing

You can customize nearly anything you like about Hugo (and then export that as a theme if you wish). Or you can layer your changes on top of an existing theme.

Hugo makes a bunch of assumptions about the structure of your site, as all of your content pages will be under the `content/` directory. Depending on which subdirectory you choose it will interpret the content type. You can override this with a [Front Matter](https://gohugo.io/content-management/front-matter/), basically a YAML block at the top of the markdown file which Hugo will use when generating. The `Front Matter` can override most things.

It is useful to examine the theme for which layouts / config params it is looking for. These isn't a clean declaration of all the options available. See [variables](https://gohugo.io/variables/) docs for existing builtin Hugo variables at the Site and Page level.

Some useful ones:
- Type: Override the inferred content type, meaning you can use a different template
- Slug: Override the url slug used (default is the file name). E.x. `/pages/apps-slug`.
- Url: Override the url from the site root to this page. E.x. `/pages/apps -> /apps`. This can create circular references so be careful.
