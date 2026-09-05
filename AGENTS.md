# Omatalk plugin

Omarchy bar widget for Omatalk: megaphone in the bar, setup/config panel.
The Daemon, CLI, and site live in `zerobearing2/omatalk` — required; this
plugin does not parent it. See `CONTEXT.md`. Default branch is `master`.

## Tests

```sh
make test
```

`omarchy plugin validate .` must pass on this checkout. QML tests need
`qmltestrunner` (skipped with a note when it is not installed; required in CI).

## Installer pin

Panel Install fetches, hashes, and runs `install.sh` from a pinned
`zerobearing2/omatalk` commit (`installerUrl` + `installerSha256` in
`Panel.qml`). That script still installs the current GitHub release tarball.
Re-pin when `install.sh` itself changes (`make pin-release`), not merely
because omatalk shipped a new release.

```sh
make pin                 # latest omatalk GitHub release
make pin REF=v0.3.1      # that tag, or a 40-character commit
make pin-release         # pin + plugin version bump, one commit
```

Push, then `make release`. Keep `install.sh` in the Daemon repo, not here.

## Release

Version is `manifest.json`. `make bump` (or `make bump VERSION=x.y.z`) commits
it; push, then `make release` to run tests and cut the GitHub release. When
the change is a newer Daemon installer, `make pin-release` instead of bump
alone.

## Agent skills

### Issue tracker

Issues live as local markdown under `.scratch/<feature>/`. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five canonical triage role strings. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` at root + `docs/adr/`. See `docs/agents/domain.md`.
