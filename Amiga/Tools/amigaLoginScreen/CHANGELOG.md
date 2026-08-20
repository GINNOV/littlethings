# Changelog

All notable changes to **AmigaLoginScreen** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.1] - 2026-08-20

### Fixed
- **Offline Preset Bundling**: Bundled all Kickstart boot screen graphics (1.3, 2.04, 3.1) directly inside the `.app` bundle under `Contents/Resources/Presets/` to prevent external network 403 Forbidden errors when setting default presets.
- **CLI & GUI Dispatching**: Resolved runloop and dispatch queue deadlocks in standalone CLI mode.
- **Image Destination Path**: Improved output directory creation and robust local fallback resolution.

---

## [1.0.0] - 2026-08-20

### Added
- **macOS Droplet & Interactive App**:
  - Drag-and-drop any image or animated GIF directly onto `AmigaLoginScreen.app` to format and apply it instantly.
  - Interactive launcher menu when opening the app directly, offering quick presets or a file picker.
- **Classic Kickstart Presets**:
  - Built-in one-click support for **Kickstart 1.3** (Iconic hand & floppy), **Kickstart 2.04** (Purple insert-disk screen), and **Kickstart 3.1** (Rainbow disk).
  - Bundled directly inside the application bundle for 100% offline reliability (no external network dependencies or 403 hotlink errors).
- **Pixel-Perfect Scaling & Padding**:
  - Preserves 1:1 crisp pixel art with nearest-neighbor scaling (no bilinear fuzziness or blurry smoothing).
  - Automatic corner-pixel sampling to seamlessly blend image borders into widescreen and high-DPI displays.
- **Animated GIF & Multi-Frame Support**:
  - Decodes GIF frames and renders clean centered backgrounds without distortion.
- **Universal Binary**:
  - Native standalone Mach-O binary supporting both Apple Silicon (`arm64`) and Intel (`x86_64`) Macs with zero external dependencies.
- **CLI & Scripting Interface**:
  - Full terminal command-line options (`--help`, `--preset <version>`, `<path_or_url>`).
- **Release Packaging**:
  - Automated release `.dmg` and `.zip` generation.
