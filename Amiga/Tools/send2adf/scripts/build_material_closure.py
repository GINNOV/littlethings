from __future__ import annotations

import ast
import io
import re
import tokenize
from collections import deque
from pathlib import Path
from typing import Final

FILE_TOKEN: Final = re.compile(
    r"[A-Za-z0-9_./-]+\.(?:cmake(?:\.in)?|h(?:\.in)?|json|patch|py|txt|c)(?![A-Za-z0-9_.])"
)
QUOTED_INCLUDE: Final = re.compile(r'^\s*#\s*include\s+"([^"]+)"', re.MULTILINE)
SUBDIRECTORY: Final = re.compile(r"add_subdirectory\(\s*\"?([^\s\")]+)")
VARIABLE_PATH: Final = re.compile(r'"([^"\n]+)"')
SKIPPED_FIXTURE_PREFIX: Final = "package-licenses-"
NON_MATERIAL_NAMES: Final = frozenset({"ADFlibLicenseApprovals.json"})


class BuildMaterialClosureError(Exception):
    pass


def _inside(path: Path, root: Path) -> bool:
    try:
        path.relative_to(root)
    except ValueError:
        return False
    return True


def _fixture_file(path: Path) -> bool:
    return not any(part.startswith(SKIPPED_FIXTURE_PREFIX) for part in path.parts)


def _add_path(path: Path, root: Path, found: set[Path], queue: deque[Path]) -> None:
    resolved = path.resolve()
    if not _inside(resolved, root) or not resolved.exists():
        return
    if resolved.is_dir():
        if resolved.name != "fixtures" or resolved.parent.name != "tests":
            return
        pending = [resolved]
        while pending:
            directory = pending.pop()
            for child in sorted(directory.iterdir()):
                if not _fixture_file(child.relative_to(resolved)):
                    continue
                if child.is_dir():
                    pending.append(child)
                elif child.is_file():
                    _add_path(child, root, found, queue)
        return
    if resolved not in found:
        found.add(resolved)
        queue.append(resolved)


def _resolve_token(token: str, current: Path, roots: tuple[Path, ...]) -> Path | None:
    direct = (current / token).resolve()
    if direct.exists():
        return direct
    matches = [(root / token).resolve() for root in roots if (root / token).exists()]
    if len(matches) == 1:
        return matches[0]
    return None


def _cmake_paths(path: Path, send2adf: Path, root: Path) -> set[Path]:
    text = path.read_text(encoding="utf-8")
    rendered = (
        text.replace("${CMAKE_CURRENT_SOURCE_DIR}", str(path.parent))
        .replace("${CMAKE_SOURCE_DIR}", str(send2adf))
        .replace("${CMAKE_CURRENT_FUNCTION_LIST_DIR}", str(path.parent))
    )
    candidates: set[Path] = set()
    for value in VARIABLE_PATH.findall(rendered):
        if "$" in value:
            continue
        candidate = Path(value)
        if not candidate.is_absolute():
            candidate = path.parent / candidate
        if candidate.exists() and _inside(candidate.resolve(), root):
            candidates.add(candidate.resolve())
    for token in FILE_TOKEN.findall(text):
        candidate = _resolve_token(token, path.parent, (send2adf, root / "Tools"))
        if candidate is not None:
            candidates.add(candidate)
    for directory in SUBDIRECTORY.findall(text):
        candidate = (path.parent / directory / "CMakeLists.txt").resolve()
        if candidate.exists():
            candidates.add(candidate)
    return candidates


def _python_paths(path: Path, roots: tuple[Path, ...]) -> set[Path]:
    text = path.read_text(encoding="utf-8")
    candidates: set[Path] = set()
    tree = ast.parse(text, filename=str(path))
    modules: set[str] = set()
    for node in ast.walk(tree):
        if isinstance(node, ast.ImportFrom) and node.module:
            modules.add(node.module)
        elif isinstance(node, ast.Import):
            modules.update(alias.name for alias in node.names)
    for module in modules:
        token = module.replace(".", "/") + ".py"
        candidate = _resolve_token(token, path.parent, roots)
        if candidate is not None:
            candidates.add(candidate)
    active_text = " ".join(
        token.string
        for token in tokenize.generate_tokens(io.StringIO(text).readline)
        if token.type != tokenize.COMMENT
    )
    for token in FILE_TOKEN.findall(active_text):
        if Path(token).name in NON_MATERIAL_NAMES:
            continue
        candidate = _resolve_token(token, path.parent, roots)
        if candidate is not None:
            candidates.add(candidate)
    return candidates


def canonical_build_materials(amiga_root: Path) -> frozenset[str]:
    root = amiga_root.resolve()
    send2adf = root / "Tools/send2adf"
    search_roots = (
        root / "Tools",
        send2adf,
        send2adf / "tests",
        root / "Tools/build-support/adflib",
        root / "Tools/build-support/adflib/tests",
    )
    found: set[Path] = set()
    queue: deque[Path] = deque()
    for initial in (
        send2adf / "CMakeLists.txt",
        send2adf / "CMakePresets.json",
        send2adf / "Makefile",
    ):
        _add_path(initial, root, found, queue)
    while queue:
        path = queue.popleft()
        suffix = path.suffix.lower()
        discovered: set[Path] = set()
        if path.name == "CMakeLists.txt" or suffix == ".cmake":
            discovered.update(_cmake_paths(path, send2adf, root))
        elif suffix == ".py":
            discovered.update(_python_paths(path, search_roots))
        elif suffix in {".c", ".h"}:
            for include in QUOTED_INCLUDE.findall(path.read_text(encoding="utf-8")):
                candidate = _resolve_token(include, path.parent, search_roots)
                if candidate is not None:
                    discovered.add(candidate)
        for candidate in discovered:
            _add_path(candidate, root, found, queue)
    relative = frozenset(path.relative_to(root).as_posix() for path in found)
    if not relative or "Tools/send2adf/CMakeLists.txt" not in relative:
        raise BuildMaterialClosureError("canonical build-material closure is empty")
    return relative
