import AppKit
import SwiftUI

struct PromptLibraryView: View {
    @StateObject private var store = PromptLibraryStore.shared
    @State private var searchText = ""
    @State private var selectedPromptID: PromptLibraryItem.ID?
    @State private var draftName = ""
    @State private var draftPrompt = ""
    @State private var draftMetadata = DemoSchoolMetadata()
    @State private var copiedPromptID: PromptLibraryItem.ID?
    @State private var difficultyFilter = "All"
    @State private var stageFilter = "All"
    @State private var languageFilter = "All"
    @State private var effectTypeFilter = "All"
    @State private var hardwareFilter = "All"
    @State private var statusFilter = "All"

    private var filteredPrompts: [PromptLibraryItem] {
        let filter = DemoSchoolLibraryFilter(
            searchText: searchText,
            difficulty: difficultyFilter,
            stage: stageFilter,
            language: languageFilter,
            effectType: effectTypeFilter,
            hardware: hardwareFilter,
            status: statusFilter
        )

        return store.prompts.filter { item in
            filter.matches(name: item.name, body: item.prompt, metadata: item.metadata)
        }
    }

    private var selectedPrompt: PromptLibraryItem? {
        store.prompt(withID: selectedPromptID)
    }

    private var previousPrompt: PromptLibraryItem? {
        adjacentPrompt(offset: -1)
    }

    private var nextPrompt: PromptLibraryItem? {
        adjacentPrompt(offset: 1)
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                DemoSchoolFilterBar(
                    difficulty: $difficultyFilter,
                    stage: $stageFilter,
                    language: $languageFilter,
                    effectType: $effectTypeFilter,
                    hardware: $hardwareFilter,
                    status: $statusFilter
                )
                .padding(10)

                List(selection: $selectedPromptID) {
                    ForEach(filteredPrompts) { item in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 6) {
                                if item.metadata.status == "Verified" {
                                    DemoSchoolVerifiedIcon()
                                }

                                Text(item.name.isEmpty ? "Untitled Prompt" : item.name)
                                    .font(.body.weight(.medium))
                                    .lineLimit(1)
                            }

                            Text(item.prompt)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)

                            DemoSchoolTagRow(tags: item.metadata.visibleTags)
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(item.name.isEmpty ? "Untitled Prompt" : item.name)
                        .accessibilityValue("\(item.metadata.difficulty), \(item.metadata.stage), \(item.metadata.status)")
                        .tag(item.id)
                    }
                }
                .listStyle(.sidebar)
                .searchable(text: $searchText, placement: .sidebar, prompt: "Search prompts and tags")
                .accessibilityIdentifier("promptLibraryList")

                Divider()

                HStack {
                    Button {
                        addPrompt()
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                    .accessibilityIdentifier("addPromptButton")

                    Spacer()
                }
                .padding(10)
            }
            .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 340)
        } detail: {
            if selectedPrompt == nil {
                ContentUnavailableView("No Prompt Selected", systemImage: "text.quote")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    promptEditor
                        .padding(16)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .frame(minWidth: 760, minHeight: 460)
        .onAppear {
            selectInitialPromptIfNeeded()
        }
        .onChange(of: selectedPromptID) {
            loadSelectedPromptDraft()
        }
    }

    private var promptEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let selectedPrompt {
                DemoSchoolProgressHeader(
                    title: draftName,
                    metadata: draftMetadata,
                    sequenceNumber: DemoSchoolLibraryProgress.sequenceNumber(from: selectedPrompt.name),
                    totalCount: store.prompts.count,
                    previousTitle: previousPrompt?.name,
                    nextTitle: nextPrompt?.name,
                    onPrevious: previousPrompt.map { prompt in { selectPrompt(prompt) } },
                    onNext: nextPrompt.map { prompt in { selectPrompt(prompt) } },
                    onDependencySelected: openDependencyPrompt
                )
                .accessibilityIdentifier("promptProgressHeader")
            }

            HStack(spacing: 10) {
                TextField("Prompt name", text: $draftName)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(saveDraft)
                    .accessibilityLabel("Prompt name")
                    .accessibilityIdentifier("promptNameField")

                Button {
                    saveDraft()
                } label: {
                    Label("Save", systemImage: "checkmark")
                }
                .disabled(!canSaveDraft)
                .accessibilityIdentifier("savePromptButton")

                Button(role: .destructive) {
                    deleteSelectedPrompt()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .accessibilityIdentifier("deletePromptButton")
            }

            Text("Prompt")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            TextEditor(text: $draftPrompt)
                .font(.body.monospaced())
                .frame(minHeight: 220, idealHeight: 260, maxHeight: 320)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                )
                .accessibilityLabel("Prompt body")
                .accessibilityIdentifier("promptBodyEditor")

            DemoSchoolMetadataEditor(metadata: $draftMetadata)
                .accessibilityIdentifier("promptMetadataEditor")

            HStack(spacing: 10) {
                Button {
                    copySelectedPrompt()
                } label: {
                    Label(copiedPromptID == selectedPromptID ? "Copied" : "Copy", systemImage: copiedPromptID == selectedPromptID ? "checkmark" : "doc.on.doc")
                }
                .disabled(draftPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("copyPromptLibraryPromptButton")

                Button {
                    pasteSelectedPromptIntoChat()
                } label: {
                    Label("Paste to Chat", systemImage: "arrow.down.message")
                }
                .disabled(draftPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("pastePromptToChatButton")

                Spacer()

                if let selectedPrompt {
                    Text("Updated \(selectedPrompt.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Last updated \(selectedPrompt.updatedAt.formatted(date: .complete, time: .shortened))")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var canSaveDraft: Bool {
        !draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !draftPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func addPrompt() {
        let item = store.createPrompt()
        selectedPromptID = item.id
        loadSelectedPromptDraft()
    }

    private func saveDraft() {
        guard let selectedPromptID, canSaveDraft else { return }
        store.updatePrompt(
            id: selectedPromptID,
            name: draftName.isEmpty ? "Untitled Prompt" : draftName,
            prompt: draftPrompt,
            metadata: draftMetadata
        )
    }

    private func deleteSelectedPrompt() {
        guard let selectedPromptID else { return }
        store.deletePrompt(id: selectedPromptID)
        self.selectedPromptID = filteredPrompts.first?.id
        loadSelectedPromptDraft()
    }

    private func copySelectedPrompt() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(draftPrompt, forType: .string)
        copiedPromptID = selectedPromptID

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if copiedPromptID == selectedPromptID {
                copiedPromptID = nil
            }
        }
    }

    private func pasteSelectedPromptIntoChat() {
        saveDraft()
        NotificationCenter.default.post(
            name: .pastePromptIntoAssistant,
            object: nil,
            userInfo: ["prompt": draftPrompt]
        )
    }

    private func selectInitialPromptIfNeeded() {
        if selectedPromptID == nil {
            selectedPromptID = filteredPrompts.first?.id
        }
        loadSelectedPromptDraft()
    }

    private func adjacentPrompt(offset: Int) -> PromptLibraryItem? {
        guard let selectedPromptID,
              let currentIndex = store.prompts.firstIndex(where: { $0.id == selectedPromptID }) else {
            return nil
        }

        let targetIndex = currentIndex + offset
        guard store.prompts.indices.contains(targetIndex) else { return nil }
        return store.prompts[targetIndex]
    }

    private func selectPrompt(_ prompt: PromptLibraryItem) {
        if canSaveDraft {
            saveDraft()
        }
        selectedPromptID = prompt.id
        loadSelectedPromptDraft()
    }

    private func openDependencyPrompt(_ dependency: String) {
        guard let prompt = store.prompts.first(where: {
            DemoSchoolLibraryProgress.reference(dependency, matches: $0.name)
        }) else { return }
        selectPrompt(prompt)
    }

    private func loadSelectedPromptDraft() {
        guard let selectedPrompt else {
            draftName = ""
            draftPrompt = ""
            draftMetadata = DemoSchoolMetadata()
            return
        }

        draftName = selectedPrompt.name
        draftPrompt = selectedPrompt.prompt
        draftMetadata = selectedPrompt.metadata
    }
}
