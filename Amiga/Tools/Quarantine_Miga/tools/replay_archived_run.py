#!/usr/bin/env python3
import argparse
import json
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
NATIVE_RETROSH = ROOT / 'tools' / 'native_vamiga_retrosh.py'


def read_json(path: Path):
    return json.loads(path.read_text(encoding='utf-8'))


def resolve_path(value: str) -> Path:
    path = Path(value)
    if not path.is_absolute():
        path = (ROOT / path).resolve()
    return path


def disk_image_from_report(report: dict, run_dir: Path) -> Path:
    archived = run_dir / 'disk_image.adf'
    if archived.is_file():
        return archived.resolve()
    disk = report.get('disk_image')
    if not disk:
        raise FileNotFoundError('No disk image recorded in archived report.')
    path = resolve_path(str(disk))
    if not path.is_file():
        raise FileNotFoundError(f'Disk image not found: {path}')
    return path


def kick_rom_from_report(report: dict) -> Path:
    kick = report.get('kick_rom')
    if not kick:
        raise FileNotFoundError('No Kick ROM recorded in archived report.')
    path = resolve_path(str(kick))
    if not path.is_file():
        raise FileNotFoundError(f'Kick ROM not found: {path}')
    return path


def script_text(disk_image: Path, kick_rom: Path, warp_mode: str) -> str:
    return '\n'.join([
        'amiga power off',
        f'mem load rom "{kick_rom}"',
        f'df0 insert "{disk_image}"',
        f'amiga set WARP_MODE {warp_mode}',
        'amiga power on',
        '',
    ])


def main() -> int:
    parser = argparse.ArgumentParser(description='Replay an archived Miga run in native vAmiga via RetroShell.')
    parser.add_argument('--run-tag', required=True, help='Archived run tag under build/amiga/runs')
    parser.add_argument('--warp-mode', default='ALWAYS', help='RetroShell WARP_MODE value to use during boot')
    parser.add_argument('--settle-seconds', type=float, default=4.0, help='Seconds to wait after importing the RetroShell script')
    args = parser.parse_args()

    run_dir = ROOT / 'build' / 'amiga' / 'runs' / args.run_tag
    report_path = run_dir / 'report.json'
    if not report_path.is_file():
        print(f'Archived report not found: {report_path}', file=sys.stderr)
        return 2
    report = read_json(report_path)

    disk_image = disk_image_from_report(report, run_dir)
    kick_rom = kick_rom_from_report(report)

    script_body = script_text(disk_image, kick_rom, args.warp_mode)
    generated_path = run_dir / 'replay.retrosh'
    generated_path.write_text(script_body, encoding='utf-8')

    cmd = [
        sys.executable,
        str(NATIVE_RETROSH),
        str(generated_path),
        '--settle-seconds',
        str(args.settle_seconds),
    ]
    proc = subprocess.run(cmd, cwd=ROOT, text=True, capture_output=True)
    if proc.returncode != 0:
        sys.stderr.write(proc.stderr or proc.stdout)
        return proc.returncode

    sys.stdout.write(proc.stdout)
    print(f'RetroShell script: {generated_path}')
    print(f'Disk image: {disk_image}')
    print(f'Kick ROM: {kick_rom}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
