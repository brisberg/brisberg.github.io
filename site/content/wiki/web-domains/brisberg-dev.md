---
weight: 3
title: "Custom Domain: brisberg.dev"
description: "The complete DNS record inventory for brisberg.dev, and why each record exists"
---

`brisberg.dev` is registered at [Squarespace Domains](google-domains.md) (originally
Google Domains) and uses the registrar's own name servers. Content is served by
[GitHub Pages](github-pages.md); the domain sends and receives no mail.

Every record in the zone is listed below. If a record is not in this table, it does
not belong there.

## Record inventory

| Type | Host | Value | Reason |
|---|---|---|---|
| `A` | `@` | `185.199.108.153` | GitHub Pages apex IP. All four are required — Pages load-balances across them, and omitting any reduces availability. |
| `A` | `@` | `185.199.109.153` | As above. |
| `A` | `@` | `185.199.110.153` | As above. |
| `A` | `@` | `185.199.111.153` | As above. |
| `CNAME` | `www` | `brisberg.github.io.` | Main site. Points at the *user* Pages site, not `ghs.googlehosted.com` — see the synthetic-records warning in [Registrars](google-domains.md). |
| `CNAME` | `twine` | `brisberg.github.io.` | Project Pages deployment for the `twine` repo. |
| `CNAME` | `friday-fellows` | `brisberg.github.io.` | Project Pages deployment for the `friday-fellows` repo. |
| `CNAME` | `tqvcie7rmzpe` | `gv-4y3lg2k2ychwgg.dv.googlehosted.com.` | **Google Search Console ownership verification. Do not delete.** See below. |
| `TXT` | `@` | `v=spf1 -all` | SPF: no host anywhere is authorized to send mail as `brisberg.dev`. |
| `TXT` | `_dmarc` | `v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s` | DMARC: receivers should reject anything claiming to be from this domain or any subdomain. |
| `TXT` | `*._domainkey` | `v=DKIM1; p=` | Null DKIM: declares that no valid signing keys exist for any selector. |

There is deliberately **no `MX` record** — not by choice, see
[the missing null MX](#the-missing-null-mx) below.

TTLs are left at the Squarespace defaults. The verification `CNAME` carries a 5-minute
TTL inherited from Google Domains, which makes it cheap to roll back if touched.

## The mystery `CNAME` is not a leftover

`tqvcie7rmzpe` → `gv-4y3lg2k2ychwgg.dv.googlehosted.com` looks like orphaned junk. It
is not. It is the live ownership verification for the Google Search Console property,
created by the **"Domain name provider"** verification method while Google Domains was
the registrar. Search Console reports it as *Successfully Verified*.

Two things that make it look dead but aren't:

- **The target does not resolve.** `gv-4y3lg2k2ychwgg.dv.googlehosted.com` returns
  `NXDOMAIN` authoritatively from `ns1.google.com`. This is the normal steady state —
  Google verifies by reading the `CNAME`'s own record data, so the target never needs
  to resolve to anything.
- **The hostname is meaningless.** `tqvcie7rmzpe` is just a verification token. Nothing
  is served from it and no mail arrives at it.

Deleting it unverifies the Search Console property and loses access to the search data
until re-verified. To confirm the current owners:
`https://www.google.com/webmasters/verification/details?domain=brisberg.dev`, or
Search Console → property → *Settings* → *Ownership verification*.

If the record ever needs to go, migrate first: add a Search Console **Domain property**
verified by a `google-site-verification=...` `TXT` record at the apex, confirm it
verifies, *then* delete the `CNAME`. A `TXT` record is self-documenting on later audits,
and a Domain property covers every subdomain and both protocols instead of one URL
prefix.

## Why the mail records exist on a domain with no mail

A domain with no `MX`, no SPF and no DMARC is trivially spoofable — anyone can send
mail claiming to be `@brisberg.dev` and receivers have no published policy to check it
against. The three `TXT` records close that off. They were added 2026-09-26; before
that, the zone had no `TXT` or `MX` records at all.

Notes on the specific choices:

- **`p=reject` immediately, not the usual `p=none` ramp.** The monitor-first ramp exists
  to avoid breaking legitimate senders. This domain has none — GitHub Pages does not
  send mail — so the ramp buys nothing but delay.
- **No `rua=` reporting address.** Sending aggregate reports to a `gmail.com` address
  from a `brisberg.dev` record is cross-domain reporting, which
  [RFC 7489 §7.1](https://datatracker.ietf.org/doc/html/rfc7489#section-7.1) requires
  the *receiving* domain to authorize by publishing
  `brisberg.dev._report._dmarc.gmail.com`. That is not possible here, so conforming
  reporters would refuse. For a domain with no legitimate mail the reports would be
  pure spoofing noise anyway.
- **`sp=reject` does the subdomain work.** `www`, `twine` and `friday-fellows` are all
  `CNAME` records, and a `CNAME` must be alone at its name — no per-subdomain `TXT` or
  `MX` is possible. The apex DMARC policy covers them instead.
- **Check for registrar mail presets.** If Squarespace email forwarding or a one-click
  Google Workspace `MX` option is enabled for this domain, it will add `MX` records and
  quietly make the domain look mail-capable again.

**This configuration means the domain sends no mail and delivers none.** To add
`you@brisberg.dev` later, rewrite SPF to authorize the chosen provider and add its `MX`
records. That is a five-minute change, not a one-way door.

## The missing null MX

The intended configuration included a null `MX` record
([RFC 7505](https://datatracker.ietf.org/doc/html/rfc7505)) — host `@`, priority `0`,
value `.` — which declares that a domain accepts no mail at all.

**Squarespace rejects it** with *"Enter valid mail server"*. Its DNS editor validates
the `MX` value as a hostname, and `.` is not one. There is no way to add it through the
UI.

The consequence is not cosmetic. With no `MX` record present,
[RFC 5321 §5.1](https://datatracker.ietf.org/doc/html/rfc5321#section-5.1) has senders
fall back to the domain's `A` records as an **implicit MX** — so mail addressed to
`@brisberg.dev` is attempted against the GitHub Pages IPs on port 25. Those hosts
refuse the connection, so the mail bounces and nothing is delivered, but "no `MX`" is
not equivalent to "null `MX`": the domain looks potentially mail-capable, and delivery
attempts land on someone else's infrastructure.

This is accepted as-is. Spoofing protection comes entirely from the SPF and DMARC
records, which are unaffected, and the end result is still non-delivery.

**Do not work around it with a placeholder hostname** such as `nomail.brisberg.dev`.
An `MX` pointing at a name that does not resolve is *worse* than no `MX` — senders
generally treat that as a temporary failure and queue-and-retry for days instead of
bouncing immediately.

The only reliable fix is delegating DNS to a provider that accepts `0 .`, such as
Cloudflare or Route 53. Moving name servers to convert a slow bounce into a fast one is
not worth it.

## Verifying the zone

```sh
dig +short brisberg.dev A            # expect the four GitHub Pages IPs
dig +short www.brisberg.dev CNAME    # expect brisberg.github.io.
dig +short brisberg.dev TXT          # expect v=spf1 -all
dig +short _dmarc.brisberg.dev TXT   # expect the DMARC policy
dig +short brisberg.dev MX           # expect empty (see: the missing null MX)
```

Allow for the record TTL before trusting a negative result.
