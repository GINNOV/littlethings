import AppKit
import SwiftUI

struct ExampleLibraryView: View {
    @StateObject private var store = ExampleLibraryStore.shared
    @State private var searchText = ""
    @State private var selectedExampleID: ExampleLibraryItem.ID?
    @State private var draftName = ""
    @State private var draftLanguage: ExampleLanguage = .assembly
    @State private var draftCode = ""
    @State private var copiedExampleID: ExampleLibraryItem.ID?

    private var filteredExamples: [ExampleLibraryItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return store.examples }

        return store.examples.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }

    private var selectedExample: ExampleLibraryItem? {
        store.example(withID: selectedExampleID)
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                List(selection: $selectedExampleID) {
                    ForEach(filteredExamples) { item in
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(item.name.isEmpty ? "Untitled Example" : item.name)
                                    .lineLimit(1)

                                Text(item.language.rawValue)
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }

                            Text(item.code)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        .tag(item.id)
                    }
                }
                .listStyle(.sidebar)
                .searchable(text: $searchText, placement: .sidebar, prompt: "Search by name")
                .accessibilityIdentifier("exampleLibraryList")

                Divider()

                HStack {
                    Button {
                        addExample()
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                    .accessibilityIdentifier("addExampleButton")

                    Spacer()
                }
                .padding(10)
            }
            .navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 360)
        } detail: {
            if selectedExample == nil {
                ContentUnavailableView("No Example Selected", systemImage: "books.vertical")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                exampleEditor
                    .padding(16)
            }
        }
        .frame(minWidth: 820, minHeight: 520)
        .onAppear {
            selectInitialExampleIfNeeded()
        }
        .onChange(of: selectedExampleID) {
            loadSelectedExampleDraft()
        }
    }

    private var exampleEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                TextField("Example name", text: $draftName)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(saveDraft)
                    .accessibilityIdentifier("exampleNameField")

                Picker("Language", selection: $draftLanguage) {
                    ForEach(ExampleLanguage.allCases) { language in
                        Text(language.rawValue).tag(language)
                    }
                }
                .labelsHidden()
                .frame(width: 120)
                .accessibilityIdentifier("exampleLanguagePicker")

                Button {
                    saveDraft()
                } label: {
                    Label("Save", systemImage: "checkmark")
                }
                .disabled(!canSaveDraft)
                .accessibilityIdentifier("saveExampleButton")

                Button(role: .destructive) {
                    deleteSelectedExample()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .accessibilityIdentifier("deleteExampleButton")
            }

            TextEditor(text: $draftCode)
                .font(.body.monospaced())
                .frame(minHeight: 300)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                )
                .accessibilityIdentifier("exampleCodeEditor")

            HStack(spacing: 10) {
                Button {
                    copySelectedExample()
                } label: {
                    Label(copiedExampleID == selectedExampleID ? "Copied" : "Copy", systemImage: copiedExampleID == selectedExampleID ? "checkmark" : "doc.on.doc")
                }
                .disabled(draftCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("copyExampleLibraryCodeButton")

                Button {
                    loadSelectedExampleIntoEditor()
                } label: {
                    Label("Paste to Editor", systemImage: "arrow.down.doc")
                }
                .disabled(draftCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("loadExampleIntoEditorButton")

                Spacer()

                if let selectedExample {
                    Text("Updated \(selectedExample.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var canSaveDraft: Bool {
        !draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !draftCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func addExample() {
        let item = store.createExample()
        selectedExampleID = item.id
        loadSelectedExampleDraft()
    }

    private func saveDraft() {
        guard let selectedExampleID, canSaveDraft else { return }
        store.updateExample(
            id: selectedExampleID,
            name: draftName.isEmpty ? "Untitled Example" : draftName,
            language: draftLanguage,
            code: draftCode
        )
    }

    private func deleteSelectedExample() {
        guard let selectedExampleID else { return }
        store.deleteExample(id: selectedExampleID)
        self.selectedExampleID = filteredExamples.first?.id
        loadSelectedExampleDraft()
    }

    private func copySelectedExample() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(draftCode, forType: .string)
        copiedExampleID = selectedExampleID

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if copiedExampleID == selectedExampleID {
                copiedExampleID = nil
            }
        }
    }

    private func loadSelectedExampleIntoEditor() {
        saveDraft()
        NotificationCenter.default.post(
            name: .loadExampleIntoEditor,
            object: nil,
            userInfo: [
                "name": draftName,
                "code": draftCode
            ]
        )
    }

    private func selectInitialExampleIfNeeded() {
        if selectedExampleID == nil {
            selectedExampleID = filteredExamples.first?.id
        }
        loadSelectedExampleDraft()
    }

    private func loadSelectedExampleDraft() {
        guard let selectedExample else {
            draftName = ""
            draftLanguage = .assembly
            draftCode = ""
            return
        }

        draftName = selectedExample.name
        draftLanguage = selectedExample.language
        draftCode = selectedExample.code
    }
}
