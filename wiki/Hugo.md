# Hugo

[Hugo](https://gohugo.io) is a Static-Site-Generator written in [Go](https://golang.org/). It claims to be the fastest SSG there is because it is based on Golang's templating libraries.

It can be used to generate beautiful static websites and comes with a number of themes to choose from.

## Installation

I chose the simplest installtion for MacOs by using HomeBrew.

```bash
brew install hugo
```

### Modules

There is another way to use hugo based on Go Modules. This is the future, but it says it isn't fully tested yet. I may switch to it in the future.

Until then the default way to install themes is with Git Submodules.

## Themes

### Minimal

Following in [nikitavoloboev](https://nikitavoloboev.xyz)'s example I am using the [Minimal](https://github.com/calintat/minimal) theme for now.

It has a simple, clean interface and a reasonable amount of features.

### Customizing

You can customize nearly anything you like about Hugo (and then export that as a theme if you wish). Or you can layer your changes on top of an existing theme.

Hugo makes a bunch of assumptions about the structure of your site, as all of your content pages will be under the `content/` directory. Depending on which subdirectory you choose it will interpret the content type. You can override this with a [Front Matter](https://gohugo.io/content-management/front-matter/), basically a YAML block at the top of the markdown file which Hugo will use when generating. The `Front Matter` can override most things.

It is useful to examine the theme for which layouts / config params it is looking for. These isn't a clean declaration of all the options available. See [variables](https://gohugo.io/variables/) docs for existing builtin Hugo variables at the Site and Page level.

Some useful ones:
- Type: Override the inferred content type, meaning you can use a different template
- Slug: Override the url slug used (default is the file name). E.x. `/pages/apps-slug`.
- Url: Override the url from the site root to this page. E.x. `/pages/apps -> /apps`. This can create circular references so be careful.
