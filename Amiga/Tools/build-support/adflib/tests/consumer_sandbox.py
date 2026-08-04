#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# sudo -n python3 consumer_sandbox.py --trusted-root controls --source-root source --cache-root cache --build-root build --home-root home -- command

from __future__ import annotations

import argparse
import errno
import hashlib
import os
import platform
import pwd
import stat
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True, slots=True)
class SandboxError(Exception):
    code: str

    def __str__(self) -> str:
        return self.code


def tree_digest(root: Path) -> str:
    digest = hashlib.sha256()
    for path in sorted(root.rglob("*")):
        relative = path.relative_to(root).as_posix().encode()
        digest.update(len(relative).to_bytes(4, "big"))
        digest.update(relative)
        mode = path.lstat().st_mode
        digest.update(mode.to_bytes(4, "big"))
        if stat.S_ISREG(mode):
            digest.update(path.read_bytes())
        elif stat.S_ISLNK(mode):
            digest.update(os.readlink(path).encode())
    return digest.hexdigest()


def parse_root(path: Path, name: str) -> Path:
    resolved = path.resolve(strict=True)
    if path.is_symlink() or not resolved.is_dir() or resolved == Path("/"):
        raise SandboxError(f"sandbox_root_invalid:{name}")
    return resolved


def sanitized_environment(home: Path, mode: str) -> dict[str, str]:
    return {
        "CONSUMER_ISOLATION_MODE": mode,
        "HOME": str(home),
        "LANG": "C.UTF-8",
        "PATH": "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
        "PYTHONDONTWRITEBYTECODE": "1",
        "TMPDIR": str(home),
        "TRUSTED_UID": str(os.getuid()),
    }


def secure_root(root: Path) -> None:
    try:
        os.chown(root, 0, 0)
        os.chmod(root, 0o555)
    except OSError as error:
        if error.errno != errno.EROFS or not os.statvfs(root).f_flag & os.ST_RDONLY:
            raise


def macos_command(command: list[str], trusted: Path, source: Path, cache: Path, build: Path, home: Path) -> tuple[list[str], str, tempfile.TemporaryDirectory[str]]:
    temporary = tempfile.TemporaryDirectory(prefix="consumer-seatbelt-")
    profile = Path(temporary.name) / "consumer.sb"
    profile.write_text(
        "(version 1)\n"
        "(allow default)\n"
        "(deny network*)\n"
        "(deny file-write*)\n"
        f'(allow file-write* (subpath "{build}"))\n'
        f'(allow file-write* (subpath "{home}"))\n'
        "(allow file-write-data (literal \"/dev/null\"))\n",
        encoding="utf-8",
    )
    os.chmod(temporary.name, 0o755)
    os.chmod(profile, 0o644)
    prefix = ["/usr/bin/sandbox-exec", "-f", str(profile)]
    mode = "darwin-seatbelt"
    if os.geteuid() == 0:
        nobody = pwd.getpwnam("nobody")
        for root in (trusted, source, cache):
            secure_root(root)
        for root in (build, home):
            os.chown(root, nobody.pw_uid, nobody.pw_gid)
            os.chmod(root, 0o700)
        prefix = ["/usr/bin/sudo", "-n", "-u", "nobody", "/usr/bin/sandbox-exec", "-f", str(profile)]
        mode = "darwin-seatbelt-distinct-uid"
    return [*prefix, "/usr/bin/env", "-i", *command], mode, temporary


def linux_command(command: list[str], trusted: Path, source: Path, cache: Path, build: Path, home: Path) -> tuple[list[str], str, None]:
    if os.geteuid() != 0:
        raise SandboxError("linux_root_broker_required")
    nobody = pwd.getpwnam("nobody")
    for root in (trusted, source, cache):
        secure_root(root)
    for root in (build, home):
        os.chown(root, nobody.pw_uid, nobody.pw_gid)
        os.chmod(root, 0o700)
    namespace_script = (
        "mount --bind / / && mount -o remount,bind,ro / && "
        "mount --bind \"$1\" \"$1\" && mount -o remount,bind,rw \"$1\" && "
        "mount --bind \"$2\" \"$2\" && mount -o remount,bind,rw \"$2\" && "
        f"shift 2 && exec setpriv --reuid={nobody.pw_uid} --regid={nobody.pw_gid} --clear-groups \"$@\""
    )
    return ["unshare", "--mount", "--net", "--pid", "--fork", "--mount-proc", "/bin/sh", "-c", namespace_script, "broker", str(build), str(home), "/usr/bin/env", "-i", *command], "linux-namespace-distinct-uid", None


def run(arguments: argparse.Namespace) -> int:
    trusted = parse_root(arguments.trusted_root, "trusted")
    source = parse_root(arguments.source_root, "source")
    cache = parse_root(arguments.cache_root, "cache")
    build = parse_root(arguments.build_root, "build")
    home = parse_root(arguments.home_root, "home")
    roots = (trusted, source, cache, build, home)
    if len(set(roots)) != len(roots):
        raise SandboxError("sandbox_roots_overlap")
    command = arguments.command[1:] if arguments.command and arguments.command[0] == "--" else arguments.command
    if not command:
        raise SandboxError("sandbox_command_required")
    working_directory = arguments.working_directory.resolve(strict=True)
    if not working_directory.is_relative_to(source) and not working_directory.is_relative_to(build):
        raise SandboxError("sandbox_working_directory_rejected")
    before = tree_digest(trusted)
    match platform.system():
        case "Darwin":
            prefix, mode, temporary = macos_command(command, trusted, source, cache, build, home)
        case "Linux":
            prefix, mode, temporary = linux_command(command, trusted, source, cache, build, home)
        case system:
            raise SandboxError(f"sandbox_platform_unsupported:{system}")
    environment = sanitized_environment(home, mode)
    prefix[-len(command) - 2 : -len(command)] = ["/usr/bin/env", "-i", *[f"{key}={value}" for key, value in environment.items()]]
    try:
        result = subprocess.run(prefix, cwd=working_directory, env={}, check=False, close_fds=True)
    finally:
        if temporary is not None:
            temporary.cleanup()
    if tree_digest(trusted) != before:
        raise SandboxError("trusted_controls_changed")
    return result.returncode


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--trusted-root", type=Path, required=True)
    parser.add_argument("--source-root", type=Path, required=True)
    parser.add_argument("--cache-root", type=Path, required=True)
    parser.add_argument("--build-root", type=Path, required=True)
    parser.add_argument("--home-root", type=Path, required=True)
    parser.add_argument("--working-directory", type=Path, required=True)
    parser.add_argument("command", nargs=argparse.REMAINDER)
    arguments = parser.parse_args()
    try:
        return run(arguments)
    except (SandboxError, OSError, KeyError, subprocess.SubprocessError) as error:
        print(error, file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
