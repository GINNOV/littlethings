# Changelog

All notable changes to **Amiga Login Screen** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.1_8] - 2026-08-20

### Added
- **Display Name**: Set application bundle and installer name to **Amiga Login Screen.app** in the Applications folder.
- **Custom Floppy App Icon**: Generated and configured a high-resolution 3.5" Amiga micro floppy disk icon featuring an embedded glowing Kickstart 1.3 screen (`AppIcon.icns`).
- **About Dialog**: Added an About dialog accessible directly from the main menu, displaying version/build metadata, credits to Mario Esposito, and direct links to:
  - 🌐 Classic Kickstart Boot Screens ([amiga.lychesis.net](https://amiga.lychesis.net/applications/Kickstart.html))
  - 🐛 Bug reports and feature suggestions ([GINNOV/littlethings](https://github.com/GINNOV/littlethings/issues))
  - 🕹️ [littlethings](https://github.com/GINNOV/littlethings) collection

---

## [1.0.1_7] - 2026-08-20

### Added
- **Target Selection Settings**: Users can choose whether to apply images to:
  - `🔒 Lock Screen Only` (**Default**)
  - `🖥️ Desktop Wallpaper Only`
  - `🔄 Both (Desktop & Lock Screen)`
- **GUI Setting Dropdown**: Added an `Apply to:` accessory popup menu in the main interactive droplet dialog that persists the user's choice to `UserDefaults`.
- **CLI `--target` Flag**: Added `--target <lockscreen|desktop|both>` (or `-t`) flag in the CLI utility.
- **Automated Unit Tests**: Added unit tests in `AmigaLoginScreenUITests.xctest` verifying target mode default values, persistence, and description localization.

---

## [1.0.1_6] - 2026-08-20

### Fixed
- **Multi-Frame Animated GIF Support**: Rebuilt the ImageIO rendering engine to iterate over and pad every single frame in animated GIFs, preserving frame delays, loop counts, and outputting `amiga_lockscreen.gif` alongside a static `amiga_lockscreen.png` fallback.
- **Full-Screen Integer Scaling**: Removed the artificial `2.0` scale cap, allowing retro artwork to scale to full display height (e.g. 6016x3384 Retina display resolution).

---

## [1.0.0_1] - 2026-08-20

### Added
- Initial release of Amiga Login Screen Droplet and CLI utility.
