---
title: "Themes"
---

Themes are packages of templates, css, and javascript used by the Hugo engine to produce a Static Site. There are many popular themes to choose from highlighted on [Hugo Themes](https://themes.gohugo.io).

Below are my notes and observations on the few with which I am familiar.

**I no longer use any of them.** [brisberg.dev][] has no theme — its layouts live in
the site repo. The notes below are kept because the comparisons are still useful if I
ever reach for a theme again, and because the way this ended is instructive: I
accumulated three theme submodules, used one, and left the config describing a
different one. See [Hugo](_index.md) for the reasoning.

## Minimal

[Minimal](https://github.com/calintat/minimal) is a simple, clean interface with a
reasonable amount of features.

[nikitavoloboev](https://nikitavoloboev.xyz) uses it for his home site, which is how I
found it; I used it for [brisberg.dev][] for several years before dropping themes
entirely.

## Book
[Book](https://themes.gohugo.io/theme/hugo-book/) is a minimalist theme specialized for documentation websites.

Book has many of the features ideal for a Knowledge Wiki:

- Flexible, tree-based navigation menu
- Simple and effective [shortcodes](https://github.com/alex-shpak/hugo-book#shortcodes)
- Table of Contents for each page
- Git Integration for calculating last edit time and one-click editing.
- Integrated Search using [flexsearch](https://github.com/nextapps-de/flexsearch)
- Light/Dark Theme

I used this theme for the knowledge wiki when it was a separate site at
`wiki.brisberg.dev`. Its content now lives under [/wiki/](/wiki/) and is rendered by
this site's own layouts. Book's tree navigation and built-in search are the two
features I actually miss.

## Zdoc
[Zdoc](https://themes.gohugo.io/hugo-theme-zdoc/) ([Demo](https://zzo-docs.vercel.app/zdoc)) is an opinionated wiki framework for creating documentation websites.

Zdoc differs from Book in the following ways:

- Navigation Menu only displays the current tree level
- Similar [shortcodes](https://zzo-docs.vercel.app/zdoc/shortcodes/)
- Language Dropdown
- Integrated Search using [Fuse.js](https://fusejs.io/)
- Light/Dark Theme toggle

Search experience is better because it includes match previews. Search Index is pre-built at Hugo build time so is fast on the client.

A light/dark theme toggle gives better user control, and saves preference to Local Storage.

However, I found it a bit more cumbersome and visually noisier than I intended. At the time it didn't sit well next to the `Minimal` theme [brisberg.dev][] was using.

My previous attempt to use this theme is preserved in the `zDoc` branch of the
(now archived) [wiki.brisberg.dev](https://github.com/brisberg/wiki.brisberg.dev/tree/zDoc)
repo for posterity.

[brisberg.dev]: https://brisberg.dev
