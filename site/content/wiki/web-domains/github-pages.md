---
weight: 1
title: "GitHub Pages"
---

[GitHub Pages](https://pages.github.com/) is a static file hosting offering from GitHub to host content directly out of a GitHub Repository.

Pages is free for public repos with GitHub Free.

By default, GitHub Pages are hosted at `<user>.github.io/<repository>`.

## Configuration

GitHub Pages must be enabled in your Repository Settings page. Visit `Settings > Options > GitHub Pages`.

Select a source branch to build GitHub Pages. It can either build from the branch root `/` or the `/docs` directory. Only these two roots are usable. If you need to build your docs from another path consider using a [GitHub Action](https://github.com/features/actions) to push that directory onto another branch to build from the root of that branch.

Convention dictates the branch to build GitHub Pages from be `gh-pages`, but any branch can be specified.

## Custom Domain

GitHub Pages can be hosted from a Custom Domain (i.e. `brisberg.dev`).

Purchase a [custom domain name](/wiki/web-domains/#purchase-a-domain-name) from a registrar such as [Google Domains](https://domains.google/).

Point that Domain to `<user>.github.io` and add a CNAME file to the root of your pages branch which contains your domain.

See [blog post](/blog/hosting-a-custom-domain-on-github-pages/index.md) for details.

### User Pages

There is an optional side benefit for creating a User GitHub Pages site with a custom domain name.

If you create a special repository called `<user>.github.io`, this will be a User GitHub Pages site. It will be hosted at `<user>.github.io` directly, instead of `<user>.github.io/<user>.github.io`.

Specifying a CNAME in this repository will automatically apply to all other GitHub Pages hosting of all other GitHub repositories you own.

For example:
- Specify a CNAME of `www.mydomain.com` for `<user>.github.io`.
- Then another project hosted on GitHub Pages will be accessible at `www.mydomain.com/<repository>` instead of `<user>.github.io/<repository>`.
