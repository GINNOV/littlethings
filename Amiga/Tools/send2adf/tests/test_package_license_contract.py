#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 Tools/send2adf/tests/test_package_license_contract.py

from __future__ import annotations

import hashlib
import io
import json
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
import unittest
from dataclasses import dataclass
from pathlib import Path

if __name__ == "__main__" and not __package__:
    repository_root = Path(__file__).resolve().parents[3]
    result = subprocess.run(
        [sys.executable, "-m", "unittest", "Tools.send2adf.tests.test_package_license_contract"],
        check=False,
        cwd=repository_root,
    )
    raise SystemExit(result.returncode)

from Tools.send2adf.scripts.adflib_source_contract import (
    AdflibSourceError,
    load_identity,
    validate_tree,
)
from Tools.send2adf.scripts.check_package_licenses import (
    ContractError,
    validate_notice_policy,
)


@dataclass(frozen=True, slots=True)
class CheckResult:
    returncode: int
    output: str


SEND2ADF_ROOT = Path(__file__).resolve().parents[1]
CHECKER = SEND2ADF_ROOT / "scripts" / "check_package_licenses.py"
FIXTURES = SEND2ADF_ROOT / "tests" / "fixtures"
REPOSITORY_ROOT = SEND2ADF_ROOT.parents[2]


def run_checker(fixture_name: str) -> CheckResult:
    return run_checker_path(FIXTURES / fixture_name)


def run_checker_path(package_root: Path) -> CheckResult:
    completed = subprocess.run(
        [sys.executable, str(CHECKER), str(package_root)],
        check=False,
        capture_output=True,
        text=True,
    )
    return CheckResult(completed.returncode, completed.stdout + completed.stderr)


def replace_source_archive(package_root: Path, content: bytes) -> None:
    archive = package_root / "send2adf-fixture-source.tar.gz"
    archive.write_bytes(content)
    contract_path = package_root / "CORRESPONDING_SOURCE.json"
    contract = json.loads(contract_path.read_text(encoding="utf-8"))
    contract["source_archive"]["sha256"] = hashlib.sha256(content).hexdigest()
    contract_path.write_text(json.dumps(contract, indent=2) + "\n", encoding="utf-8")


def remove_declared_material(package_root: Path, relative: str) -> None:
    material = package_root / "corresponding-source" / relative
    material.unlink()
    contract_path = package_root / "CORRESPONDING_SOURCE.json"
    contract = json.loads(contract_path.read_text(encoding="utf-8"))
    contract["source_inventory"] = [item for item in contract["source_inventory"] if item["path"] != relative]
    for key in ("build_helpers", "build_descriptors"):
        contract[key] = [path for path in contract[key] if path != relative]
    contract_path.write_text(json.dumps(contract, indent=2) + "\n", encoding="utf-8")


class PackageLicenseContractTests(unittest.TestCase):
    def test_notice_policy_when_manifest_identity_changes(self) -> None:
        # Given: generic production notices and a complete alternate six-field identity.
        notices = (
            SEND2ADF_ROOT / "THIRD_PARTY_NOTICES.md",
            REPOSITORY_ROOT / "Amiga/Tools/ADFinder/THIRD_PARTY_NOTICES.md",
        )
        alternate_manifest = (
            'set(ADFLIB_VERSION "9.8.7")\n'
            'set(ADFLIB_TAG "v9.8.7-alternate")\n'
            'set(ADFLIB_COMMIT "1111111111111111111111111111111111111111")\n'
            'set(ADFLIB_TREE_SHA "2222222222222222222222222222222222222222")\n'
            'set(ADFLIB_ARCHIVE_URL "https://example.invalid/adflib-alternate.tar.gz")\n'
            'set(ADFLIB_TREE_MANIFEST_SHA256 "3333333333333333333333333333333333333333333333333333333333333333")\n'
        )
        with tempfile.TemporaryDirectory() as temporary_directory:
            manifest = Path(temporary_directory) / "alternate.cmake"
            manifest.write_text(alternate_manifest, encoding="utf-8")
            # When: notice policy is evaluated against an identity unknown to production text.
            for notice in notices:
                validate_notice_policy(notice, manifest)
            pinned = Path(temporary_directory) / "pinned.md"
            pinned.write_text("1111111111111111111111111111111111111111\n", encoding="utf-8")
            # Then: generic notices pass while a notice that pins the alternate commit fails.
            with self.assertRaisesRegex(ContractError, "third-party notice pins ADFlib identity"):
                validate_notice_policy(pinned, manifest)

    def test_notice_files_when_updater_mutation_surface_is_audited(self) -> None:
        # Given: the production updater implementation and both production notice paths.
        updater = (
            REPOSITORY_ROOT / "Amiga/Tools/build-support/adflib/update_adflib.py"
        ).read_text(encoding="utf-8")
        # When: its mutation surface is scanned for notice ownership.
        notice_names = ("THIRD_PARTY_NOTICES.md", "Tools/send2adf/THIRD_PARTY_NOTICES.md", "Tools/ADFinder/THIRD_PARTY_NOTICES.md")
        # Then: the six-field updater has no notice-file mutation target.
        self.assertTrue(all(name not in updater for name in notice_names))

    def test_notice_mismatch_when_packaged_policy_text_changes(self) -> None:
        # Given: a structurally valid package whose policy notice differs by one byte.
        with tempfile.TemporaryDirectory() as temporary_directory:
            package_root = Path(temporary_directory) / "package"
            shutil.copytree(FIXTURES / "package-licenses-valid", package_root)
            notice = package_root / "THIRD_PARTY_NOTICES.md"
            notice.write_bytes(notice.read_bytes() + b"changed\n")
            # When: the package checker binds the packaged notice to canonical policy text.
            result = run_checker_path(package_root)
        # Then: release fails closed before accepting mutable or stale notice prose.
        self.assertEqual((result.returncode, result.output.strip()), (2, "third-party notice mismatch"))

    def test_missing_build_material_when_any_derived_category_is_omitted(self) -> None:
        categories = {
            "application-source": "Tools/send2adf/send2adf_runtime.c",
            "cmake-invoked-script": "Tools/send2adf/tests/run_characterization.py",
            "imported-helper": "Tools/send2adf/tests/characterization_cases.py",
            "test-fixture": "Tools/send2adf/tests/fixtures/single/message.txt",
            "shared-build-support": "Tools/build-support/adflib/tests/test_canonical_archive.py",
        }
        for category, relative in categories.items():
            with self.subTest(category=category), tempfile.TemporaryDirectory() as temporary_directory:
                # Given: a declared package with one entire derived build-material category removed.
                package_root = Path(temporary_directory) / "package"
                shutil.copytree(FIXTURES / "package-licenses-valid", package_root)
                remove_declared_material(package_root, relative)
                # When: the checker recomputes closure from canonical CMake, imports, includes, and fixtures.
                result = run_checker_path(package_root)
                # Then: removing both the file and its declaration still fails closed.
                self.assertEqual(
                    (result.returncode, result.output.strip()),
                    (2, "packaged build material closure mismatch"),
                )

    def test_regularized_symlink_mode_when_install_is_executable(self) -> None:
        # Given: a complete materialized tree whose reviewed INSTALL copy has executable mode.
        with tempfile.TemporaryDirectory() as temporary_directory:
            source_root = Path(temporary_directory) / "ADFlib-v0.10.7"
            shutil.copytree(
                FIXTURES / "package-licenses-valid/corresponding-source/ADFlib-v0.10.7",
                source_root,
            )
            (source_root / "INSTALL").chmod(0o755)
            # When: the complete tree identity is recomputed from local bytes and modes.
            with self.assertRaisesRegex(AdflibSourceError, "ADFlib symlink regularization mismatch"):
                manifest = FIXTURES / "package-licenses-valid/corresponding-source/Tools/build-support/adflib/ADFlibDependency.cmake"
                validate_tree(source_root, load_identity(manifest))
        # Then: a non-deterministic mode cannot masquerade as the reviewed materialization.

    def test_incomplete_system_dependencies_when_git_apply_is_omitted(self) -> None:
        # Given: a complete package whose dependency declaration omits the patch tool it uses.
        with tempfile.TemporaryDirectory() as temporary_directory:
            package_root = Path(temporary_directory) / "package"
            shutil.copytree(FIXTURES / "package-licenses-valid", package_root)
            contract_path = package_root / "CORRESPONDING_SOURCE.json"
            contract = json.loads(contract_path.read_text(encoding="utf-8"))
            contract["system_dependencies"].remove("git")
            contract_path.write_text(json.dumps(contract, indent=2) + "\n", encoding="utf-8")
            # When: the release gate validates the actual package build inputs.
            result = run_checker_path(package_root)
        # Then: a partially declared system toolchain cannot pass the source gate.
        self.assertEqual(
            (result.returncode, result.output.strip()),
            (2, "system dependency declaration mismatch"),
        )

    def test_incomplete_adflib_tree_when_claimed_digests_match(self) -> None:
        # Given: the package claims the pinned ADFlib tree but carries only notice-bearing files.
        with tempfile.TemporaryDirectory() as temporary_directory:
            package_root = Path(temporary_directory) / "package"
            shutil.copytree(FIXTURES / "package-licenses-valid", package_root)
            adflib_root = package_root / "corresponding-source/ADFlib-v0.10.7"
            shutil.rmtree(adflib_root)
            (adflib_root / "src").mkdir(parents=True)
            shutil.copy(package_root / "ADFlib/COPYING", adflib_root / "COPYING")
            for name in ("adflib.c", "adf_version.h", "adf_limits.h"):
                shutil.copy(package_root / "ADFlib/source-notices/src" / name, adflib_root / "src" / name)
            # When: the release gate recomputes the packaged source tree identity.
            result = run_checker_path(package_root)
        # Then: matching metadata claims cannot substitute for complete corresponding source.
        self.assertEqual(
            (result.returncode, result.output.strip()),
            (2, "ADFlib source tree identity mismatch"),
        )

    def test_missing_adflib_notice_when_package_omits_required_notice(self) -> None:
        # Given: the valid package without ADFlib's adflib.c notice.
        with tempfile.TemporaryDirectory() as temporary_directory:
            package_root = Path(temporary_directory) / "package"
            shutil.copytree(FIXTURES / "package-licenses-valid", package_root)
            (package_root / "ADFlib/source-notices/src/adflib.c").unlink()
            # When: the release gate checks the package tree.
            result = run_checker_path(package_root)
        # Then: the exact missing conflicting notice blocks release.
        self.assertEqual(
            (result.returncode, result.output.strip()),
            (2, "missing: ADFlib/source-notices/src/adflib.c"),
        )

    def test_missing_adf_limits_notice_when_package_omits_required_notice(self) -> None:
        # Given: the valid package without ADFlib's adf_limits.h notice.
        with tempfile.TemporaryDirectory() as temporary_directory:
            package_root = Path(temporary_directory) / "package"
            shutil.copytree(FIXTURES / "package-licenses-valid", package_root)
            (package_root / "ADFlib/source-notices/src/adf_limits.h").unlink()
            # When: the release gate checks the package tree.
            result = run_checker_path(package_root)
        # Then: the exact missing conflicting notice blocks release.
        self.assertEqual(
            (result.returncode, result.output.strip()),
            (2, "missing: ADFlib/source-notices/src/adf_limits.h"),
        )

    def test_unlisted_helper_when_corresponding_source_contains_extra_helper(self) -> None:
        # Given: a helper exists in corresponding source but not its inventory.
        with tempfile.TemporaryDirectory() as temporary_directory:
            package_root = Path(temporary_directory) / "package"
            shutil.copytree(FIXTURES / "package-licenses-valid", package_root)
            (package_root / "corresponding-source/Tools/send2adf/cmake/verify_release.cmake").write_text(
                "exit 0\n", encoding="utf-8"
            )
            # When: the release gate compares actual and inventoried source.
            result = run_checker_path(package_root)
        # Then: the unlisted helper blocks release before archive acceptance.
        self.assertEqual(
            (result.returncode, result.output.strip()),
            (2, "packaged build material closure mismatch"),
        )

    def test_uninventoried_packaging_dependency_when_dependency_is_declared(self) -> None:
        # Given: a declared non-system dependency is removed from source inventory.
        with tempfile.TemporaryDirectory() as temporary_directory:
            package_root = Path(temporary_directory) / "package"
            shutil.copytree(FIXTURES / "package-licenses-valid", package_root)
            contract_path = package_root / "CORRESPONDING_SOURCE.json"
            contract = json.loads(contract_path.read_text(encoding="utf-8"))
            contract["non_system_packaging_dependencies"] = [
                {"name": "undeclared-helper", "path": "Tools/send2adf/send2adf.c"}
            ]
            contract_path.write_text(json.dumps(contract, indent=2) + "\n", encoding="utf-8")
            # When: the release gate compares dependency declarations and inventory.
            result = run_checker_path(package_root)
        # Then: missing dependency source coverage blocks release.
        self.assertEqual(
            (result.returncode, result.output.strip()),
            (2, "packaging dependency source mismatch"),
        )

    def test_uninspectable_source_archive_when_archive_contains_link(self) -> None:
        # Given: an archive that mixes a regular source member with a symbolic link.
        with tempfile.TemporaryDirectory() as temporary_directory:
            package_root = Path(temporary_directory) / "package"
            shutil.copytree(FIXTURES / "package-licenses-valid", package_root)
            buffer = io.BytesIO()
            with tarfile.open(fileobj=buffer, mode="w:gz") as source:
                regular = tarfile.TarInfo("corresponding-source/Tools/send2adf/send2adf.c")
                content = (package_root / "corresponding-source/Tools/send2adf/send2adf.c").read_bytes()
                regular.size = len(content)
                source.addfile(regular, io.BytesIO(content))
                link = tarfile.TarInfo("corresponding-source/link")
                link.type = tarfile.SYMTYPE
                link.linkname = "Tools/send2adf/send2adf.c"
                source.addfile(link)
            replace_source_archive(package_root, buffer.getvalue())
            # When: the release gate inspects every archive member.
            result = run_checker_path(package_root)
        # Then: unsupported link material blocks the release.
        self.assertEqual(
            (result.returncode, result.output.strip()),
            (2, "unsupported source archive member: corresponding-source/link"),
        )

    def test_corrupt_source_archive_when_digest_matches_corrupt_bytes(self) -> None:
        # Given: a nonempty package archive whose digest matches corrupt bytes.
        with tempfile.TemporaryDirectory() as temporary_directory:
            package_root = Path(temporary_directory) / "package"
            shutil.copytree(FIXTURES / "package-licenses-valid", package_root)
            replace_source_archive(package_root, b"not a tar archive")
            # When: the release gate inspects the archive.
            result = run_checker_path(package_root)
        # Then: matching transport bytes do not establish inspectable source.
        self.assertEqual(
            (result.returncode, result.output.strip()),
            (2, "corresponding source archive is not inspectable"),
        )

    def test_empty_source_archive_when_digest_matches_empty_file(self) -> None:
        # Given: an otherwise complete package whose source archive has zero bytes.
        with tempfile.TemporaryDirectory() as temporary_directory:
            package_root = Path(temporary_directory) / "package"
            shutil.copytree(FIXTURES / "package-licenses-valid", package_root)
            replace_source_archive(package_root, b"")
            # When: the release gate checks the package tree.
            result = run_checker_path(package_root)
        # Then: a matching empty-file digest cannot masquerade as corresponding source.
        self.assertEqual(
            (result.returncode, result.output.strip()),
            (2, "corresponding source archive is empty"),
        )

    def test_missing_adf_version_notice_when_package_omits_required_notice(self) -> None:
        # Given: the valid package without ADFlib's adf_version.h notice.
        with tempfile.TemporaryDirectory() as temporary_directory:
            package_root = Path(temporary_directory) / "package"
            shutil.copytree(FIXTURES / "package-licenses-valid", package_root)
            (package_root / "ADFlib/source-notices/src/adf_version.h").unlink(missing_ok=True)
            # When: the release gate checks the package tree.
            result = run_checker_path(package_root)
        # Then: the exact missing conflicting notice blocks release.
        self.assertEqual(
            (result.returncode, result.output.strip()),
            (2, "missing: ADFlib/source-notices/src/adf_version.h"),
        )

    def test_baseline_ledger_when_legal_review_is_not_recorded(self) -> None:
        # Given: the tracked source arrays and canonical baseline ledger.
        ledger = json.loads(
            (REPOSITORY_ROOT / "Amiga/Tools/build-support/adflib/ADFlibLicenseApprovals.json")
            .read_text(encoding="utf-8")
        )
        send2adf_source = (SEND2ADF_ROOT / "send2adf.c").read_text(encoding="utf-8")
        adfinder_source = (
            REPOSITORY_ROOT / "Amiga/Tools/ADFinder/ADFinder/ADFLibrary/ADFService.swift"
        ).read_text(encoding="utf-8")
        source_by_consumer = {"send2adf": send2adf_source, "ADFinder": adfinder_source}
        symbol_by_name = {
            "kickstart-1.3": "kick13BootBlock",
            "kickstart-2.0": "kick20BootBlock",
            "sca-virus-killer": "scaBootBlock",
            "bandit-virus-killer": "banditBootBlock",
        }
        # When: every ledger byte identity is recomputed from its consumer source.
        for bootblock in ledger["bootblocks"]:
            source = source_by_consumer[bootblock["consumer"]]
            symbol = symbol_by_name[bootblock["name"]]
            data_pattern = r"\{(.*?)\};" if source is send2adf_source else r"\[(.*?)\]"
            body = re.search(rf"{symbol}.*?{data_pattern}", source, re.DOTALL)
            if body is None:
                self.fail(f"missing bootblock source array: {symbol}")
            raw = bytes(int(value, 16) for value in re.findall(r"0x([0-9a-fA-F]{2})", body.group(1)))
            padding = 1024 - len(raw) if bootblock["consumer"] == "send2adf" else 1024 - 40
            # Then: hashes match, while missing legal authority remains explicitly blocking.
            self.assertEqual(hashlib.sha256(raw).hexdigest(), bootblock["source_sha256"])
            self.assertEqual(hashlib.sha256(raw + bytes(padding)).hexdigest(), bootblock["materialized_sha256"])
            self.assertEqual(bootblock["legal_decision"], "pending_legal_review")
        self.assertEqual(ledger["baseline"]["status"], "pending_legal_review")
        self.assertEqual(ledger["approvals"], [])

    def test_valid_package_when_every_contract_is_bound(self) -> None:
        # Given: a package with licenses, an approved ledger/receipt, and complete source.
        # When: the release gate checks the package tree.
        result = run_checker("package-licenses-valid")
        # Then: the package is accepted with the stable success diagnostic.
        self.assertEqual((result.returncode, result.output.strip()), (0, "license_inventory_ok"))

    def test_missing_copying_when_adflib_license_is_absent(self) -> None:
        # Given: the valid package contract without ADFlib/COPYING.
        # When: the release gate checks the package tree.
        result = run_checker("package-licenses-missing-copying")
        # Then: the package is rejected with the plan-mandated diagnostic.
        self.assertEqual((result.returncode, result.output.strip()), (2, "missing: ADFlib/COPYING"))

    def test_incomplete_source_when_patch_is_not_in_inventory(self) -> None:
        # Given: a source tree whose ADFlib patch is omitted from the inventory.
        # When: the release gate checks the package tree.
        result = run_checker("package-licenses-incomplete-source")
        # Then: release fails closed at the omitted corresponding-source class.
        self.assertEqual((result.returncode, result.output.strip()), (2, "missing source kind: adflib-patch"))

    def test_pending_approval_when_ledger_has_no_legal_decision(self) -> None:
        # Given: a structurally complete package with a pending legal ledger.
        # When: the release gate checks the package tree.
        result = run_checker("package-licenses-pending-approval")
        # Then: release is blocked rather than treating structure as legal approval.
        self.assertEqual((result.returncode, result.output.strip()), (2, "license approval pending"))

    def test_receipt_mismatch_when_merge_does_not_bind_ledger(self) -> None:
        # Given: a receipt whose ledger digest differs from the packaged ledger bytes.
        # When: the release gate checks the package tree.
        result = run_checker("package-licenses-bad-receipt")
        # Then: release fails closed on the post-merge binding.
        self.assertEqual((result.returncode, result.output.strip()), (2, "post-merge receipt ledger mismatch"))


if __name__ == "__main__":
    unittest.main()
