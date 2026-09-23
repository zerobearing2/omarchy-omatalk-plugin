# Omatalk

Local text-to-speech for Omarchy: select text, press F8, the machine reads it
back. A megaphone in the bar follows idle, speaking, and unavailable.

![Omatalk config panel](preview.png)

## Requirements

This plugin is the bar widget and config panel. Speech itself is the Omatalk
Daemon (`omatalkd`) in [zerobearing2/omatalk](https://github.com/zerobearing2/omatalk).
The plugin does not work without that Daemon. It does not start, stop, or
parent it.

- Omarchy with Quickshell plugin support.
- The Omatalk Daemon: uv, Kokoro models (~185MB), a systemd user unit,
  PipeWire, and wl-clipboard. If the Daemon is missing, the panel shows the
  install command to paste into a terminal.
- No sudo. No pkexec. The plugin does not start a second Quickshell process.

## Install

```sh
omarchy plugin add https://github.com/zerobearing2/omarchy-omatalk-plugin.git --enable
```

Then install the Daemon from a terminal. The panel shows this command, with
a copy button, until the Daemon is installed:

```sh
curl -fsSL https://omatalk.zerobearing.com/install.sh | bash
```

The plugin never downloads or runs an installer itself. Later Daemon updates
are `omatalk upgrade`. Models are about 185MB.

If the megaphone is missing or the panel still looks like an older checkout,
reload the bar:

```sh
omarchy restart shell
```

The site is also a complete door for the Daemon, the launcher, and this plugin.
See [zerobearing2/omatalk](https://github.com/zerobearing2/omatalk).

## Update

QML only:

```sh
omarchy plugin update zerobearing.omatalk --yes
```

Daemon, models, and unit:

```sh
omatalk upgrade
```

A Daemon upgrade does not rewrite a git-managed plugin checkout. A plugin
update does not rebuild the venv or stop the Daemon. Restart the shell after
a plugin update if the panel still shows the previous QML.

## Remove

```sh
omarchy plugin remove zerobearing.omatalk --yes
```

Plugin remove unloads the megaphone and deletes this checkout. It leaves the
Daemon, the venv, the models, and your config. F8 still speaks.

Full teardown (unit, launcher, plugin, optional models, config, and the F8
binding) is `omatalk uninstall`.

The Daemon installer never edits `config.toml`. It asks before adding its F8
line to `~/.config/hypr/bindings.lua`, and uninstall asks before removing it.

## Development

This repository is the plugin. The Daemon, CLI, and site live in
https://github.com/zerobearing2/omatalk and release on their own. Default
branch is `master`. To release, bump `version` in `manifest.json`, then:

```sh
git commit -am "Release vX.Y.Z"
git push
gh release create vX.Y.Z --generate-notes
```

CI runs the tests on push:

```sh
./tests/run.sh
```

`omarchy plugin add` clones this whole git tree, including tests. The shell
only loads the QML entry points in `manifest.json`.

Version lives in `manifest.json`. The panel shows it next to the installed
Daemon version (`omatalk version`).
