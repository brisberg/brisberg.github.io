# Custom Domain

I have purchased a custom domain name for hosting this blog: [brisberg.dev](https://brisberg.dev)

Purchased from [Google Domains](https://domains.google/).

After some playing around, I followed [GitHub's Guide](https://docs.github.com/en/free-pro-team@latest/github/working-with-github-pages/configuring-a-custom-domain-for-your-github-pages-site) for setting up a custom domain for GitHub Pages.

The built in Google Domain forward rules didn't work. It directs to `ghs.googlehosted.com` instead of `brisberg.github.io`. Also I had to add `ALIAS` (`A`) rules towards the 4 IPs provided by Github.

I needed to wait nearly 30 min for Github to provision new TLS Certificates but it now works over `https`.
