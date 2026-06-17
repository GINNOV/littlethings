# Amiga ROM Explorer

Browse a shipped reference catalog of Amiga firmware — Kickstart, extended ROM, boot ROM, bootstrap, and cartridge images — with hardware mapping, history, and technical notes.

## Install

1. Drag **AmigaROMExplorer.app** to **Applications**.
2. Open the app and complete the setup wizard.
3. Use **reference catalog mode** immediately, or scan your own legally obtained ROM folder later.

## Quarantine flag

Unsigned builds may be blocked by Gatekeeper. Remove the quarantine attribute:

```bash
xattr -rc /Applications/AmigaROMExplorer.app
```

Or use [Sentinel](https://github.com/alienator88/Sentinel) to manage quarantine visually.

Enjoy exploring Amiga firmware history.