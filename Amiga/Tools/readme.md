# 🕹️ Amiga Tools for macOS

A collection of native macOS utility applications, command-line tools, and QuickLook plugins built for Amiga enthusiasts and developers.

Live interactive showcases, details, and video demos live on the **[Amiga Dev Hub](https://ginnov.github.io/littlethings/amiga/index.html)**.

---

## 📂 Tools Directory Guide

| Project | Type | Description | Links |
| :--- | :--- | :--- | :--- |
| **[ADFinder](./ADFinder/)** | macOS App | The ultimate ADF manager and disk manipulator for macOS. | [README](./ADFinder/README.md) · [Releases](./releases/) |
| **[amigaLoginScreen](./amigaLoginScreen/)** | macOS Droplet / CLI | Formats and sets classic Amiga Kickstart boot screens as wallpaper and lock screen. | [README](./amigaLoginScreen/README.md) · [Releases](./releases/) |
| **[AmigaROMExplorer](./AmigaROMExplorer/)** | macOS App | Comprehensive Amiga ROM & firmware atlas with local ROM matching. | [README](./AmigaROMExplorer/README.md) · [Releases](./releases/) |
| **[AuDeluxe](./AuDeluxe/)** | macOS App / QuickLook | Modern player & QuickLook preview for Amiga audio formats (MOD, etc.) via OpenMPT. | [README](./AuDeluxe/README.md) · [Releases](./releases/) |
| **[IFFViewer](./IFFViewer/)** | QuickLook Plugin | Modern macOS QuickLook preview extension for Amiga IFF images in Finder. | [README](./IFFViewer/README.md) · [Releases](./releases/) |
| **[PixDeluxe](./PixDeluxe/)** | macOS App | IFF image manager, format inspector, and PNG batch converter. | [README](./PixDeluxe/README.md) · [Releases](./releases/) |
| **[send2adf](./send2adf/)** | C CLI Utility | Lightweight terminal tool to dynamically package files or directories into bootable ADFs. | [README](./send2adf/README.md) |
| **[AmigaPlayground](../aMiLa/AmigaPlayground/)** | macOS App | 68k assembly workspace with local MLX AI assistant, compiler, and emulator integration. | [README](../aMiLa/AmigaPlayground/README.md) · [Releases](./releases/) |

---

## 📦 Precompiled Releases

Precompiled `.dmg` installers and `.zip` archives are available in the **[releases/](./releases/)** folder:

👉 **[Browse Compiled Releases](./releases/readme.md)**

> [!TIP]
> Most builds are Universal Binaries (`arm64` Apple Silicon + `x86_64` Intel Macs). For instructions on removing macOS quarantine on first launch, see the [Quarantine Guide](https://ginnov.github.io/littlethings/amiga/index.html#remove-quarantine).

---

## 🧪 Testing Notes

Amiga-side code and disk outputs are verified using [vAmiga](https://dirkwhoffmann.github.io/vAmiga/), [FS-UAE](https://fs-uae.net/), and real Amiga 1200 / 500 hardware.
