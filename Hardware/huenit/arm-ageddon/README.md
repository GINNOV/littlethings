# Arm-ageddon

Arm-ageddon is a native Swift controller for the HUENIT robotic arm. The first
goal is dependable, observable, and safe USB serial control on macOS. Vision,
automation, and support for additional modules can build on that foundation.

## Initial scope

- Discover and connect to the arm over USB serial at 115200 baud.
- Parse pose and status responses into typed Swift values.
- Jog and move the arm while enforcing workspace limits.
- Stop motion immediately and safely.
- Control the suction module and other verified attachments.
- Record and replay movement sequences.
- Exercise protocol behavior without hardware using recorded serial fixtures.

## Capabilities in the Python reference

The projects under `/Users/megov/Downloads/huenit-external` are an important
behavioral reference. Together they cover substantially more than basic jogging.

### Arm control

- Discover the FTDI serial device and communicate at 115200 baud.
- Query Cartesian position and joint angles.
- Move in Cartesian space with `G0` and `G1`, or command joint angles directly.
- Engage and release the motors for manual teaching.
- Set the current position and wait for queued motion to complete.
- Control pump power, valve state, suction, gripper state, and suction-cup angle.
- Drive the arm interactively with a SpaceMouse.

### Camera and machine learning

- Download and convert Open Images datasets for custom labels.
- Calculate YOLO anchors with k-means and Gaussian-mixture clustering.
- Train, evaluate, and run object-detection models.
- Produce mAP reports and retain inference results for comparison.
- Convert trained models for K210/CanMV deployment and generate on-device
  detector scripts.
- Run live camera inference with bounding boxes and labels on the K210 display.
- Send detected bounding-box coordinates over K210 UART at 115200 baud.
- Provide host-side examples for TensorFlow Lite, Arm NN, Edge TPU, and OAK
  inference backends.

`example_scripts/arm_nn` refers to the Arm NN inference framework, not the
HUENIT robot arm. The local Python export contains both arm control and camera
intelligence, but no verified closed loop that converts a detection into a safe
robot target. That boundary requires camera calibration, coordinate transforms,
workspace validation, and motion policy. `jpwilhelms/huenit_vision` is the most
relevant reference for building it.

Arm-ageddon should preserve these capabilities without porting the entire
training stack to Swift. Training and K210 model generation can remain external
tools; the native app should own camera preview, inference-result ingestion,
calibration, target selection, safety checks, and arm execution. Core ML and
Vision are the preferred macOS-native inference path when models can be
converted reliably.

## Architecture priorities

1. A typed command and response layer with optional raw serial logging.
2. A `WorkspaceValidator` based on verified HUENIT geometry.
3. A safety interlock that rejects movement until the connection, coordinate
   mode, current pose, and target bounds are known.
4. Command profiles for firmware or API variants, especially module commands.
5. Recorded serial fixtures for deterministic tests without a connected arm.
6. Firmware and NVS backup instructions before homing or firmware experiments.

Keep the transport, protocol, safety, and UI layers independent. The UI should
request operations from the arm model rather than constructing G-code directly.

## Protocol notes

The available sources disagree about module commands:

- The Hackaday investigation and existing Python implementation use
  `M1400 A...` and `M1401 A...` for the vacuum pump and valve.
- The unofficial community SDK documents `M1111`, `M1112`, `M1113`, and
  `M1114` for suction, gripper, and pump operations.

Treat these as firmware or API profiles until they have been verified against
captured serial responses. Do not silently fall back from one command family to
another.

## Safety rules

- Never send Marlin `G28`. The arm has no limit switches and may drive into its
  physical limits.
- Reject unvalidated Cartesian targets before they reach the serial transport.
- Do not move until the current pose and coordinate mode are known.
- Provide an always-available stop action and stop when app focus is lost.
- Use conservative speeds for first-contact and live-hardware tests.
- Separate hardware-moving tests from the default test suite.
- Back up the ESP32 firmware and NVS calibration data before firmware work.

## Reference material

### Primary protocol and control references

- [Getting to know Huenit](https://hackaday.io/project/204061-getting-to-know-huenit)
  documents the FYSETC E4/ESP32 controller, customized Marlin behavior,
  calibration risks, encoder queries, and discovered commands.
- [piramja/huenit](https://github.com/piramja/huenit) provides small Python
  examples for jogging and teach-and-replay. It is GPL-3.0 licensed; use it as a
  behavioral reference unless this project's licensing is made compatible.
- [elandivar/huenit_community_sdk](https://github.com/elandivar/huenit_community_sdk)
  documents the reverse-engineered Huenit event model and proprietary Python
  environment. Its findings are incomplete and no clear repository license was
  found, so treat it as documentation rather than reusable source.
- [jpwilhelms/huenit_vision](https://github.com/jpwilhelms/huenit_vision)
  contains workspace validation, camera calibration, visual servoing, and a
  larger Python robot-control layer.

### AI and firmware references

- [huenit-paul/ai-for-huenit](https://github.com/huenit-paul/ai-for-huenit) is
  an MIT-licensed Keras/aXeleRate fork for the K210/CanMV AI-camera pipeline.
- [MarlinFirmware/Marlin](https://github.com/MarlinFirmware/Marlin) provides
  the upstream firmware context and FYSETC E4 support. HUENIT-specific firmware
  behavior must still be measured rather than assumed from upstream Marlin.
- [HUENIT English manual](https://huenit.gitbook.io/huenit-manual-en) documents
  official user-facing behavior such as connection, jogging, Teach & Play,
  stopping, module control, and G-code execution.

## Lower-priority findings

- [sjungwoo0127/huenit-smart-city](https://github.com/sjungwoo0127/huenit-smart-city)
  is useful Korean product and deployment documentation, but not an arm-control
  implementation.
- `sjungwoo-0127/HUENIT-VIDEO` and `choyounghyun/huenit_test` were empty when
  reviewed.
- `choyounghyun/huenit_public` contained release notes rather than source code.

## First milestone

Before adding advanced UI or vision features, prove a minimal vertical slice:

1. Detect the correct serial device.
2. Connect without moving the arm.
3. Query and parse the current pose.
4. Send one bounded, low-speed move.
5. Wait for completion and query the resulting pose.
6. Stop safely on command, disconnect, or application focus loss.

The captured request and response transcript becomes the first protocol fixture
and the baseline for subsequent Swift tests.
