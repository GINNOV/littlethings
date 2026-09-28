import SwiftUI

struct DashboardView: View {
    @StateObject private var model = AppModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    heroCard
                    sourceCard
                    motorCard
                    motorDebugCard
                    telemetryCard

                    if model.selectedSource == .simulator {
                        simulatorCard
                    }
                }
                .padding(20)
            }
            .navigationTitle("PivoPilot")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Wearable camera tracking")
                .font(.title.bold())

            Text(model.statusText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button(model.isTracking ? "Stop Tracking" : "Start Tracking") {
                    model.toggleTracking()
                }
                .buttonStyle(.borderedProminent)

                Button("Recenter") {
                    model.recenter()
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var sourceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Motion Source", systemImage: "sensor.tag.radiowaves.forward")
                .font(.headline)

            Picker("Motion Source", selection: $model.selectedSource) {
                ForEach(AppModel.MotionSource.allCases) { source in
                    Text(source.rawValue).tag(source)
                }
            }
            .pickerStyle(.segmented)

            Text(model.sourceDescription)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var motorCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Motor Transport", systemImage: "dot.radiowaves.left.and.right")
                .font(.headline)

            HStack {
                metric(title: "Backend", value: model.motorController.displayName)
                metric(title: "State", value: model.motorController.connectionState.rawValue)
            }

            HStack {
                metric(title: "Battery", value: model.motorController.batteryLevel.map { "\($0)%" } ?? "--")
                metric(title: "Speed", value: "\(model.motorController.currentSpeed) s/r")
            }

            Text("License: \(model.motorController.licenseStatus)")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text("Last event: \(model.motorController.lastEventDescription)")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text("Last command: \(model.motorController.lastCommand.description)")
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button("Scan") {
                    model.connectMotor()
                }
                .buttonStyle(.borderedProminent)

                Button("Stop Scan") {
                    model.stopScanning()
                }
                .buttonStyle(.bordered)

                Button("Battery") {
                    model.requestBatteryLevel()
                }
                .buttonStyle(.bordered)

                Button("Disconnect") {
                    model.disconnectMotor()
                }
                .buttonStyle(.bordered)
            }

            if !model.motorController.availableDevices.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Discovered Devices")
                        .font(.subheadline.weight(.semibold))

                    ForEach(model.motorController.availableDevices) { device in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(device.name)
                                Text(device.id)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Button("Connect") {
                                model.connectMotor(to: device)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }

            if !model.motorController.supportedSpeeds.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Motor Speed")
                        .font(.subheadline.weight(.semibold))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(model.motorController.supportedSpeeds, id: \.self) { speed in
                                if speed == model.motorController.currentSpeed {
                                    Button("\(speed)") {
                                        model.setMotorSpeed(speed)
                                    }
                                    .buttonStyle(.borderedProminent)
                                } else {
                                    Button("\(speed)") {
                                        model.setMotorSpeed(speed)
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var motorDebugCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Motor Debug", systemImage: "dial.medium")
                .font(.headline)

            Stepper("Step angle: \(model.manualTurnAngle)°", value: $model.manualTurnAngle, in: 1...360)

            HStack(spacing: 12) {
                Button("Left \(model.manualTurnAngle)°") {
                    model.manualTurnLeft()
                }
                .buttonStyle(.bordered)

                Button("Right \(model.manualTurnAngle)°") {
                    model.manualTurnRight()
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 12) {
                Button("Continuous Left") {
                    model.startContinuousLeft()
                }
                .buttonStyle(.borderedProminent)

                Button("Continuous Right") {
                    model.startContinuousRight()
                }
                .buttonStyle(.borderedProminent)

                Button("Stop") {
                    model.stopMotorMotion()
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var telemetryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Telemetry", systemImage: "gauge.with.dots.needle.67percent")
                .font(.headline)

            HStack {
                metric(title: "Raw Yaw", value: angleString(model.fusion.rawYawDegrees))
                metric(title: "Filtered Yaw", value: angleString(model.fusion.smoothedYawDegrees))
            }

            HStack {
                metric(title: "Reference", value: model.fusion.referenceCaptured ? "Captured" : "Waiting")
                metric(title: "Tracking", value: model.isTracking ? "Live" : "Stopped")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var simulatorCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Simulator Controls", systemImage: "slider.horizontal.3")
                .font(.headline)

            Text("Use the slider to inject yaw changes and validate the mapping without AirPods, watch, or a Pivo stand.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Slider(value: $model.simulatedYawDegrees, in: -180...180, step: 1)

            HStack {
                Button("-15°") {
                    model.nudgeSimulation(by: -15)
                }
                .buttonStyle(.bordered)

                Button("+15°") {
                    model.nudgeSimulation(by: 15)
                }
                .buttonStyle(.bordered)

                Spacer()

                Text(angleString(model.simulatedYawDegrees))
                    .font(.headline.monospacedDigit())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func metric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.monospacedDigit())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func angleString(_ value: Double) -> String {
        "\(value.formatted(.number.precision(.fractionLength(1))))°"
    }
}
