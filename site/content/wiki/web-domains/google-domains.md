---
weight: 2
title: "Registrars: Google Domains and Squarespace"
description: "Google Domains is gone. What replaced it, and what carried over."
---

**Google Domains no longer exists.** Google sold its domain registration business to
Squarespace in 2023, and all registrations were migrated to
[Squarespace Domains](https://domains.squarespace.com) over the following months.
Existing registrations carried over automatically, including renewal pricing.

`brisberg.dev` was originally registered with Google Domains and now lives at
Squarespace. Renewal pricing was grandfathered at the original rate.

The rest of this page is kept because the concepts are registrar-independent — the
DNS record types and their behavior are the same everywhere. Only the UI moved.

## What Google Domains offered

- [Privacy Protection](https://whois.icann.org/en/about-whois) — the registrar uses a
  third-party service to alias your personal information in the WHOIS registry.
  Squarespace carries this forward.
- Registrar-operated DNS servers, with the option to delegate to your own
- SSL/TLS certificates
- Custom email forwarding

## DNS configuration

### DNS servers

Registrars default to their own name servers. You can delegate to someone else's
(Cloudflare, Route 53) if you want features the registrar doesn't offer.

### DNSSEC

Domain Name System Security Extensions protect a domain against attacks such as DNS
cache poisoning and DNS spoofing, by signing responses so resolvers can verify they
were not tampered with.

### Synthetic records

Google Domains had "synthetic records" — automatically-generated groupings of
resource records that set up a common feature (domain forwarding, Google Workspace)
in one step.

**These did not work for GitHub Pages hosting.** The subdomain-forwarding synthetic
record directs to `ghs.googlehosted.com` rather than `<user>.github.io`, which is not
what Pages expects. Use plain resource records instead — see
[GitHub Pages](github-pages.md).

### Custom resource records

Resource records define how the domain behaves, and are common to every DNS service:
`A` and `AAAA` records pointing at server IPs, `CNAME` aliases, `MX` for mail, `TXT`
for verification.

For a working configuration example, see [Brisberg.dev](brisberg-dev.md).
