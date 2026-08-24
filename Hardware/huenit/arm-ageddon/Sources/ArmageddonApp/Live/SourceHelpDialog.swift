import ArmageddonCore
import SwiftUI

struct SourceHelpDialog: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let identifierPrefix: String
    let markdown: String
    var onDismiss: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.standard) {
            HStack {
                Label(title, systemImage: "questionmark.circle")
                    .font(DesignTokens.Typography.workspaceTitle)
                    .bold()
                    .accessibilityIdentifier("\(identifierPrefix).title")
                Spacer()
                Button("Close") {
                    onDismiss()
                    dismiss()
                }
                    .keyboardShortcut(.cancelAction)
                    .accessibilityIdentifier("\(identifierPrefix).close")
            }

            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.standard) {
                    ForEach(Array(MarkdownManual.parse(markdown).enumerated()), id: \.offset) { _, block in
                        blockView(block)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(DesignTokens.Spacing.section)
        .frame(minWidth: 540, idealWidth: 600, minHeight: 420, idealHeight: 520)
        .background(DesignTokens.Colors.workspace)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(identifierPrefix)
    }

    @ViewBuilder
    private func blockView(_ block: MarkdownManualBlock) -> some View {
        switch block {
        case .title(let text):
            Text(text)
                .font(DesignTokens.Typography.workspaceTitle)
                .bold()
        case .heading(let text):
            Text(text)
                .font(DesignTokens.Typography.sectionTitle)
                .bold()
                .padding(.top, DesignTokens.Spacing.compact)
                .accessibilityAddTraits(.isHeader)
        case .paragraph(let text):
            Text(paragraph(text))
                .font(DesignTokens.Typography.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        case .bullets(let items):
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .top, spacing: DesignTokens.Spacing.compact) {
                        Text("•")
                        Text(paragraph(item))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .font(DesignTokens.Typography.body)
                }
            }
        }
    }

    private func paragraph(_ markdown: String) -> AttributedString {
        (try? AttributedString(
            markdown: markdown,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(markdown)
    }
}

enum BundledDocumentation {
    static func markdown(in bundle: Bundle = .main) -> String {
        guard let url = bundle.url(forResource: "documentation", withExtension: "md"),
              let text = try? MarkdownManual.load(from: url),
              text.isEmpty == false else {
            return "Help could not be loaded from documentation.md."
        }
        return text
    }

    static func section(_ title: String, in bundle: Bundle = .main) -> String {
        let loaded = markdown(in: bundle)
        let section = MarkdownManual.section(named: title, in: loaded)
        return section.isEmpty ? loaded : section
    }
}
