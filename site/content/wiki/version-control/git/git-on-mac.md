---
title: "Git on Mac"
weight: 1
---

I am investigating how to support automatic authentication for two different GitHub logins.

## Apple's forked version of Git

Apple maintains their own version of Git for deployment on their machines. One of the things this does is force include a `gitconfig` file. (located at `/Applications/Xcode.app/Contents/Developer/usr/share/git-core/gitconfig`)

```bash
$ git --version
# git version 2.24.3 (Apple Git-128)
```

This config sets the `credential.helper` field to `osxkeychain` to use the built-in OSX keychain helper.

Normally this would be fine for a single GitHub login across your whole system, but there is no way to override this.

A suggestion is to use Homebrew to install normal `git` which will use any config scheme you ask for.

```bash
$ brew install git
# brew install output omitted

# open a new shell
$ git --version
git version 2.29.2
```

[Suggestion to use Homebrew installed Git](https://stackoverflow.com/q/34005353#comment55770768_34005353)

Then you can use split Config files to access different credential sources.

https://stackoverflow.com/a/43884702

This lets you use a different config file based on directory.

### Links

- [Directory Based Configs](https://stackoverflow.com/a/43884702)
- [IncludeIF Suggestion](https://deepsource.io/blog/managing-different-git-profiles/)

## Alternatives

You can simply pass the "useHttpPath" to the `osxkeychain` helper so that it matches each full URL. This means you need to enter your password for each repository.

This isn't ideal, especially because 2-factor auth requires a PAT instead of a password. So it is hard to remember the password.

[Guide](https://coderwall.com/p/9ub-6a/using-multiple-accounts-with-git-or-github)
