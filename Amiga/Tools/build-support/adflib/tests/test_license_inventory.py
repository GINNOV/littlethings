#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 -m unittest test_license_inventory.py

from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from license_inventory import (
    MAX_CLASSIFIED_BYTES,
    InventoryError,
    LicenseInventory,
    build_inventory,
)


class CompleteLicenseInventoryTests(unittest.TestCase):
    def inventory(self, files: dict[str, bytes]) -> LicenseInventory:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            for relative, content in files.items():
                destination = root / relative
                destination.parent.mkdir(parents=True, exist_ok=True)
                destination.write_bytes(content)
            return build_inventory(root)

    def test_detects_license_comment_after_first_eight_kibibytes(self) -> None:
        # Given: a source license span begins after the old 8 KiB cutoff.
        content = b"int x;\n" * 1_100 + b"/* SPDX-License-Identifier: GPL-2.0-or-later\n * Copyright 2026 Example\n */\n"
        # When: the complete classified source is inventoried.
        inventory = self.inventory({"src/late.c": content})
        # Then: the late complete comment span contributes to the legal digest.
        self.assertEqual(len(inventory.records), 1)
        self.assertEqual(inventory.records[0].kind, "comment_span")

    def test_code_only_edit_keeps_legal_digest(self) -> None:
        # Given: two files have different code and identical notice spans.
        notice = b"/* SPDX-License-Identifier: GPL-2.0-or-later */\n"
        # When: each candidate is inventoried independently.
        first = self.inventory({"src/a.c": notice + b"int first;\n"})
        second = self.inventory({"src/a.c": notice + b"int second;\n"})
        # Then: code outside the complete matching span cannot require approval.
        self.assertEqual(first.digest, second.digest)

    def test_source_rename_keeps_legal_digest(self) -> None:
        # Given: one source notice is moved without changing its normalized bytes.
        notice = b"// SPDX-License-Identifier: GPL-2.0-or-later\n// Copyright 2026 Example\n"
        # When: old and renamed candidates are inventoried.
        first = self.inventory({"src/old.c": notice})
        second = self.inventory({"lib/new.c": notice})
        # Then: ordinary-source path is excluded from the legal approval digest.
        self.assertEqual(first.digest, second.digest)

    def test_changed_notice_changes_legal_digest(self) -> None:
        # Given: the copyright span changes while code remains fixed.
        first = self.inventory({"src/a.c": b"// Copyright 2025 Example\nint x;\n"})
        second = self.inventory({"src/a.c": b"// Copyright 2026 Example\nint x;\n"})
        # When/Then: complete span bytes distinguish the approval decision.
        self.assertNotEqual(first.digest, second.digest)

    def test_dedicated_license_hashes_complete_file(self) -> None:
        # Given: a dedicated license file changes outside its opening paragraph.
        first = self.inventory({"COPYING": b"terms\nA\n"})
        second = self.inventory({"COPYING": b"terms\nB\n"})
        # When/Then: the whole dedicated file is protected.
        self.assertNotEqual(first.digest, second.digest)
        self.assertEqual(first.records[0].kind, "dedicated_file")

    def test_ambiguous_uncommented_signal_forces_whole_file_review(self) -> None:
        # Given: a source contains a legal signal outside a parseable comment span.
        content = b'const char *notice = "SPDX-License-Identifier: GPL-2.0-or-later";\n'
        # When: the source is classified.
        inventory = self.inventory({"src/ambiguous.c": content})
        # Then: it is recorded as an ambiguous whole-file review item.
        self.assertEqual(inventory.ambiguous_paths, ("src/ambiguous.c",))
        self.assertEqual(inventory.records[0].kind, "ambiguous_whole_file")

    def test_discovers_notices_in_every_content_classified_source_name(self) -> None:
        # Given: legal comments appear in Java, mixed-case, extensionless, and unfamiliar source names.
        files = {
            "src/Main.java": b"// SPDX-License-Identifier: GPL-2.0-or-later\nclass Main {}\n",
            "src/Worker.JaVa": b"/* Copyright 2026 Example */\nclass Worker {}\n",
            "tools/generate": b"#!/usr/bin/env python3\n# SPDX-License-Identifier: MIT\nprint('ok')\n",
            "src/module.unfamiliar": b"// Licensed under the Apache License, Version 2.0\nvalue = 1\n",
        }
        # When: candidate-wide discovery classifies content instead of suffixes.
        inventory = self.inventory(files)
        # Then: every legal span is represented regardless of its path spelling.
        self.assertEqual({record.path for record in inventory.records}, set(files))

    def test_plain_license_text_in_unknown_file_forces_whole_file_review(self) -> None:
        # Given: an unfamiliar text file contains a legal signal outside a recognized comment.
        content = b"SPDX-License-Identifier: MIT\nterms follow\n"
        # When: content classification scans the complete file.
        inventory = self.inventory({"metadata/legal.data": content})
        # Then: the file is covered by ambiguous whole-file review.
        self.assertEqual(inventory.ambiguous_paths, ("metadata/legal.data",))

    def test_known_binary_is_explicitly_recorded_as_skipped(self) -> None:
        # Given: a PNG-like binary contains no legal signal.
        content = b"\x89PNG\r\n\x1a\n\x00binary"
        # When: candidate-wide classification examines it.
        inventory = self.inventory({"assets/icon.bin": content})
        # Then: the binary skip and reason are recorded rather than silently omitted.
        self.assertEqual(inventory.records, ())
        self.assertEqual(inventory.classifications[0].kind, "binary_skipped")
        self.assertEqual(inventory.classifications[0].reason, "known_binary_signature")

    def test_ambiguous_encoding_forces_whole_file_review(self) -> None:
        # Given: non-binary bytes are not valid UTF-8 and have no trusted encoding marker.
        content = b"notice: \xff\xfe terms"
        # When: classification cannot prove text or binary identity.
        inventory = self.inventory({"src/unknown.encoding": content})
        # Then: the complete file is covered by fail-closed review.
        self.assertEqual(inventory.ambiguous_paths, ("src/unknown.encoding",))
        self.assertEqual(inventory.classifications[0].kind, "ambiguous_whole_file")

    def test_utf16_bom_text_is_not_silently_classified_as_binary(self) -> None:
        # Given: legal text has a UTF-16 BOM and embedded NUL bytes.
        content = "SPDX-License-Identifier: MIT\n".encode("utf-16")
        # When: content classification encounters the non-UTF-8 encoding marker.
        inventory = self.inventory({"src/utf16.source": content})
        # Then: encoding ambiguity forces whole-file review instead of a binary skip.
        self.assertEqual(inventory.ambiguous_paths, ("src/utf16.source",))
        self.assertEqual(inventory.classifications[0].kind, "ambiguous_whole_file")
        self.assertEqual(inventory.classifications[0].reason, "ambiguous_encoding")

    def test_binary_with_legal_signal_forces_whole_file_review(self) -> None:
        # Given: a binary-signature file also embeds an ASCII SPDX signal.
        content = b"\x89PNG\r\n\x1a\n\x00SPDX-License-Identifier: MIT"
        # When: candidate-wide classification examines all bytes.
        inventory = self.inventory({"assets/image.png": content})
        # Then: legal coverage wins over binary skipping.
        self.assertEqual(inventory.ambiguous_paths, ("assets/image.png",))
        self.assertEqual(inventory.records[0].kind, "ambiguous_whole_file")

    def test_oversized_unbounded_input_fails_before_full_read(self) -> None:
        # Given: a direct inventory caller supplies a file beyond the archive member policy.
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            candidate = root / "oversized.source"
            with candidate.open("wb") as stream:
                stream.truncate(MAX_CLASSIFIED_BYTES + 1)
            # When: candidate-wide classification enforces its independent read bound.
            with self.assertRaises(InventoryError) as raised:
                build_inventory(root)
            # Then: the update fails closed before allocating or scanning unbounded content.
            self.assertEqual(raised.exception.code, "license_file_size_limit")


if __name__ == "__main__":
    unittest.main()
