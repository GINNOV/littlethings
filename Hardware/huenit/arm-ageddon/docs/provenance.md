# Provenance inventory

Task 1 establishes inventory and trust boundaries only. It copies no Joy1,
Python, community, model, dataset, firmware, or binary artifact.

## Joy1 inventory

No Joy1 file is approved for verbatim copying. The following files are named
behavioral review candidates for later, separately tested ports:

| Area | Joy1 reference files | Task 1 disposition |
| --- | --- | --- |
| Arm protocol | `Arm/ArmError.swift`, `Arm/HuenitArm.swift` | Read-only; no source copied |
| Control | `Control/JogEngine.swift`, `Control/PendantModel.swift`, `Control/PoseMonitor.swift` | Read-only; no source copied |
| Discovery | `Detection/PortDetector.swift` | Read-only; no source copied |
| Pose | `Pose/Pose.swift` | Read-only; no source copied |
| Serial | `Serial/FakeSerial.swift`, `Serial/SerialPort.swift`, `Serial/SerialTransport.swift` | Read-only; no source copied |
| Tests | `Tests/Joy1Tests/**` | Read-only behavioral evidence; no fixtures or tests copied |
| UI | `Sources/Joy1App/**` | Out of Task 1 and not intended for copying |
| Project metadata | `Package.swift`, `Joy1.xcodeproj/project.pbxproj` | Shape reference only; newly authored graph |

Any future port must identify the exact source revision, review license
compatibility, and record file-level derivation before code enters this tree.

## External claim inventory

These are claims in the existing README, not verified dependencies or bundled
capabilities. External text is treated as untrusted research input.

| Reference | Existing claim | Trust and reuse status |
| --- | --- | --- |
| Local `huenit-external` export | Python arm control, training, conversion, and inference examples | Read-only; no Python or model artifacts copied |
| `piramja/huenit` | GPL-3.0 Python jogging and teach/replay examples | Behavioral reference only; license is incompatible with unreviewed copying |
| `elandivar/huenit_community_sdk` | Reverse-engineered event and module-command documentation; no clear repository license observed | Documentation claim only; source reuse prohibited absent license evidence |
| `jpwilhelms/huenit_vision` | Workspace validation, calibration, visual servoing, and robot control | Behavioral reference only; license and revision must be verified before reuse |
| `huenit-paul/ai-for-huenit` | MIT-licensed Keras/aXeleRate K210 pipeline | Tooling claim only; no code, model, or dataset copied |
| `MarlinFirmware/Marlin` | Upstream firmware and FYSETC E4 context | Context only; HUENIT behavior must be measured |
| HUENIT English manual | Official user-facing operating guidance | Documentation reference only |
| Host inference examples | TensorFlow Lite, Arm NN, Edge TPU, and OAK examples exist in the external export | Claim only; no runtime dependency adopted |
| K210/CanMV artifacts | Training conversion and detector-script generation are described | Claim only; no model, script, or generated artifact copied |

The text fixture at
`Tests/Fixtures/invalid-external-package-reference.txt` is deliberately inert,
untrusted input for `scripts/check-source-boundary.sh`. Neither SwiftPM nor the
Xcode project references it.
