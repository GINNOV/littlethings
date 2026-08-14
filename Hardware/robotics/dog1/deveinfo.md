# DogBotOne developer information

This document records what is currently known about the robot dog, its Bluetooth Low Energy (BLE) interface, and the ways this repository can control or probe it.

The app now encodes named movement and action packets in `RobotCommand`. Those encodings are **what the macOS client sends**. They are not a hardware lab notebook. Do not treat a UI label such as Sit as a confirmed physical action until the same bytes have been sent to a live dog and the result has been recorded.

Treat every unrecognized command as potentially consequential.

## Project and device identity

| Item | Known value | Evidence / status |
| --- | --- | --- |
| App target | `DogBotOne` | Current Xcode target and app entry point |
| Current SwiftUI surface | `RemoteView` | `DogBotOneApp.swift` presents `RemoteView()` |
| Legacy developer surface | `ContentView` | Original BLE test UI; still compiles; not the launch surface |
| Advertised device name | `Rapidpower-dog-fire` | Exact name filter in `BLEManager` |
| Human-facing project name | `DogBotOne` | App and remote UI labels |
| Device category | BLE toy / robot dog | UI and prior macOS QA notes |
| Physical behavior verified in this repository | None | No hardware session or behavior log was found |

`Rapidpower-dog-fire` is the BLE advertisement name used for discovery. `DogBotOne` is the project and application name. Do not assume they are the same string on the air.

## What the dog is known to do

The repository does **not** contain observed stand / sit / walk / dance results from a physical dog.

What *is* known:

- The device is expected to advertise as `Rapidpower-dog-fire`.
- After connection, it exposes service `FA879AF4-D601-420C-B2B4-07FFB528DDE3`.
- The client writes command bytes to a characteristic that reports `write` or `writeWithoutResponse`.
- `RemoteView` now sends framed 7-byte packets for drive and named actions. Those packets are defined in `RobotCommand.packet`.
- Raw hexadecimal writes remain available in Developer mode for protocol discovery.

Earlier notes about `controlsAreMapped = false`, locked consumer buttons, and `Stand` / `Sleep` labels are obsolete. The current remote enables the jog wheel and the official 12-action grid plus Swimming and Dance.

## BLE protocol

### BLE terms in plain language

BLE devices expose a small, structured database called GATT. The app is the **central** (the client that scans and connects); the dog is the **peripheral** (the device that advertises and accepts the connection).

The hierarchy developers see is:

```text
Peripheral: Rapidpower-dog-fire
└── Service: a related group of capabilities
    └── Characteristic: one value or data channel within the service
        └── Properties: what operations are allowed on that channel
```

- **Peripheral/device:** The physical dog identified during scanning by its advertised name. A BLE name is useful for finding a device, but it is not a protocol command or a guarantee that the name cannot change.
- **Service:** A logical collection of related functionality. A service has a UUID so a client can ask the dog for a particular group of capabilities. In this project, the expected service is `FA879AF4-...`.
- **Characteristic:** The actual data endpoint inside a service. Commands are written to a writable characteristic; sensor or status data may be read from or received through another characteristic. In this project, the expected command characteristic is `B02EAEAA-...`.
- **Characteristic properties:** Flags reported during discovery. Common properties are `read`, `write`, `writeWithoutResponse`, `notify`, and `indicate`.
  - `read` means the central can request the current value.
  - `write` means the central can send a value and receive a BLE-level write response.
  - `writeWithoutResponse` means the central can send a value without a BLE-level response. This can be faster, but it does not confirm that the dog understood the command.
  - `notify` means the peripheral can push value updates to the central without a request for every update.
  - `indicate` is similar to notification but includes a lower-level delivery confirmation.
- **Discover / discovery:** After connecting, the central asks the peripheral which services and characteristics exist and what properties each characteristic has. This is metadata discovery; it does not discover the dog’s command meanings. Finding a writable characteristic only proves that bytes can be sent to it, not what those bytes do.
- **UUID:** A 128-bit identifier for a service or characteristic. UUIDs identify endpoints; they do not describe the byte-level command format carried by the endpoint.

“Discoverable” can refer to two different things and they should not be confused:

1. A **discoverable peripheral** is visible during scanning and can be found by name or advertised service.
2. A **discoverable characteristic** is found after connection during GATT discovery. Its properties tell the developer whether it is readable, writable, or capable of notifications/indications.

There is no separate “discoverable write” permission. The relevant question is whether the discovered characteristic has the `write` or `writeWithoutResponse` property. The app logs the raw property bitmask for every characteristic and then selects a writable one.

### Identifiers

The expected GATT identifiers in the current client are:

```text
Device name:       Rapidpower-dog-fire
Service UUID:      FA879AF4-D601-420C-B2B4-07FFB528DDE3
Characteristic:    B02EAEAA-F6BC-4A7E-BC94-F7B7FC8DED0B
```

The service UUID is used when retrieving already-connected peripherals and when discovering services after connection.

A live session on 2026-08-14 confirmed those identifiers on a nearby `Rapidpower-dog-fire`:

| Endpoint | UUID | Properties | Role in that session |
| --- | --- | --- | --- |
| Service | `FA879AF4-D601-420C-B2B4-07FFB528DDE3` | — | Discovered after connect |
| Notify characteristic | `10E2FDE2-D7FE-4845-B3F3-A32010EBB095` | `0x10` (notify) | Notifications subscribed and reported active |
| Write characteristic | `B02EAEAA-F6BC-4A7E-BC94-F7B7FC8DED0B` | `0x8` (write) | Selected as the writable command endpoint |

One notification payload was logged without sending a command:

```text
11 EE EE 11
```

`0x11` and `0xEE` are bitwise inverses, so this may be a framed heartbeat or status word. Meaning is unknown. That observation confirms discovery and write-target selection. It does **not** confirm what any command packet does physically. No named motion or action packets were sent during that session.

The characteristic UUID is shown in Developer mode as expected metadata. The write path does **not** require the discovered characteristic to match `B02EAEAA-...`. `BLEManager` discovers every characteristic on the expected service, enables notify/indicate where available, and then selects a writable characteristic by properties:

1. Prefer `.write` (with response).
2. Otherwise accept `.writeWithoutResponse`.
3. If several writable characteristics exist, later discoveries overwrite the selection.

Older notes that listed `0000AF30-0000-1000-8000-00805F9B34FB` as the command characteristic are stale. That UUID is no longer in the source.

For someone inspecting a BLE browser or the app’s activity log:

| What you see | What it means here | What it does not prove |
| --- | --- | --- |
| `Rapidpower-dog-fire` | The advertised peripheral name used by the scanner | That the device is currently connected or that the name is permanent |
| `FA879AF4-...` | The service containing the dog’s relevant BLE endpoints | That the service UUID reveals the command bytes |
| `B02EAEAA-...` | The expected command characteristic UUID shown in the UI | That this is the characteristic actually selected if firmware exposes another writable endpoint |
| `properties=0x...` | The characteristic’s BLE capability flags, printed in hexadecimal | The meaning of any application-level command payload |
| `Selected writable characteristic` | The app found an endpoint it can write to | That the dog accepted or acted on the payload |
| `Received [...]` | A notification or indication value arrived | That the value is an acknowledgement unless the protocol is decoded |

### Connection sequence

`BLEManager` follows this sequence:

1. Create a `CBCentralManager`.
2. Wait for Bluetooth to reach `.poweredOn`.
3. Look for an already-connected peripheral exposing the expected service and named `Rapidpower-dog-fire`.
4. Otherwise scan without a service filter and accept only a peripheral whose name is exactly `Rapidpower-dog-fire`.
5. Stop scanning and connect when the matching peripheral is found.
6. Discover the expected service.
7. Discover all characteristics in that service.
8. Enable notifications or indications on any characteristic that supports them.
9. Select a writable characteristic. Prefer `.write` with response; otherwise use `.writeWithoutResponse`.
10. Send either a `RobotCommand` packet or raw developer hex to the selected characteristic.

The scan timeout is 10 seconds. On timeout, the log reports `Device not found (scan timeout)`. On disconnect, the manager clears the peripheral and characteristic state, stops any active sweep, and starts scanning again.

Status strings the remote shows:

| Status | Meaning |
| --- | --- |
| `Disconnected` | Bluetooth is on, but no session is ready |
| `Bluetooth Off` | System Bluetooth is powered off |
| `Unsupported` | This Mac has no usable BLE |
| `Preparing` | Connected; GATT discovery is still running |
| `Connected` | A writable characteristic has been selected |

### Write behavior

The current write type is selected from the discovered characteristic:

- `.write` is sent with `CBCharacteristicWriteType.withResponse`.
- `.writeWithoutResponse` is sent with `CBCharacteristicWriteType.withoutResponse`.

For response writes, `didWriteValueFor` logs either `Write successful` or the write error. For notification/indication traffic, received bytes are rendered as uppercase, space-separated hexadecimal in the activity log.

A successful BLE write only proves the stack accepted the bytes. It does not prove the dog parsed or acted on them.

## Command packet format

Named controls do not send a single raw opcode. `RobotCommand.packet` builds a 7-byte frame:

```text
F0  P0  P1  P2  ~P0  ~P1  ~P2
```

| Offset | Value | Role in the client |
| ---: | --- | --- |
| 0 | `F0` | Fixed header |
| 1 | `P0` | Command family (`2A` for most motion/actions, `12` for dance) |
| 2 | `P1` | Always `00` in the current map |
| 3 | `P2` | Subcommand / variant |
| 4–6 | bitwise NOT of `P0 P1 P2` | Integrity check encoded by the client |

This frame layout is inferred only from `DogBotOne/DogBotOne/RobotCommand.swift`. Firmware confirmation, endianness beyond this byte order, and whether the inverted trailer is required are still open.

### Current client command map

| Control | `P0 P1 P2` | Full packet the app sends | Notes |
| --- | --- | --- | --- |
| Forward | `2A 00 01` | `F0 2A 00 01 D5 FF FE` | Jog wheel up |
| Left | `2A 00 04` | `F0 2A 00 04 D5 FF FB` | Jog wheel left |
| Right | `2A 00 07` | `F0 2A 00 07 D5 FF F8` | Jog wheel right |
| Stop | `2A 00 0A` | `F0 2A 00 0A D5 FF F5` | Jog wheel center / release |
| Back | `2A 00 0D` | `F0 2A 00 0D D5 FF F2` | Jog wheel down. Inferred: next unused `2A 00` slot after Stop (`0A + 3`). Not hardware-verified. |
| Sit Down | `2A 00 10` | `F0 2A 00 10 D5 FF EF` | Action button |
| Greetings | `2A 00 13` | `F0 2A 00 13 D5 FF EC` | Action button |
| Get Down | `2A 00 16` | `F0 2A 00 16 D5 FF E9` | Official grid after Greetings. Inferred: `13 + 3`. Not hardware-verified. |
| Act Cute | `2A 00 19` | `F0 2A 00 19 D5 FF E6` | Official grid after Get Down. Inferred: `16 + 3`. Not hardware-verified. |
| Handshake | `2A 00 1C` | `F0 2A 00 1C D5 FF E3` | Official grid after Act Cute. Inferred: `19 + 3`. Not hardware-verified. |
| Attack | `2A 00 1F` | `F0 2A 00 1F D5 FF E0` | Official grid after Handshake. Inferred: `1C + 3`. Not hardware-verified. |
| Surrender | `2A 00 22` | `F0 2A 00 22 D5 FF DD` | Official grid after Attack. Inferred: `1F + 3`. Not hardware-verified. |
| Urinate | `2A 00 25` | `F0 2A 00 25 D5 FF DA` | Official grid after Surrender. Inferred: `22 + 3`. Not hardware-verified. |
| Handstand | `2A 00 28` | `F0 2A 00 28 D5 FF D7` | Official grid after Urinate, before Patrol. Inferred: `25 + 3`. Not hardware-verified. |
| Patrol | `2A 00 2B` | `F0 2A 00 2B D5 FF D4` | Action button |
| Kung Fu | `2A 00 2E` | `F0 2A 00 2E D5 FF D1` | Action button |
| Push-up | `2A 00 31` | `F0 2A 00 31 D5 FF CE` | Action button |
| Swimming | `2A 00 34` | `F0 2A 00 34 D5 FF CB` | Official D-pad bottom. Inferred: next unused `2A 00` slot after Push-up (`31 + 3`). Not hardware-verified. |
| Dance | `12 00 01` | `F0 12 00 01 ED FF FE` | Only command using family `12` |
| Stay awake | `2A 00 28` | `F0 2A 00 28 D5 FF D7` | Same bytes as vendor Stand / Handstand. Unused `2A 00 00` is ignored, so it cannot keep the dog awake. |

Pattern notes from the table, not from hardware:

- Motion variants under `2A 00` step by 3: `01` forward, `04` left, `07` right, `0A` stop, then inferred `0D` back.
- The official 12-action grid continues that stride from Sit (`10`) through Push-up (`31`).
- The seven buttons between Greetings and Patrol fill the previously unused slots `16`–`28`.
- Swimming is on the official D-pad, not in that grid, so it is encoded as the next unused slot after Push-up (`34`).
- Vendor Stand / Handstand is `2A 00 28`. Stay awake sends those bytes; unused `2A 00 00` is not a heartbeat.
- Vendor Sleep is family `24` (`F0 24 00 01` … `04`), not Stop.

Confidence for every row: **client encoding only**. Repeat count: 0 live-dog observations in this repository.

## Hex command format

Developer mode still accepts raw hexadecimal with optional spaces, tabs, and newlines. Input is normalized by removing whitespace and must contain:

- at least one byte;
- an even number of hexadecimal characters;
- only `0-9`, `A-F`, or `a-f` characters.

Examples:

```text
01                -> one byte: 0x01
0A FF             -> two bytes: 0x0A, 0xFF
F0 2A 00 0A D5 FF F5 -> the encoded Stop packet
```

Invalid input is rejected and logged. There is no command-language parsing beyond hexadecimal conversion. Raw sends bypass `RobotCommand` and write exactly the parsed bytes.

## Current ways to control or probe the dog

### Active `RemoteView` surface

The application launches `RemoteView`, not `ContentView`.

When a writable characteristic is selected (`status == "Connected"`):

- the jog wheel sends Forward / Back / Left / Right while dragged, Stop when the knob returns to center, and Stop again on release;
- Sit Down, Greetings, Get Down, Act Cute, Handshake, Attack, Surrender, Urinate, Handstand, Patrol, Kung Fu, Push-up, Swimming, and Dance send the packets above;
- Developer mode stays collapsed until opened.

Developer mode provides:

- a raw hex command field and Send button;
- the expected service UUID;
- the expected characteristic UUID;
- the UUID of the characteristic actually selected as writable;
- a reminder that raw commands are for protocol discovery, not consumer controls;
- a link that opens this file (`deveinfo.md`) from the repository root;
- an activity log of connection, writes, errors, and notifications.

The link is built at compile time from `#filePath` of `RemoteView.swift`, walking up three directories to the `dog1` folder and appending `deveinfo.md`. It therefore opens the source-tree copy of this document on the machine that built the app. It is not bundled inside the `.app`.

There is no sweep button on `RemoteView`. Sweep helpers still exist on `BLEManager` and on the legacy `ContentView` surface.

### Legacy `ContentView` developer surface

`ContentView` is the original test UI and still hosts `BLEManager`. It is not the current app entry surface. It still exposes:

- preset one-byte sends: `00`, `01`, `FF`, and `0A`;
- a one-byte sweep over `00` through `FF` by default via `startAutoDiscover()`, with a default delay of 0.5 seconds (the `RemoteView` era `00–0F` / 0.75 s numbers are obsolete);
- a two-byte sweep using prefixes `00`, `01`, `0A`, and `FF`, each followed by `00` through `FF`, for 1,024 total commands, default delay 0.5 seconds;
- a Stop button that cancels an active sweep.

Those sweeps send raw 1-byte or 2-byte values, not the 7-byte `RobotCommand` frame. The two-byte sweep is especially broad and should not be run on an unattended or mechanically unconstrained dog.

## Safe protocol-discovery procedure

Use a controlled test environment before sending unknown bytes:

1. Put the dog on a stable surface with enough clearance for unexpected movement.
2. Keep hands, cables, pets, and fragile objects away from the legs and wheels.
3. Connect and confirm the selected writable characteristic in the log.
4. Record the dog’s initial state and battery/power state.
5. Prefer one `RobotCommand` at a time, or one raw hex candidate at a time.
6. Wait for the dog to stop responding before sending the next candidate.
7. Record the exact bytes, timestamp, observed motion/sound/light, duration, and whether a notification or write response arrived.
8. Repeat a promising command from the same initial state to check that the result is reproducible.
9. Stop immediately if the dog behaves unexpectedly; disconnect power if required for safety.

For sweeps, use a low-risk physical setup and an observer. A lack of visible response is not proof that a command is harmless: it may change a mode, queue an action, or require another byte sequence.

## Suggested command-mapping record

Keep mappings in a table or lab notebook with enough detail to reproduce them:

| Bytes | Length | Initial state | Observed result | Confidence | Repeat count | Notes |
| --- | ---: | --- | --- | --- | ---: | --- |
| `F0 2A 00 0A D5 FF F5` | 7 | powered / idle / standing | motion, sound, light, or none | client encoding / unverified on hardware | 0 | Stop packet as encoded today |

Only mark a command hardware-verified after repeated physical tests. A UI label such as `Sit` is still not evidence that the dog sat.

## Troubleshooting

### Bluetooth is off or unsupported

Enable Bluetooth and retry. The manager reports `Bluetooth Off` or `Unsupported` and does not scan until the central manager is ready.

### The dog is not found

Confirm that it is powered on, nearby, and advertising with the exact name `Rapidpower-dog-fire`. The app scans for all peripherals but filters by name, so a changed or missing advertisement name will prevent connection.

### Connected but no command can be sent

Wait for service and characteristic discovery to finish. Send actions require a selected writable characteristic. Check the activity log for `Selected writable characteristic` or `Selected write-without-response characteristic`.

### Writes succeed but nothing visibly happens

The transport may be correct while the command is unknown, incomplete, state-dependent, or sent to the wrong writable characteristic. Check notifications and repeat with a recorded initial state. Do not assume that a successful BLE write means a valid dog command.

### The device disconnects during testing

The manager clears its write characteristic, stops a sweep, and resumes scanning. Reconnect only after the dog is safe and stable. A disconnect is useful evidence and should be recorded with the last command sent.

### The documentation link does nothing

The Developer mode link opens `deveinfo.md` next to the sources that were compiled into that build. If the project was moved after the build, rebuild so `#filePath` is current. A copied `.app` on another machine will not contain this file.

## Implementation references

- `DogBotOne/DogBotOne/RobotCommand.swift`: 7-byte frame builder and the current named-command map.
- `DogBotOne/DogBotOne/RemoteView.swift`: current remote UI, enabled drive/action controls, developer raw-command field, and documentation link.
- `DogBotOne/DogBotOne/ContentView.swift`: BLE manager, connection lifecycle, hex parser, notification logging, and legacy sweep helpers.
- `DogBotOne/DogBotOne/DogBotOneApp.swift`: current app entry point; launches `RemoteView`.
- `.omo/evidence/dogAttack-macos-foundation-gate-review.md`: prior QA notes that sweep controls transmit command sequences rather than performing device discovery, and that no physical robot behavior was reviewed.
- `.omo/evidence/dogattack-macos-visual-qa-gate-review.md`: prior QA notes confirming the app is a native macOS BLE developer/test utility and documenting remaining evidence gaps.

## Open questions

The following are not answered by the current repository and require hardware testing or additional protocol capture:

- Which of the encoded packets actually produce the labeled motion or animation on a live dog?
- Is the `F0` + inverted-trailer frame required, optional, or client-invented relative to the official controller?
- Why does Dance use family `12` while every other named command uses `2A`?
- Do the inferred `2A 00` slots `16`–`28` and `34` actually match Get Down, Act Cute, Handshake, Attack, Surrender, Urinate, Handstand, and Swimming on a live dog?
- Are commands one-shot, timed, queued, or held (the jog wheel resends when the sector changes, then sends Stop on release)?
- Is there a required initialization, wake, pairing, or mode-selection command?
- Does the dog send useful telemetry or acknowledgements through notifications?
- What do notifications on `10E2FDE2-...` contain (telemetry, ack, IMU, battery)?
- Which writable characteristic is authoritative if the service exposes more than one?
- What are the safe stop, emergency stop, and idle commands on the hardware?
- What payload size and inter-command delay does the firmware require?
- What happened to the older `0000AF30-...` characteristic UUID — firmware change, earlier guess, or a second endpoint?

Until those questions are answered with repeatable hardware evidence, keep raw developer writes available and treat the named buttons as a client-side map, not a finished protocol specification.
