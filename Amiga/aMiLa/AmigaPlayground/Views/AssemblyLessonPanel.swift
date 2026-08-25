import SwiftUI

struct AssemblyLessonPanel: View {
    let course: AssemblyCourse
    @Binding var selectedLessonID: String
    let completedLessonIDs: Set<String>
    let onLoadCode: (AssemblyLesson) -> Void
    let onAssemble: () -> Void
    let onRun: (AssemblyLesson) -> Void
    let onComplete: (String) -> Void

    @State private var selectedQuizAnswer: Int?

    private var selectedLesson: AssemblyLesson? {
        course.lessons.first { $0.id == selectedLessonID } ?? course.lessons.first
    }

    private var completedCount: Int {
        course.lessons.filter { completedLessonIDs.contains($0.id) }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            panelHeader

            if let selectedLesson {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        lessonHeading(for: selectedLesson)
                        lessonContent(for: selectedLesson)
                        lessonActions(for: selectedLesson)
                        quiz(for: selectedLesson)
                    }
                    .padding(16)
                }
            } else {
                ContentUnavailableView("No Lesson Available", systemImage: "book.closed")
            }
        }
        .frame(minWidth: 320, idealWidth: 370, maxWidth: 460)
        .background(Color(nsColor: .controlBackgroundColor))
        .onChange(of: selectedLessonID) {
            selectedQuizAnswer = nil
        }
    }

    private var panelHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Assembly School", systemImage: "graduationcap.fill")
                    .font(.headline)
                    .foregroundStyle(.cyan)

                Spacer()

                Text("\(completedCount)/\(course.lessons.count)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Picker("Lesson", selection: $selectedLessonID) {
                ForEach(course.lessons) { lesson in
                    Text(lesson.title).tag(lesson.id)
                }
            }
            .labelsHidden()

            ProgressView(value: Double(completedCount), total: Double(max(course.lessons.count, 1)))
                .tint(.cyan)
        }
        .padding(16)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func lessonHeading(for lesson: AssemblyLesson) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(lesson.tag.uppercased())
                    .font(.caption.bold())
                    .foregroundStyle(.purple)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.purple.opacity(0.16))
                    .clipShape(Capsule())

                if completedLessonIDs.contains(lesson.id) {
                    Label("Complete", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            Text(lesson.title)
                .font(.title3.bold())

            Text(lesson.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Label(lesson.goal, systemImage: "target")
                .font(.subheadline)
                .foregroundStyle(.primary)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.yellow.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private func lessonContent(for lesson: AssemblyLesson) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(lesson.theory, id: \.self) { paragraph in
                Text(paragraph)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }

            lessonCallout(title: "Swift analogy", text: lesson.analogy, color: .yellow)
            lessonCallout(title: "Key idea", text: lesson.keyIdea, color: .cyan)
        }
    }

    private func lessonCallout(title: String, text: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(color)
            Text(text)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.10))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(color)
                .frame(width: 3)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func lessonActions(for lesson: AssemblyLesson) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Try it in the editor")
                .font(.headline)

            Text("Load the starter code, make the requested change, then assemble or run it in the selected emulator.")
                .font(.callout)
                .foregroundStyle(.secondary)

            if let emulatorPresetName = lesson.emulatorPresetName ?? lesson.emulatorPresetID {
                Label("Loading this lesson selects the \(emulatorPresetName) profile.", systemImage: "cpu")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                Button("Load", systemImage: "arrow.down.doc") {
                    onLoadCode(lesson)
                }
                .buttonStyle(.borderedProminent)

                Button("Assemble", systemImage: "hammer.fill", action: onAssemble)
                    .buttonStyle(.bordered)

                Button("Run", systemImage: "play.fill") {
                    onRun(lesson)
                }
                    .buttonStyle(.bordered)
            }
            .controlSize(.small)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func quiz(for lesson: AssemblyLesson) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Checkpoint", systemImage: "checkmark.seal")
                .font(.headline)
                .foregroundStyle(.yellow)

            Text(lesson.quiz.question)
                .font(.body.bold())

            ForEach(Array(lesson.quiz.options.enumerated()), id: \.offset) { index, option in
                Button {
                    selectedQuizAnswer = index
                } label: {
                    HStack {
                        Text(option)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        if selectedQuizAnswer == index {
                            Image(systemName: index == lesson.quiz.answer ? "checkmark.circle.fill" : "xmark.circle.fill")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)
                .tint(selectedQuizAnswer == index ? (index == lesson.quiz.answer ? .green : .red) : .secondary)
            }

            if selectedQuizAnswer != nil {
                Text(selectedQuizAnswer == lesson.quiz.answer ? lesson.quiz.feedback : "Not quite. Re-read the lesson and try again.")
                    .font(.callout)
                    .foregroundStyle(selectedQuizAnswer == lesson.quiz.answer ? .green : .red)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button("Mark lesson complete", systemImage: "checkmark") {
                onComplete(lesson.id)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .disabled(selectedQuizAnswer != lesson.quiz.answer && !completedLessonIDs.contains(lesson.id))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
