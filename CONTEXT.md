# Omatalk plugin

Bar chrome for Omatalk on Omarchy. This repository is the widget and panel.
Speech itself is the Daemon in https://github.com/zerobearing2/omatalk.

## Language

**Daemon**:
The always-running local process that holds the TTS model warm. It lives in
https://github.com/zerobearing2/omatalk (`omatalkd`). This plugin does not
start it, stop it, or parent it. Installed means `~/.local/bin/omatalk`
exists (the launcher the Daemon installer writes). Do not use
`command -v omatalk` as the only probe.
_Avoid_: server, service (the systemd unit wraps the Daemon but is not the term)

**Utterance**:
One unit of speech. The panel preview shells `omatalk speak`; F8 does the same
without the panel.
_Avoid_: request, job, playback

## Bar states

- Not installed: normal color, tooltip "Omatalk is not installed". No socket
  follow, no unavailable.
- Installed and follow connected: idle / speaking.
- Installed and follow failed past a three-second grace, or Daemon `error`:
  unavailable (urgent).

## Panel states

- Not installed: setup (Install fetches a pinned `install.sh` from
  zerobearing2/omatalk, verifies SHA-256, and runs it in Omarchy's floating
  terminal). Plugin version from `manifest.json`. No `omatalk config` /
  `version` / preview `speak`.
- Installed: voice, speed, plugin version, Daemon version (`omatalk version`).
  Config CLI uses `~/.local/bin/omatalk`.
