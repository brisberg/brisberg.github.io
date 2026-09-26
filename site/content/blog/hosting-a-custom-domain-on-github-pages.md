---
title: "Hosting a Custom Domain on GitHub Pages"
date: 2020-11-09
draft: true
description: "Pointing a purchased domain at GitHub Pages, including subdomains for project repos."
tags: ["github-pages", "dns", "hugo"]
---

<!-- DRAFT NOTES — remove before publishing:
  - Written in 2020 against Google Domains, which no longer exists (sold to
    Squarespace in 2023). The registrar half needs rewriting; the DNS and Pages
    mechanics are still accurate.
  - The subdomain-per-project advice at the end is advice I have since reversed.
    See the consolidation: blog/wiki/recipes are now sections of one site. That
    reversal is arguably the more interesting post.
  - Two orphaned screenshots exist in the old blog repo history
    (Screen Shot 2020-11-09 at 12.34.{17,37} PM.png) for the "TLS progress"
    placeholder below. Decide whether to use them or cut the placeholder.
-->

Hosting a personal website on GitHub Pages with a custom domain.

## Buying a domain

I bought mine from Google Domains, which had the best selection and lowest prices at
the time. Google had recently launched several of their own top-level domains —
`.page`, `.dev`, `.studio`, `.tech`, `.design` — and `.dev` fit a developer's web
presence best.

`.dev` is on the [HSTS preload list](https://hstspreload.org/), so it is *always*
served over HTTPS. Browsers refuse to load it over plain HTTP.

## Pointing the domain at GitHub

GitHub hosts a "root" Pages site for the repo named `<user>.github.io`, served at
`https://<user>.github.io`. Applying a custom domain to that repo applies it to every
other repo you host on Pages:

```
https://<user>.github.io/<repo>  =>  https://mycustom.domain/<repo>
```

Configuring DNS takes two records. Any DNS provider works the same way.

1. Apex `A` records pointing directly at the four GitHub Pages IP addresses. GitHub
   documents the current
   [set of addresses](https://docs.github.com/pages/configuring-a-custom-domain-for-your-github-pages-site).
2. A `CNAME` record for the `www` subdomain pointing at `<user>.github.io`.

Changes can take up to 48 hours to propagate, though in practice it was much faster.

One thing that did *not* work: Google Domains' built-in forwarding rules. They direct
to `ghs.googlehosted.com` instead of `<user>.github.io`, which Pages does not
recognize. Use plain resource records.

Once the records are in place, enable **Enforce HTTPS** in the repo's Pages settings.
GitHub provisions a Let's Encrypt certificate automatically; mine took about 30
minutes.

<!-- Image of TLS provisioning progress -->

## Subdomains for project repos

Once the root Pages repo is set up, other repositories can be served from
subdomains rather than paths:

```
https://mycustom.domain/<repo>  =>  https://<repo>.mycustom.domain/
```

Add a second `CNAME` record for the subdomain, also pointing at `<user>.github.io` —
**not** at the repo path. The repo itself tells GitHub which host it answers to, via a
`CNAME` file at the root of the published output containing the full subdomain.

That file takes 15–60 minutes to take effect, after which you enable **Enforce HTTPS**
again and wait out another certificate provisioning round.
