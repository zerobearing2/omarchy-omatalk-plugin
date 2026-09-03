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

## Release

Version is `manifest.json`. `make bump` (or `make bump VERSION=x.y.z`) commits
it; push, then `make release` to run tests and cut the GitHub release.
