# BLE Toy Controller - Project Plan & PRD

## Project Overview
Build a macOS native application to control a Bluetooth Low Energy (BLE) toy that currently only has an iOS app. The toy connects without traditional pairing, suggesting it uses BLE public advertising.

## Technical Specifications

### Device Information
- **Device Name**: Rapidpower-dog-fire
- **Device UUID**: 177F2F46-1E04-16E1-EEDC-710FAD650404
- **Service UUID**: FA879AF4-D601-420C-B2B4-07FFB528DDE3
- **Characteristic UUID**: 0000AF30-0000-1000-8000-00805F9B34FB (short form: AF30)
- **Characteristic Properties**: Write (writable characteristic for sending commands)
- **Connection Type**: BLE with public advertising (no pairing required)

### Technology Stack
- **Platform**: macOS
- **Language**: Swift
- **Framework**: CoreBluetooth (Apple's native BLE framework)
- **UI**: SwiftUI

## Product Requirements

### Core Features (MVP)

1. **Device Discovery & Connection**
   - Automatically scan for BLE devices on app launch
   - Filter for device named "Rapidpower-dog-fire"
   - Auto-connect when device is discovered
   - Display connection status (Connected/Disconnected)
   - Handle disconnection and reconnection gracefully

2. **Command Interface**
   - Text input field for entering hex commands (e.g., "01", "0A FF")
   - Quick-access buttons for common test commands (0x00, 0x01, 0xFF, 0x0A)
   - Send button to transmit commands to the device
   - Input validation for hex format

3. **Activity Logging**
   - Real-time log of all BLE events (scan, connection, commands sent)
   - Timestamped entries
   - Color-coded by type (info, success, error)
   - Scrollable log view with latest entries at bottom

4. **Device Information Display**
   - Show service UUID
   - Show characteristic UUID
   - Visual connection status indicator (colored dot)

### Technical Implementation Plan

#### Phase 1: BLE Core Setup
1. Create BLEManager class implementing:
   - CBCentralManagerDelegate (for scanning and connection)
   - CBPeripheralDelegate (for service/characteristic discovery)
2. Initialize CBCentralManager
3. Implement scanning logic to filter for target device name
4. Implement connection handling

#### Phase 2: Service Discovery
1. Discover services on connected peripheral
2. Discover characteristics within target service
3. Store reference to writable characteristic (AF30)
4. Validate characteristic properties include .write

#### Phase 3: Command Transmission
1. Implement hex string to Data conversion utility
2. Create sendCommand function using writeValue(_:for:type:)
3. Use .withResponse write type for reliability
4. Handle write completion callbacks

#### Phase 4: UI Development
1. Build SwiftUI interface with three main sections:
   - Header with status and device info
   - Command input section
   - Activity log section
2. Implement ObservableObject pattern for reactive updates
3. Wire up UI controls to BLE manager methods

#### Phase 5: Testing & Refinement
1. Test connection reliability
2. Experiment with different hex commands to reverse-engineer protocol
3. Document which commands produce which behaviors
4. Add more quick-access buttons based on discovered commands

### Required Permissions
- **NSBluetoothAlwaysUsageDescription** in Info.plist
- Value: "This app needs Bluetooth to control your toy"

### Error Handling
- Bluetooth powered off state
- Device not found timeout
- Connection failure recovery
- Invalid hex input validation
- Write errors

### Future Enhancements (Post-MVP)
- Protocol reverse engineering documentation
- Named command presets (once protocol is understood)
- Response monitoring (if device sends data back)
- Multiple device support
- Command history/favorites
- Export log functionality

## Development Environment
- macOS development machine
- Xcode (latest stable version)
- Physical BLE toy device for testing
- iPhone with BLE scanner app (for initial protocol discovery)

## Success Criteria
- App successfully discovers and connects to device
- Commands can be sent reliably to characteristic AF30
- User can experiment with different hex values
- Connection status is clearly visible
- All BLE events are logged for debugging

## Next Steps After MVP
1. Monitor device responses during command testing
2. Document command protocol (map hex values to behaviors)
3. Build higher-level control interface once protocol is understood
4. Add specialized controls (sliders, toggles) for specific functions

## Notes
- The protocol is currently unknown and needs to be reverse-engineered
- Initial phase is exploratory - sending various hex values to discover functionality
- The writable characteristic is the primary control interface
- Device may have additional readable characteristics for state/feedback (to be investigated)
