# Omatalk plugin

Omarchy bar widget for Omatalk: megaphone in the bar, setup/config panel.
The Daemon, CLI, and site live in `zerobearing2/omatalk`. See `CONTEXT.md`.

## Tests

```sh
make test
```

`omarchy plugin validate .` must pass on this checkout. QML tests need
`qmltestrunner` (skipped with a note when it is not installed).
