# Changelog

All notable changes to **AmigaLoginScreen** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.1_7] - 2026-08-20

### Added
- **Target Selection Settings**: Users can now choose whether to apply images to:
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
- Initial release of AmigaLoginScreen Droplet and CLI utility.
