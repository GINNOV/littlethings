//
//  ContentView.swift
//  dogAttack
//
//  Created by Mario Esposito on 1/13/26.
//

import SwiftUI
import CoreBluetooth
import Combine

// MARK: - Bluetooth Manager
class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var status = "Disconnected"
    @Published var logs: [LogEntry] = []
    @Published var isAutoDiscovering = false
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?
    private var writeType: CBCharacteristicWriteType = .withResponse
    private var scanTimeoutWorkItem: DispatchWorkItem?
    private var autoDiscoverTask: Task<Void, Never>?
    
    let targetDeviceName = "Rapidpower-dog-fire"
    let serviceUUID = CBUUID(string: "FA879AF4-D601-420C-B2B4-07FFB528DDE3")
    let characteristicUUID = CBUUID(string: "0000AF30-0000-1000-8000-00805F9B34FB")
    let scanTimeout: TimeInterval = 10
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func addLog(_ message: String, type: LogType = .info) {
        DispatchQueue.main.async {
            self.logs.append(LogEntry(message: message, type: type))
        }
    }
    
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            addLog("Bluetooth not ready to scan", type: .error)
            return
        }
        addLog("Starting scan...")
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        scheduleScanTimeout()
    }
    
    func stopScanning() {
        centralManager.stopScan()
        scanTimeoutWorkItem?.cancel()
        scanTimeoutWorkItem = nil
        addLog("Stopped scanning")
    }
    
    func disconnect() {
        if let peripheral = peripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }

    func reconnect() {
        addLog("Reconnecting...")
        stopScanning()
        if let peripheral = peripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        peripheral = nil
        writeCharacteristic = nil
        startScanning()
    }

    func sendHex(_ hexString: String) {
        guard let characteristic = writeCharacteristic else {
            addLog("Not connected to characteristic", type: .error)
            return
        }
        
        guard let data = parseHexInput(hexString) else { return }
        
        peripheral?.writeValue(data, for: characteristic, type: writeType)
        addLog("Sent: \(hexString)", type: .success)
    }

    func startAutoDiscover(range: ClosedRange<UInt8> = 0x00...0x0F, delaySeconds: TimeInterval = 0.5) {
        let sequence = range.map { String(format: "%02X", $0) }
        startAutoDiscoverSequence(sequence, label: "1-byte", delaySeconds: delaySeconds)
    }

    func startAutoDiscoverTwoByte(
        prefixes: [UInt8] = [0x00, 0x01, 0x0A, 0xFF],
        secondByteRange: ClosedRange<UInt8> = 0x00...0xFF,
        delaySeconds: TimeInterval = 0.5
    ) {
        var sequence: [String] = []
        sequence.reserveCapacity(prefixes.count * (secondByteRange.count))
        for prefix in prefixes {
            for value in secondByteRange {
                sequence.append(String(format: "%02X %02X", prefix, value))
            }
        }
        startAutoDiscoverSequence(sequence, label: "2-byte", delaySeconds: delaySeconds)
    }

    private func startAutoDiscoverSequence(_ sequence: [String], label: String, delaySeconds: TimeInterval) {
        guard peripheral?.state == .connected else {
            addLog("Not connected to device", type: .error)
            return
        }
        if isAutoDiscovering {
            addLog("Auto discover already running", type: .info)
            return
        }
        autoDiscoverTask?.cancel()
        autoDiscoverTask = Task { [weak self] in
            guard let self = self else { return }
            await MainActor.run {
                self.isAutoDiscovering = true
                self.addLog("Auto discover started (\(label), \(sequence.count) commands)")
            }
            let ready = await self.waitForWriteCharacteristic(timeoutSeconds: 5)
            if !ready {
                await MainActor.run {
                    self.isAutoDiscovering = false
                    self.addLog("Characteristic not ready yet (timeout)", type: .error)
                }
                return
            }
            for hex in sequence {
                if Task.isCancelled { break }
                self.sendHex(hex)
                try? await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
            }
            await MainActor.run {
                self.isAutoDiscovering = false
                self.addLog("Auto discover finished")
            }
        }
    }

    func stopAutoDiscover() {
        guard isAutoDiscovering else { return }
        autoDiscoverTask?.cancel()
        autoDiscoverTask = nil
        isAutoDiscovering = false
        addLog("Auto discover stopped", type: .info)
    }
    
    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            status = "Disconnected"
            addLog("Bluetooth powered on")
            startScanning()
        case .poweredOff:
            status = "Bluetooth Off"
            addLog("Bluetooth powered off", type: .error)
        case .unsupported:
            status = "Unsupported"
            addLog("Bluetooth not supported", type: .error)
        default:
            addLog("Bluetooth state: \(central.state.rawValue)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == targetDeviceName {
            addLog("Found device: \(peripheral.name ?? "Unknown")")
            self.peripheral = peripheral
            central.stopScan()
            scanTimeoutWorkItem?.cancel()
            central.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        addLog("Connected!", type: .success)
        status = "Connected"
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        addLog("Disconnected", type: .error)
        status = "Disconnected"
        self.peripheral = nil
        self.writeCharacteristic = nil
        stopAutoDiscover()
        startScanning()
    }
    
    // MARK: - CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            addLog("Found service: \(service.uuid)")
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            addLog("Found characteristic: \(characteristic.uuid)")
            if characteristic.uuid == characteristicUUID {
                if characteristic.properties.contains(.write) {
                    writeType = .withResponse
                } else if characteristic.properties.contains(.writeWithoutResponse) {
                    writeType = .withoutResponse
                } else {
                    addLog("Characteristic not writable", type: .error)
                    continue
                }
                writeCharacteristic = characteristic
                addLog("Ready to send commands!", type: .success)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            addLog("Write error: \(error.localizedDescription)", type: .error)
        } else {
            addLog("Write successful", type: .success)
        }
    }

    private func scheduleScanTimeout() {
        scanTimeoutWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            if self.peripheral == nil {
                self.addLog("Device not found (scan timeout)", type: .error)
                self.stopScanning()
            }
        }
        scanTimeoutWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + scanTimeout, execute: workItem)
    }

    private func parseHexInput(_ input: String) -> Data? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            addLog("Hex input is empty", type: .error)
            return nil
        }
        let compact = trimmed.split { $0 == " " || $0 == "\n" || $0 == "\t" }.joined()
        guard compact.count % 2 == 0 else {
            addLog("Hex input must be an even number of characters", type: .error)
            return nil
        }
        for char in compact {
            if !char.isHexDigit {
                addLog("Invalid hex character: \(char)", type: .error)
                return nil
            }
        }
        guard let data = Data(hexString: compact) else {
            addLog("Invalid hex string", type: .error)
            return nil
        }
        return data
    }

    private func waitForWriteCharacteristic(timeoutSeconds: TimeInterval) async -> Bool {
        let deadline = Date().addingTimeInterval(timeoutSeconds)
        while Date() < deadline {
            if writeCharacteristic != nil { return true }
            try? await Task.sleep(nanoseconds: 200_000_000)
        }
        return false
    }
}

// MARK: - Models
struct LogEntry: Identifiable {
    let id = UUID()
    let time = Date()
    let message: String
    let type: LogType
}

enum LogType {
    case info, success, error
}

extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var i = hexString.startIndex
        for _ in 0..<len {
            let j = hexString.index(i, offsetBy: 2)
            let bytes = hexString[i..<j]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
            i = j
        }
        self = data
    }
}

// MARK: - SwiftUI View
struct ContentView: View {
    @StateObject private var bleManager = BLEManager()
    @State private var hexInput = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
                VStack(alignment: .leading) {
                    Text("BLE Toy Controller")
                        .font(.title)
                        .bold()
                    Text("Rapidpower-dog-fire")
                        .foregroundColor(.secondary)
                }
                Spacer()
                Circle()
                    .fill(bleManager.status == "Connected" ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                Text(bleManager.status)
                Button("Reconnect") {
                    bleManager.reconnect()
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Service UUID:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(bleManager.serviceUUID.uuidString)
                        .font(.system(.caption, design: .monospaced))
                }
                HStack {
                    Text("Characteristic UUID:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(bleManager.characteristicUUID.uuidString)
                        .font(.system(.caption, design: .monospaced))
                }
            }
            
            // Send Command Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Send Command")
                    .font(.headline)
                
                HStack {
                    TextField("Enter hex (e.g., 01 or 0A FF)", text: $hexInput)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Send") {
                        bleManager.sendHex(hexInput)
                    }
                    .disabled(bleManager.status != "Connected" || !hexInputIsValid)
                }

                if !hexInput.isEmpty && !hexInputIsValid {
                    Text("Invalid hex input")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                HStack {
                    ForEach(["00", "01", "FF", "0A"], id: \.self) { hex in
                        Button("0x\(hex)") {
                            bleManager.sendHex(hex)
                        }
                        .disabled(bleManager.status != "Connected")
                    }
                }

                HStack {
                    Button("Auto Discover (1-byte)") {
                        bleManager.startAutoDiscover()
                    }
                    .disabled(bleManager.status != "Connected" || bleManager.isAutoDiscovering)

                    Button("Auto Discover (2-byte)") {
                        bleManager.startAutoDiscoverTwoByte()
                    }
                    .disabled(bleManager.status != "Connected" || bleManager.isAutoDiscovering)

                    Button("Stop") {
                        bleManager.stopAutoDiscover()
                    }
                    .disabled(!bleManager.isAutoDiscovering)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
            
            // Log Section
            VStack(alignment: .leading) {
                Text("Activity Log")
                    .font(.headline)
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(bleManager.logs) { log in
                                HStack {
                                    Text(log.time, style: .time)
                                        .foregroundColor(.secondary)
                                        .font(.system(.caption, design: .monospaced))
                                    Text(log.message)
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(colorForLogType(log.type))
                                }
                                .id(log.id)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .onChange(of: bleManager.logs.count) {
                        if let last = bleManager.logs.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
                .frame(height: 200)
                .padding(8)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
        .frame(minWidth: 600, minHeight: 500)
    }
    
    func colorForLogType(_ type: LogType) -> Color {
        switch type {
        case .info: return .primary
        case .success: return .green
        case .error: return .red
        }
    }

    private var hexInputIsValid: Bool {
        let trimmed = hexInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return false }
        let compact = trimmed.split { $0 == " " || $0 == "\n" || $0 == "\t" }.joined()
        guard compact.count % 2 == 0 else { return false }
        return compact.allSatisfy { $0.isHexDigit }
    }
}
