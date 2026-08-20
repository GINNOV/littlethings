#!/bin/sh

set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
for destination in live capture models runs diagnostics; do
    rg -q -F "accessibilityIdentifier(\"workspace.$destination\")" \
        "$project_root/Sources/ArmageddonApp" || {
        printf '%s\n' "ERROR[workspace-accessibility-missing]: $destination" >&2
        exit 1
    }
done
grep -Fq 'accessibilityLabel("STOP motion")' "$project_root/Sources/ArmageddonApp/Components/StatusStripView.swift"
grep -Fq 'keyboardShortcut(.escape' "$project_root/Sources/ArmageddonApp/Components/StatusStripView.swift"
grep -Fq 'accessibilityElement(children: .combine)' "$project_root/Sources/ArmageddonApp/Live/DetectionOverlayView.swift"
grep -Fq 'accessibilityValue(' "$project_root/Sources/ArmageddonApp/Live/DetectionOverlayView.swift"
grep -Fq 'View provenance for' "$project_root/Sources/ArmageddonApp/Models/ModelsWorkspaceView.swift"
grep -Fq 'models.k210-import' "$project_root/Sources/ArmageddonApp/Models/ModelsWorkspaceView.swift"
grep -Fq 'models.k210-inventory' "$project_root/Sources/ArmageddonApp/Models/ModelsWorkspaceView.swift"
grep -Fq 'model.detail.activate' "$project_root/Sources/ArmageddonApp/Models/ModelDetailView.swift"
grep -Fq 'model.detail.rollback' "$project_root/Sources/ArmageddonApp/Models/ModelDetailView.swift"
grep -Fq '"Required interlocks are always on"' "$project_root/Sources/ArmageddonApp/Resources/Localizable.xcstrings"
grep -Fq 'sourceLanguage' "$project_root/Sources/ArmageddonApp/Resources/Localizable.xcstrings"
printf '%s\n' 'PASS: accessibility, keyboard STOP, ordered detection labels, and localization catalog contracts are present'
