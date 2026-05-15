#!/usr/bin/env python3
import argparse
import subprocess
import sys
import textwrap
import time
from pathlib import Path


def run_osascript(script: str, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["osascript", "-", *args],
        input=script,
        text=True,
        capture_output=True,
        check=False,
    )


def activate_vamiga(disk_image: Path | None) -> None:
    if disk_image is not None:
        subprocess.run(["open", "-a", "/Applications/vAmiga.app", str(disk_image)], check=True)
    else:
        subprocess.run(["open", "-a", "/Applications/vAmiga.app"], check=True)
    time.sleep(2.5)
    script = textwrap.dedent(
        """
        tell application "vAmiga" to activate
        tell application "System Events"
          tell process "vAmiga"
            set frontmost to true
            return name of every menu bar item of menu bar 1
          end tell
        end tell
        """
    )
    result = run_osascript(script)
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip() or "Failed to activate vAmiga")


def import_script(script_path: Path) -> str:
    applescript = textwrap.dedent(
        """
        on run argv
          set scriptPath to item 1 of argv
          tell application "vAmiga" to activate
          delay 0.5
          tell application "System Events"
            tell process "vAmiga"
              set frontmost to true
              click menu item "Import script..." of menu 1 of menu bar item "Machine" of menu bar 1
              delay 0.8
              keystroke "G" using {command down, shift down}
              delay 0.4
              keystroke scriptPath
              delay 0.2
              key code 36
              delay 0.6
              key code 36
            end tell
          end tell
        end run
        """
    )
    result = run_osascript(applescript, str(script_path))
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip() or "Failed to import RetroShell script")
    return (result.stdout or "").strip()


def main() -> int:
    parser = argparse.ArgumentParser(description="Run a RetroShell script through native vAmiga via the Import script menu.")
    parser.add_argument("script", help="Path to the .retrosh script file")
    parser.add_argument("--disk-image", help="Optional disk image to open in vAmiga before importing the script")
    parser.add_argument("--settle-seconds", type=float, default=2.0, help="Additional seconds to wait after importing the script")
    args = parser.parse_args()

    script_path = Path(args.script).expanduser().resolve()
    if not script_path.is_file():
        print(f"RetroShell script not found: {script_path}", file=sys.stderr)
        return 2
    disk_image = None
    if args.disk_image:
        disk_image = Path(args.disk_image).expanduser().resolve()
        if not disk_image.exists():
            print(f"Disk image not found: {disk_image}", file=sys.stderr)
            return 2

    try:
        activate_vamiga(disk_image)
        import_script(script_path)
        if args.settle_seconds > 0:
            time.sleep(args.settle_seconds)
    except Exception as exc:  # noqa: BLE001
        print(str(exc), file=sys.stderr)
        return 1

    print(f"Imported RetroShell script into native vAmiga: {script_path}")
    if disk_image:
        print(f"Disk image: {disk_image}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
