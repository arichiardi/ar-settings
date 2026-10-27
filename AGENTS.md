# ar-settings: agent guide

Instructions for AI coding agents that work in this repository.

## What this repository is

`ar-settings` holds the author's machine settings, configs, and provisioning
scripts. The repository is the source of truth. Scripts copy files from the
repository into live system locations.

## Layout

The repository keeps three mirror roots. Each root maps to a live location.

| Repo path | Live target | Content |
| --- | --- | --- |
| `home/` | `$HOME` | dotfiles, `.config/`, `.local/bin/`, bash and profile fragments |
| `etc/` | `/etc` | system config such as `gitconfig`, `sudoers.d`, `caddy`, `conf.d` |
| `usr/` | `/usr/local` | helper binaries under `usr/local/bin/`, Emacs site-lisp, icons |

Other paths:

- `bootstrap/` - first-run scripts. They restore GPG keys and config, and clone
  the settings repository on a new machine.
- `initialize/bin/` - numbered scripts that populate `$HOME`.
- `init-*` - per-component installers at the repository root, for example
  `init-i3`, `init-sway`, `init-caddy`, `init-etc`.
- `install-dev-tools` - developer tooling installer.
- `secrets/` - KeePass databases (`.kdbx`). Never touch these files.
- `home/.config/llm/prompts/` - prompt templates.
- `home/.config/pi/` - pi coding agent configuration that mirrors `~/.config/pi`.

## Safety rules

These rules are critical. Violation changes the live machine or destroys data.

1. Never run a script that mutates the live system autonomously. That set is a
   judgment call that the user and the agent decide per case. It includes
   `bootstrap/bin/*`, `initialize/bin/*`, root `init-*` scripts, and
   `install-*` scripts. Ask the user before any such script runs.
2. Never decrypt, move, rename, or edit `secrets/*.kdbx`, `etc/*.gpg`,
   `etc/*.enc`, `etc/**/*.enc`, or files under `home/.gnupg`.
3. Never write outside the repository working tree without explicit user
   approval. Editing a file in `home/` or `etc/` is a repository edit. Editing
   `$HOME` or `/etc` directly is a live-system edit.
4. Never run `secret`, `secrets-*`, or `vault-*` helpers. They wipe the source
   file after a successful copy.
5. Treat the `initialize` scripts as merge tools. They run `vimdiff` against
   live files. They are interactive and destructive.

## Private config and data

Never commit a private value in plaintext. Private values include a custom
domain, hostname, IP address, token, key, account identifier, and network
detail. When you see one, stop and ask the user, and propose to encrypt the
file.

`gpg-backup-to-repo` snapshots a live machine file into the repository as
`<repo_path>.gpg`. Prefer `.gpg` files. Add a `"<machine_path>:<repo_path>"`
entry to its `files` array and run it from the repository root.

## Script conventions

- Use `#!/usr/bin/env bash`. Every script sets `set -euo pipefail`.
- Root `init-*` scripts run from the repository root. They source
  `./usr/local/bin/ar-helpers.sh`.
- `initialize/bin/*` scripts resolve `repo_root` from `git rev-parse` and must
  run from inside the repository.
- Use the helper functions for output and guards:
  - `echo_info`, `echo_warn`, `echo_fail`, `echo_ok` for messages.
  - `confirm "message"` before a system change. It is a no-op when stdin is not
    a terminal.
  - `pkg_detect` and `pkg_run` for package operations. They support pacman, yay,
    apk, apt-get.
- Keep scripts idempotent. A second run must not corrupt state.
- Keep the existing numbered `NN-name` ordering in `bootstrap/bin` and
  `initialize/bin`.

## Testing and verification

Verify changes as follows.

1. Check shell syntax for each changed script:
   ```shell
   bash -n path/to/script
   ```
2. Check whitespace and conflict markers:
   ```shell
   git diff --check
   ```
3. For config files, compare the repository file with the live file before you
   propose a change:
   ```shell
   git diff --no-index "$HOME/.config/foo" home/.config/foo
   ```
4. State which checks you ran. Do not claim a script works. Say that syntax
   passes and that runtime behavior needs the user's machine.

## Git conventions

- Write concise, imperative commit messages.
- Commit signing is enabled. Do not disable it.
- Never use `git commit --amend` or `git push --force` without explicit user
  confirmation.
- Keep unrelated changes out of a commit. The user may have uncommitted work in
  the tree. Check `git status` before you stage.

## Editing rules

- Edit files under `home/`, `etc/`, and `usr/` as repository files. Do not copy
  them into place. The user runs the init scripts.
- Preserve the mirror layout. A file in `home/.config/x` belongs to
  `$HOME/.config/x`.
- Do not reformat existing config files. Change only the lines that the task
  needs.
- Do not add a `README.md` section for a change unless the user asks.

## Error handling

- On failure, report the exact command and the exact error. Propose the minimal
  fix. Retry at most 3 times.
- If a task needs a live-system change, stop and ask. Do not work around a
  sandbox restriction.
- If a referenced tool is missing, fall back to a plain shell equivalent and say
  so.

## Success criteria

A change is complete when:

1. The repository edit matches the requested behavior.
2. `bash -n` passes for each changed script.
3. `git diff --check` reports no problems.
4. The user knows which steps still require a live machine.
