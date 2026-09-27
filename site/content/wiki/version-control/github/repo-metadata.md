---
title: "Repository Metadata"
description: "Setting a repo's description, website, and topics — the About panel — from the command line instead of the settings UI."
weight: 1
generated: claude
---

The **About** panel on a repository's main page holds three editable fields: the
description, the website, and the topics. By default you set them by clicking the
gear icon next to "About", once, by hand, for every repository you create.

All three can be set from the command line. None of them can be set from a file in
the repository.

## Why there is no file for this

The About fields are not git content. They are columns on GitHub's repository record,
which is why they survive a force-push, why they don't appear in a clone, and why
nothing you commit will change them.

This is the part that catches people out, because `.github/` looks like it should be
the answer. It isn't — that directory holds *community health files*
(`CONTRIBUTING.md`, `SECURITY.md`, `FUNDING.yml`, `ISSUE_TEMPLATE/`, and workflows),
and none of them touch the About panel.

A few repository files *do* render into that sidebar, which muddies the picture
further:

- `LICENSE` — detected by [licensee](https://github.com/licensee/licensee) and shown
  as a license badge
- `CITATION.cff` — adds a "Cite this repository" button
- `README.md` — rendered below the file list, not in the panel

None of these set the description, the website, or the topics.

## Setting it with the `gh` CLI

The shortest path. [`gh repo edit`](https://cli.github.com/manual/gh_repo_edit)
covers all three fields:

```bash
gh repo edit brisberg/some-repo \
  --description "A one-line summary of the project" \
  --homepage "https://brisberg.dev" \
  --add-topic hugo --add-topic static-site --add-topic typescript
```

`--add-topic` and `--remove-topic` are incremental, which is what you usually want.
The same command also toggles issues, the wiki, visibility, and the default branch.

## Setting it with the REST API

Useful in a script that shouldn't depend on `gh`, or when you want to see exactly
what is being sent. Note that these are **two different endpoints** — topics are not
part of the repository object:

```bash
# description and homepage
gh api -X PATCH repos/brisberg/some-repo \
  -f description='A one-line summary of the project' \
  -f homepage='https://brisberg.dev'

# topics — this REPLACES the entire list, it is not additive
gh api -X PUT repos/brisberg/some-repo/topics \
  -f 'names[]=hugo' \
  -f 'names[]=static-site'
```

That `PUT` is the sharp edge: send one topic and the other five are gone. If you are
scripting it, `GET` the current list first and merge, or just use `gh repo edit
--add-topic`.

Authentication needs a token with the `repo` scope, or a fine-grained token with
**Administration: write** on the repository. The `GITHUB_TOKEN` available inside
GitHub Actions does **not** have this permission, which matters below.

### Field constraints

| Field | Limit |
|---|---|
| Description | 350 characters |
| Topics | 20 per repository |
| Topic name | 50 characters; lowercase letters, numbers and hyphens; must start with a letter or number |

Topics submitted with capitals are lowercased rather than rejected.

## Making it a file anyway

If you genuinely want this declared in the repository, there are two ways, both with
real costs.

**The Settings app.** [repository-settings/app](https://github.com/repository-settings/app)
is a GitHub App that reads `.github/settings.yml` and syncs it to the repository on
push:

```yaml
repository:
  description: "A one-line summary of the project"
  homepage: "https://brisberg.dev"
  topics: hugo, static-site, typescript
```

The cost is that you install an app with administrative write access across your
repositories, and anyone who can push to the default branch can now change
repository settings. On a personal account that is usually fine. In an organisation
it is a privilege-escalation path worth thinking about first.

**Your own workflow.** A job triggered on changes to a metadata file, calling the two
API endpoints above. About twenty lines, no third party — but it needs a personal
access token in repository secrets, because `GITHUB_TOKEN` cannot edit repository
settings. And it has to be maintained in every repository that uses it.

## Setting it at creation time instead

Worth weighing before automating any of the above: these fields are written once and
then essentially never change. A sync mechanism solves a maintenance problem that
doesn't exist, and adds a file, a token, and an app to every repository in order to
automate a single write.

The friction is at creation. That can be fixed in one place, on one machine, with no
repository-side moving parts at all:

```bash
# newrepo <name> <description> <topic>...
newrepo() {
  local name="$1" desc="$2"; shift 2
  gh repo create "$name" --public --description "$desc" \
    && gh repo edit "$name" --homepage "https://brisberg.dev" \
         "${@/#/--add-topic }"
}
```

Creating a repository from a template does not carry the template's description or
topics across, so a template repository is not a substitute for this.

## Managing many repositories

Past a dozen or so repositories that need to stay consistent, the
[Terraform GitHub provider](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository)
is the tool that actually fits. `github_repository` exposes `description`,
`homepage_url`, and `topics`, and the desired state lives in one place rather than
scattered across N repositories — which is the thing `.github/settings.yml` never
gives you.

Below that threshold it is a state file and a provider upgrade cadence in exchange
for a field you set once.
