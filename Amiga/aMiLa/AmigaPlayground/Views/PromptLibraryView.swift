import AppKit
import SwiftUI

struct PromptLibraryView: View {
    @StateObject private var store = PromptLibraryStore.shared
    @State private var searchText = ""
    @State private var selectedPromptID: PromptLibraryItem.ID?
    @State private var draftName = ""
    @State private var draftPrompt = ""
    @State private var copiedPromptID: PromptLibraryItem.ID?

    private var filteredPrompts: [PromptLibraryItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return store.prompts }

        return store.prompts.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }

    private var selectedPrompt: PromptLibraryItem? {
        store.prompt(withID: selectedPromptID)
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                List(selection: $selectedPromptID) {
                    ForEach(filteredPrompts) { item in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name.isEmpty ? "Untitled Prompt" : item.name)
                                .lineLimit(1)

                            Text(item.prompt)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        .tag(item.id)
                    }
                }
                .listStyle(.sidebar)
                .searchable(text: $searchText, placement: .sidebar, prompt: "Search by name")
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
                promptEditor
                    .padding(16)
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
            HStack(spacing: 10) {
                TextField("Prompt name", text: $draftName)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(saveDraft)
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

            TextEditor(text: $draftPrompt)
                .font(.body.monospaced())
                .frame(minHeight: 260)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                )
                .accessibilityIdentifier("promptBodyEditor")

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
                }
            }
        }
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
            prompt: draftPrompt
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

    private func loadSelectedPromptDraft() {
        guard let selectedPrompt else {
            draftName = ""
            draftPrompt = ""
            return
        }

        draftName = selectedPrompt.name
        draftPrompt = selectedPrompt.prompt
    }
}
