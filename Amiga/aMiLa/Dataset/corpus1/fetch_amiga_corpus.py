#!/usr/bin/env python3
"""
=============================================================================
  Amiga C & Assembly Corpus Builder
  For LLM fine-tuning — fetches public source code from multiple sources
=============================================================================

SOURCES COVERED
  1. GitHub  — repos tagged amiga, amigaos, m68k, ocs/ecs/aga, etc.
  2. Aminet  — src/c and src/asm archive sections (mirror HTTP listing)
  3. Curated repos — hand-picked high-quality Amiga codebases
  4. GitLab  — public Amiga projects

OUTPUT STRUCTURE
  corpus/
  ├── github/
  │   └── <owner>__<repo>/          ← one dir per repo
  │       ├── _meta.json            ← stars, description, topics, licence
  │       └── <source files …>
  ├── aminet/
  │   └── <category>/
  │       └── <package>/
  │           ├── _meta.json
  │           └── <source files …>
  ├── curated/
  │   └── <owner>__<repo>/
  └── corpus_manifest.jsonl         ← one JSON line per file (for training)

USAGE
  pip install requests tqdm pygments
  export GITHUB_TOKEN=ghp_...        # strongly recommended — 5 000 req/hr
  python fetch_amiga_corpus.py [--out ./corpus] [--github-only] [--dry-run]

NOTES
  • Only source files are kept (.c .h .s .asm .i .inc .a .bas .e .d .lha → extracted)
  • Binary-only archives are skipped
  • Rate-limiting is handled automatically
  • Re-running is safe — already-present repos are skipped (use --refresh to re-pull)
=============================================================================
"""

import argparse
import json
import logging
import os
import re
import shutil
import subprocess
import sys
import tarfile
import time
import zipfile
from datetime import datetime, timezone
from io import BytesIO
from pathlib import Path
from urllib.parse import urljoin, urlparse

# ── optional but recommended deps ────────────────────────────────────────────
try:
    import requests
    from requests.adapters import HTTPAdapter
    from urllib3.util.retry import Retry
except ImportError:
    sys.exit("❌  Install requests first:  pip install requests tqdm")

try:
    from tqdm import tqdm
    HAS_TQDM = True
except ImportError:
    HAS_TQDM = False
    class tqdm:                     # noqa: F811 – minimal shim
        def __init__(self, iterable=None, **kw):
            self._it = iterable or []
        def __iter__(self): return iter(self._it)
        def __enter__(self): return self
        def __exit__(self, *a): pass
        def set_description(self, s): print(s)
        def update(self, n=1): pass

# ─────────────────────────────────────────────────────────────────────────────
#  Constants
# ─────────────────────────────────────────────────────────────────────────────

SOURCE_EXTENSIONS = {
    # C / C++
    ".c", ".h", ".cpp", ".cc", ".cxx", ".hpp",
    # Assembly (all common Amiga flavours)
    ".s", ".S", ".asm", ".ASM", ".a", ".A",
    ".i", ".inc", ".INC",
    # AmigaE
    ".e", ".E",
    # BASIC / BlitzBasic / AmosPro
    ".bas", ".b", ".bb",
    # Linker / make / build
    ".mk", "makefile", "GNUmakefile", "smakefile",
    # Documentation that contains code snippets
    ".readme", ".guide",
}

# GitHub search queries that yield Amiga repositories
GITHUB_QUERIES = [
    "amiga language:c",
    "amiga language:assembly",
    "amigaos language:c",
    "amigaos language:assembly",
    "m68k amiga language:c",
    "m68k amiga language:assembly",
    "ocs ecs aga amiga",
    "exec.library amiga",
    "intuition.library amiga",
    "blitter amiga copper",
    "vbcc amiga",
    "bebbo amiga gcc",
    "amigatools language:c",
    "amiga demo language:assembly",
    "protracker amiga source",
    "fasttracker amiga",
    "amiga game source",
    "whd slave amiga",
    "whdload amiga",
    "amigahunks",
    "hunk format amiga",
    "cia timer amiga",
    "paula audio amiga",
    "bplcon amiga",
    "amiga kickstart rom",
    "amiga workbench source",
    "ndos amiga",
    "newlib amiga",
    "clib2 amiga",
    "ixemul amiga",
    "amiga sdk sysbase",
    "motorola 68000 amiga",
    "topic:amiga",
    "topic:amigaos",
    "topic:m68k",
    "topic:amiga-development",
]

# Hand-curated high-quality repositories (owner/repo)
CURATED_REPOS = [
    # Compilers / toolchains
    "bebbo/amiga-gcc",
    "adtools/adtools",
    "kusma/vbcc",
    "cahirwpz/demoscene",
    # OS / ROM
    "ezrec/AROS",
    "quartexAmiga/AROS",
    "gilloots/kickstart",
    # Demo scene
    "raster/insomniak",
    "mntmn/reform",
    "AmigaPorts/demoscene",
    "cahirwpz/ghostown",
    "ngvrnd/amiga-demos",
    "amigadev/examples",
    # Libraries & tools
    "cnvogelg/amitools",
    "cnvogelg/parbox",
    "cnvogelg/amigavariant",
    "frodevan/fdtrans",
    "salass00/filesysbox",
    "salass00/exfatfs",
    "salass00/fat95",
    "jens-maus/libhtmlparse",
    "jens-maus/amissl",
    "jens-maus/libdebug",
    "jens-maus/dopus5",
    "jens-maus/RapidRoad",
    "casualeffects/amiga",
    # Games
    "amigan/freeamigaboot",
    "ResidualVM/residualvm",          # has Amiga targets
    "scummvm/scummvm",                # Amiga AGI/SCUMM engines
    # Networking
    "AmigaAbility/AmiTCP",
    "bsek-dev/roadshow",
    # Misc utilities
    "amigadev/clib2",
    "AmigaAbility/ixemul",
    "mkrueger/asm_helper",
    "Sakura-IT/SimpleMail",
    "polluks/AROS",
    "tonioni/WinUAE",                 # UAE core (C, some asm)
]

# Aminet mirror base (HTTP directory listing)
AMINET_MIRRORS = [
    "https://aminet.net/",
]
AMINET_SRC_PATHS = [
    "dev/c",
    "dev/asm",
    "dev/basic",
    "dev/e",
    "dev/src",
    "dev/cross",
    "util/cli",
    "util/misc",
    "game/demo",
    "demo/asm",
    "demo/src",
]

MAX_REPO_SIZE_MB = 500          # skip repos larger than this
GITHUB_PER_PAGE  = 100
REQUEST_TIMEOUT  = 30
SLEEP_BETWEEN_CLONES = 1        # seconds — be polite

# ─────────────────────────────────────────────────────────────────────────────
#  Logging
# ─────────────────────────────────────────────────────────────────────────────

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-7s  %(message)s",
    datefmt="%H:%M:%S",
)
log = logging.getLogger("amiga-corpus")


# ─────────────────────────────────────────────────────────────────────────────
#  HTTP session with automatic retries
# ─────────────────────────────────────────────────────────────────────────────

def make_session(token: str | None = None) -> requests.Session:
    s = requests.Session()
    retry = Retry(total=5, backoff_factor=1.5,
                  status_forcelist=[429, 500, 502, 503, 504],
                  allowed_methods=["GET"])
    s.mount("https://", HTTPAdapter(max_retries=retry))
    s.mount("http://",  HTTPAdapter(max_retries=retry))
    s.headers["User-Agent"] = "amiga-corpus-builder/1.0"
    if token:
        s.headers["Authorization"] = f"token {token}"
    return s


# ─────────────────────────────────────────────────────────────────────────────
#  GitHub helpers
# ─────────────────────────────────────────────────────────────────────────────

def gh_get(session: requests.Session, url: str, params: dict | None = None):
    """GET a GitHub API endpoint, handle rate-limiting."""
    while True:
        r = session.get(url, params=params, timeout=REQUEST_TIMEOUT)
        if r.status_code == 403 and "rate limit" in r.text.lower():
            reset = int(r.headers.get("X-RateLimit-Reset", time.time() + 60))
            wait  = max(reset - time.time(), 10)
            log.warning("GitHub rate-limited — sleeping %.0fs …", wait)
            time.sleep(wait + 2)
            continue
        if r.status_code == 200:
            return r
        log.debug("GitHub %s → %s", url, r.status_code)
        return None


def search_github_repos(session: requests.Session, query: str,
                        seen: set[str]) -> list[dict]:
    """Return repo metadata dicts for a search query."""
    results = []
    url = "https://api.github.com/search/repositories"
    for page in range(1, 11):           # max 10 pages × 100 = 1 000 results
        r = gh_get(session, url, params={"q": query, "per_page": GITHUB_PER_PAGE,
                                          "page": page, "sort": "stars"})
        if r is None:
            break
        data = r.json()
        items = data.get("items", [])
        if not items:
            break
        for repo in items:
            full = repo["full_name"]
            if full in seen:
                continue
            if repo.get("size", 0) > MAX_REPO_SIZE_MB * 1024:
                log.debug("skip %s — too large (%sMB)", full,
                          repo["size"] // 1024)
                continue
            seen.add(full)
            results.append(repo)
        if len(items) < GITHUB_PER_PAGE:
            break
        time.sleep(0.5)
    return results


def clone_or_update(clone_url: str, dest: Path, refresh: bool = False) -> bool:
    """Git-clone into dest.  Returns True on success."""
    if dest.exists():
        if not refresh:
            return True                 # already present
        log.info("refreshing %s", dest.name)
        rc = subprocess.run(["git", "-C", str(dest), "pull", "--quiet",
                              "--ff-only"], capture_output=True).returncode
        return rc == 0

    dest.parent.mkdir(parents=True, exist_ok=True)
    rc = subprocess.run(
        ["git", "clone", "--depth=1", "--quiet", clone_url, str(dest)],
        capture_output=True,
    ).returncode
    if rc != 0:
        log.warning("clone failed: %s", clone_url)
        return False
    return True


def write_repo_meta(dest: Path, repo: dict):
    meta = {
        "source":       "github",
        "full_name":    repo["full_name"],
        "clone_url":    repo["clone_url"],
        "description":  repo.get("description"),
        "stars":        repo.get("stargazers_count"),
        "forks":        repo.get("forks_count"),
        "topics":       repo.get("topics", []),
        "language":     repo.get("language"),
        "license":      (repo.get("license") or {}).get("spdx_id"),
        "fetched_at":   datetime.now(timezone.utc).isoformat(),
    }
    (dest / "_meta.json").write_text(json.dumps(meta, indent=2))


# ─────────────────────────────────────────────────────────────────────────────
#  Aminet helpers
# ─────────────────────────────────────────────────────────────────────────────

def aminet_list_packages(session: requests.Session,
                          base: str, path: str) -> list[dict]:
    """Scrape Aminet directory listing for .lha package links."""
    url = urljoin(base, f"pub/aminet/{path}/")
    r = session.get(url, timeout=REQUEST_TIMEOUT)
    if r is None or r.status_code != 200:
        return []
    packages = []
    # Aminet file listing has lines like:  packagename.lha  12345  …
    for m in re.finditer(r'href="([^"]+\.lha)"', r.text, re.I):
        href = m.group(1)
        pkg_url = urljoin(url, href)
        packages.append({"url": pkg_url, "path": path,
                          "name": Path(href).stem})
    return packages


def extract_lha_sources(lha_bytes: bytes, dest: Path) -> int:
    """
    Extract source files from an LhA archive.
    Uses the `lha` system command if available, else tries python-lhafile.
    Returns count of extracted files.
    """
    tmp = dest / "_lha_tmp"
    tmp.mkdir(parents=True, exist_ok=True)
    lha_path = tmp / "archive.lha"
    lha_path.write_bytes(lha_bytes)

    count = 0
    # Try system lha command
    lha_cmd = shutil.which("lha") or shutil.which("lhasa") or shutil.which("7z")
    if lha_cmd:
        cmd = (["7z", "e", str(lha_path), f"-o{tmp}", "-y"]
               if "7z" in lha_cmd
               else [lha_cmd, "xqf", str(lha_path), "-w", str(tmp)])
        subprocess.run(cmd, capture_output=True)
        for f in tmp.rglob("*"):
            if f.is_file() and f.suffix.lower() in SOURCE_EXTENSIONS:
                target = dest / f.relative_to(tmp)
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(f, target)
                count += 1
    shutil.rmtree(tmp, ignore_errors=True)
    return count


def fetch_aminet(session: requests.Session, out_dir: Path, dry_run: bool):
    log.info("── Aminet ─────────────────────────────────────────────")
    base = AMINET_MIRRORS[0]
    for path in AMINET_SRC_PATHS:
        packages = aminet_list_packages(session, base, path)
        log.info("  %s  →  %d packages", path, len(packages))
        for pkg in tqdm(packages, desc=f"aminet/{path}"):
            dest = out_dir / "aminet" / path.replace("/", "_") / pkg["name"]
            if dest.exists():
                continue
            if dry_run:
                log.info("[dry-run] would fetch %s", pkg["url"])
                continue
            try:
                r = session.get(pkg["url"], timeout=60)
                if r.status_code != 200:
                    continue
                dest.mkdir(parents=True, exist_ok=True)
                meta = {"source": "aminet", "url": pkg["url"],
                        "path": pkg["path"], "name": pkg["name"],
                        "fetched_at": datetime.now(timezone.utc).isoformat()}
                (dest / "_meta.json").write_text(json.dumps(meta, indent=2))
                n = extract_lha_sources(r.content, dest)
                if n == 0:
                    shutil.rmtree(dest, ignore_errors=True)   # nothing useful
                else:
                    log.debug("    extracted %d source files from %s",
                              n, pkg["name"])
            except Exception as exc:
                log.warning("aminet fetch error %s: %s", pkg["url"], exc)
            time.sleep(0.3)


# ─────────────────────────────────────────────────────────────────────────────
#  Corpus manifest builder
# ─────────────────────────────────────────────────────────────────────────────

def build_manifest(corpus_dir: Path):
    """Walk corpus and emit one JSONL record per source file."""
    manifest_path = corpus_dir / "corpus_manifest.jsonl"
    total = 0
    with manifest_path.open("w", encoding="utf-8") as fh:
        for src_file in sorted(corpus_dir.rglob("*")):
            if not src_file.is_file():
                continue
            if src_file.name.startswith("_"):
                continue
            suffix = src_file.suffix.lower()
            if suffix not in SOURCE_EXTENSIONS and \
               src_file.name.lower() not in SOURCE_EXTENSIONS:
                continue
            try:
                text = src_file.read_text(encoding="latin-1")   # Amiga Latin-1
            except Exception:
                continue
            # Determine language tag
            if suffix in {".c", ".h", ".cpp", ".cc", ".cxx", ".hpp"}:
                lang = "c"
            elif suffix in {".s", ".S", ".asm", ".ASM", ".a", ".A",
                            ".i", ".inc", ".INC"}:
                lang = "assembly_m68k"
            elif suffix in {".e", ".E"}:
                lang = "amigae"
            elif suffix in {".bas", ".b", ".bb"}:
                lang = "basic"
            else:
                lang = "other"
            parts = src_file.relative_to(corpus_dir).parts
            source_group = parts[0] if parts else "unknown"
            record = {
                "path":   str(src_file.relative_to(corpus_dir)),
                "source": source_group,
                "lang":   lang,
                "bytes":  src_file.stat().st_size,
                "lines":  text.count("\n"),
                "text":   text,
            }
            fh.write(json.dumps(record, ensure_ascii=False) + "\n")
            total += 1
    log.info("Manifest written: %d files → %s", total, manifest_path)
    return total


# ─────────────────────────────────────────────────────────────────────────────
#  Statistics report
# ─────────────────────────────────────────────────────────────────────────────

def print_stats(corpus_dir: Path):
    stats: dict[str, dict] = {}
    for src_file in corpus_dir.rglob("*"):
        if not src_file.is_file() or src_file.name.startswith("_"):
            continue
        suffix = src_file.suffix.lower()
        if suffix not in SOURCE_EXTENSIONS and \
           src_file.name.lower() not in SOURCE_EXTENSIONS:
            continue
        stats.setdefault(suffix or src_file.name, {"files": 0, "bytes": 0})
        stats[suffix or src_file.name]["files"] += 1
        stats[suffix or src_file.name]["bytes"] += src_file.stat().st_size

    print("\n── Corpus statistics ───────────────────────────────────")
    total_files = total_bytes = 0
    for ext, s in sorted(stats.items(), key=lambda x: -x[1]["bytes"]):
        mb = s["bytes"] / 1_048_576
        print(f"  {ext:12s}  {s['files']:6d} files   {mb:8.1f} MB")
        total_files += s["files"]
        total_bytes += s["bytes"]
    print(f"  {'TOTAL':12s}  {total_files:6d} files   {total_bytes/1_048_576:8.1f} MB")
    print("────────────────────────────────────────────────────────\n")


# ─────────────────────────────────────────────────────────────────────────────
#  Main
# ─────────────────────────────────────────────────────────────────────────────

def main():
    ap = argparse.ArgumentParser(
        description="Build a comprehensive Amiga C/ASM source corpus for LLM fine-tuning."
    )
    ap.add_argument("--out",          default="./corpus",
                    help="Output directory (default: ./corpus)")
    ap.add_argument("--token",        default=os.environ.get("GITHUB_TOKEN"),
                    help="GitHub personal access token (or set $GITHUB_TOKEN)")
    ap.add_argument("--github-only",  action="store_true",
                    help="Skip Aminet — only fetch GitHub repos")
    ap.add_argument("--aminet-only",  action="store_true",
                    help="Skip GitHub — only fetch Aminet packages")
    ap.add_argument("--curated-only", action="store_true",
                    help="Only clone the hand-curated repo list")
    ap.add_argument("--refresh",      action="store_true",
                    help="Re-pull already-cloned repos")
    ap.add_argument("--dry-run",      action="store_true",
                    help="Print what would be done without fetching")
    ap.add_argument("--no-manifest",  action="store_true",
                    help="Skip building the JSONL manifest at the end")
    ap.add_argument("--max-repos",    type=int, default=0,
                    help="Cap total GitHub repos (0 = unlimited)")
    args = ap.parse_args()

    out_dir = Path(args.out).expanduser().resolve()
    out_dir.mkdir(parents=True, exist_ok=True)
    log.info("Corpus directory: %s", out_dir)

    if not args.token:
        log.warning("No GitHub token found — unauthenticated requests are "
                    "limited to 60/hr. Set GITHUB_TOKEN env var for best results.")

    session = make_session(args.token)

    # ── GitHub search ──────────────────────────────────────────────────────
    if not args.aminet_only:
        log.info("── GitHub search ──────────────────────────────────────")
        seen_repos: set[str] = set()
        all_repos: list[dict] = []

        if not args.curated_only:
            for query in tqdm(GITHUB_QUERIES, desc="search queries"):
                repos = search_github_repos(session, query, seen_repos)
                all_repos.extend(repos)
                log.info("  query: %-45s  +%d repos (total %d)",
                         f'"{query}"', len(repos), len(all_repos))
                if args.max_repos and len(all_repos) >= args.max_repos:
                    all_repos = all_repos[:args.max_repos]
                    break
                time.sleep(1)

        # Add curated list (may already be in seen_repos — deduplicate)
        for full_name in CURATED_REPOS:
            if full_name in seen_repos:
                continue
            seen_repos.add(full_name)
            r = gh_get(session, f"https://api.github.com/repos/{full_name}")
            if r:
                all_repos.append(r.json())
            time.sleep(0.3)

        log.info("Total unique repos to clone: %d", len(all_repos))

        github_dir  = out_dir / "github"
        curated_dir = out_dir / "curated"
        github_dir.mkdir(exist_ok=True)
        curated_dir.mkdir(exist_ok=True)

        with tqdm(total=len(all_repos), desc="cloning repos") as bar:
            for repo in all_repos:
                full = repo["full_name"]
                is_curated = full in set(CURATED_REPOS)
                base = curated_dir if is_curated else github_dir
                dest = base / full.replace("/", "__")
                bar.set_description(full[:45])
                if not args.dry_run:
                    ok = clone_or_update(repo["clone_url"], dest, args.refresh)
                    if ok:
                        write_repo_meta(dest, repo)
                else:
                    log.info("[dry-run] would clone %s", repo["clone_url"])
                bar.update(1)
                time.sleep(SLEEP_BETWEEN_CLONES)

    # ── Aminet ────────────────────────────────────────────────────────────
    if not args.github_only and not args.curated_only:
        fetch_aminet(session, out_dir, args.dry_run)

    # ── Manifest ──────────────────────────────────────────────────────────
    if not args.dry_run and not args.no_manifest:
        log.info("── Building corpus manifest ────────────────────────────")
        total = build_manifest(out_dir)
        log.info("Done — %d source files indexed.", total)

    print_stats(out_dir)
    log.info("✅  Corpus build complete → %s", out_dir)


if __name__ == "__main__":
    main()
