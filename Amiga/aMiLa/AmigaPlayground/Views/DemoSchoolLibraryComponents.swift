import SwiftUI

enum DemoSchoolLibraryProgress {
    static func sequenceNumber(from name: String) -> Int? {
        let prefix = name.prefix(while: { $0.isNumber })
        guard !prefix.isEmpty else { return nil }
        return Int(prefix)
    }

    static func reference(_ reference: String, matches title: String) -> Bool {
        let cleanedReference = normalized(reference)
        let cleanedTitle = normalized(title)
        return cleanedReference == cleanedTitle ||
            cleanedReference.contains(cleanedTitle) ||
            cleanedTitle.contains(cleanedReference)
    }

    private static func normalized(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: #"^(requires|uses)\s+"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct DemoSchoolProgressHeader: View {
    let title: String
    let metadata: DemoSchoolMetadata
    let sequenceNumber: Int?
    let totalCount: Int
    let previousTitle: String?
    let nextTitle: String?
    let onPrevious: (() -> Void)?
    let onNext: (() -> Void)?
    var onDependencySelected: ((String) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 10) {
                if let sequenceNumber {
                    Text(String(format: "%02d", sequenceNumber))
                        .font(.title3.monospacedDigit().weight(.semibold))
                        .frame(width: 42, height: 34)
                        .background(.secondary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .accessibilityLabel("Lesson \(sequenceNumber) of \(totalCount)")
                        .accessibilityIdentifier("demoSchoolSequenceNumber")
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title.isEmpty ? "Untitled" : title)
                        .font(.headline)
                        .lineLimit(1)
                    Text("\(metadata.stage) / \(metadata.effectType) / \(metadata.difficulty)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                HStack(spacing: 6) {
                    Button {
                        onPrevious?()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(onPrevious == nil)
                    .help(previousTitle ?? "No previous lesson")
                    .accessibilityIdentifier("demoSchoolPreviousButton")

                    Button {
                        onNext?()
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(onNext == nil)
                    .help(nextTitle ?? "No next lesson")
                    .accessibilityIdentifier("demoSchoolNextButton")
                }
                .buttonStyle(.bordered)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 170), alignment: .leading)], alignment: .leading, spacing: 10) {
                DemoSchoolChipGroup(title: "Requires", values: metadata.dependencies, emptyValue: "None", onSelect: onDependencySelected)
                DemoSchoolChipGroup(title: "Concepts", values: metadata.concepts, emptyValue: "None")
                DemoSchoolChipGroup(title: "Builds", values: metadata.value, emptyValue: "Learn")
            }
        }
        .padding(10)
        .background(.quaternary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct DemoSchoolChipGroup: View {
    let title: String
    let values: [String]
    let emptyValue: String
    var onSelect: ((String) -> Void)?

    private var visibleValues: [String] {
        let cleaned = values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return cleaned.isEmpty ? [emptyValue] : Array(cleaned.prefix(3))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 4) {
                ForEach(visibleValues, id: \.self) { value in
                    if let onSelect, value != emptyValue {
                        Button {
                            onSelect(value)
                        } label: {
                            DemoSchoolChipLabel(value: value)
                        }
                        .buttonStyle(.plain)
                        .help("Open \(value)")
                        .accessibilityLabel("\(title): \(value)")
                        .accessibilityHint("Opens the referenced lesson")
                    } else {
                        DemoSchoolChipLabel(value: value)
                            .accessibilityLabel("\(title): \(value)")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DemoSchoolChipLabel: View {
    let value: String

    var body: some View {
        Text(value)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .truncationMode(.middle)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(.secondary.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var widestLine: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if lineWidth > 0, lineWidth + spacing + size.width > maxWidth {
                totalHeight += lineHeight + spacing
                widestLine = max(widestLine, lineWidth)
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth += lineWidth == 0 ? size.width : spacing + size.width
                lineHeight = max(lineHeight, size.height)
            }
        }

        totalHeight += lineHeight
        widestLine = max(widestLine, lineWidth)
        return CGSize(width: proposal.width ?? widestLine, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var point = bounds.origin
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if point.x > bounds.minX, point.x + size.width > bounds.maxX {
                point.x = bounds.minX
                point.y += lineHeight + spacing
                lineHeight = 0
            }

            subview.place(at: point, proposal: ProposedViewSize(size))
            point.x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

struct DemoSchoolFilterBar: View {
    @Binding var difficulty: String
    @Binding var stage: String
    @Binding var language: String
    @Binding var effectType: String
    @Binding var hardware: String
    @Binding var status: String
    var showsLanguage: Bool = true

    private var activeFilterCount: Int {
        [
            difficulty,
            stage,
            showsLanguage ? language : "All",
            effectType,
            hardware,
            status
        ].filter { $0 != "All" }.count
    }

    var body: some View {
        HStack {
            Menu {
                DemoSchoolFilterPicker(title: "Difficulty", selection: $difficulty, options: DemoSchoolFilterOptions.difficulties)
                DemoSchoolFilterPicker(title: "Stage", selection: $stage, options: DemoSchoolFilterOptions.stages)
                if showsLanguage {
                    DemoSchoolFilterPicker(title: "Language", selection: $language, options: DemoSchoolFilterOptions.languages)
                }
                DemoSchoolFilterPicker(title: "Effect", selection: $effectType, options: DemoSchoolFilterOptions.effectTypes)
                DemoSchoolFilterPicker(title: "Hardware", selection: $hardware, options: DemoSchoolFilterOptions.hardware)
                DemoSchoolFilterPicker(title: "Status", selection: $status, options: DemoSchoolFilterOptions.statuses)

                Divider()

                Button("Reset Filters") {
                    resetFilters()
                }
                .disabled(activeFilterCount == 0)
            } label: {
                Label(activeFilterCount == 0 ? "Filters" : "Filters (\(activeFilterCount))", systemImage: activeFilterCount == 0 ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Filters")
            .accessibilityValue(activeFilterCount == 0 ? "No filters applied" : "\(activeFilterCount) applied")

            Spacer()
        }
    }

    private func resetFilters() {
        difficulty = "All"
        stage = "All"
        language = "All"
        effectType = "All"
        hardware = "All"
        status = "All"
    }
}

struct DemoSchoolFilterPicker: View {
    let title: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        Menu(title) {
            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                } label: {
                    if selection == option {
                        Label(option, systemImage: "checkmark")
                    } else {
                        Text(option)
                    }
                }
            }
        }
        .accessibilityLabel(title)
        .accessibilityValue(selection == "All" ? "All" : selection)
    }
}

struct DemoSchoolVerifiedIcon: View {
    var body: some View {
        Image(systemName: "checkmark.seal.fill")
            .font(.caption)
            .foregroundStyle(.green)
            .accessibilityLabel("Verified")
    }
}

struct DemoSchoolTagRow: View {
    let tags: [String]

    var body: some View {
        FlowLayout(spacing: 4) {
            ForEach(Array(tags.prefix(4)), id: \.self) { tag in
                Text(tag)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(.secondary.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(tags.prefix(4).joined(separator: ", "))
    }
}

struct DemoSchoolMetadataPanel: View {
    let metadata: DemoSchoolMetadata

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Demo School Metadata")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), alignment: .leading)], alignment: .leading, spacing: 8) {
                DemoSchoolMetadataField(title: "Difficulty", value: metadata.difficulty)
                DemoSchoolMetadataField(title: "Stage", value: metadata.stage)
                DemoSchoolMetadataField(title: "Language", value: metadata.language)
                DemoSchoolMetadataField(title: "Effect", value: metadata.effectType)
                DemoSchoolMetadataField(title: "Status", value: metadata.status)
                DemoSchoolMetadataField(title: "Hardware", value: metadata.hardware.joined(separator: ", "))
                DemoSchoolMetadataField(title: "Concepts", value: metadata.concepts.joined(separator: ", "))
                DemoSchoolMetadataField(title: "Value", value: metadata.value.joined(separator: ", "))
                DemoSchoolMetadataField(title: "Dependencies", value: metadata.dependencies.isEmpty ? "None" : metadata.dependencies.joined(separator: ", "))
            }
        }
        .padding(10)
        .background(.quaternary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct DemoSchoolMetadataEditor: View {
    @Binding var metadata: DemoSchoolMetadata
    var showsLanguage: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Demo School Metadata")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), alignment: .leading)], alignment: .leading, spacing: 10) {
                DemoSchoolMetadataPicker(title: "Difficulty", selection: $metadata.difficulty, options: DemoSchoolFilterOptions.difficulties.filter { $0 != "All" })
                DemoSchoolMetadataPicker(title: "Stage", selection: $metadata.stage, options: DemoSchoolFilterOptions.stages.filter { $0 != "All" })
                if showsLanguage {
                    DemoSchoolMetadataPicker(title: "Language", selection: $metadata.language, options: DemoSchoolFilterOptions.languages.filter { $0 != "All" })
                }
                DemoSchoolMetadataPicker(title: "Effect", selection: $metadata.effectType, options: DemoSchoolFilterOptions.effectTypes.filter { $0 != "All" })
                DemoSchoolMetadataPicker(title: "Status", selection: $metadata.status, options: DemoSchoolFilterOptions.statuses.filter { $0 != "All" })
            }

            DemoSchoolTokenField(title: "Hardware", values: $metadata.hardware, placeholder: "Copper, Blitter, Paula")
            DemoSchoolTokenField(title: "Concepts", values: $metadata.concepts, placeholder: "VBlank, DMA, sine table")
            DemoSchoolTokenField(title: "Value", values: $metadata.value, placeholder: "Learn, Reuse, Showcase")
            DemoSchoolTokenField(title: "Dependencies", values: $metadata.dependencies, placeholder: "Requires 02 System Skeleton")
        }
        .padding(10)
        .background(.quaternary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct DemoSchoolMetadataPicker: View {
    let title: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)

            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .labelsHidden()
            .accessibilityLabel(title)
            .accessibilityValue(selection)
        }
    }
}

struct DemoSchoolTokenField: View {
    let title: String
    @Binding var values: [String]
    let placeholder: String

    private var text: Binding<String> {
        Binding(
            get: { values.joined(separator: ", ") },
            set: { newValue in
                values = newValue
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            TextField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
                .accessibilityLabel(title)
        }
    }
}

struct DemoSchoolMetadataField: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value.isEmpty ? "None" : value)
                .font(.caption)
                .lineLimit(2)
        }
    }
}
