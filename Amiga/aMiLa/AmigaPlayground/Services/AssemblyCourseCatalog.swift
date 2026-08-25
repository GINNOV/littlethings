import Foundation

struct AssemblyCourse: Codable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let lessons: [AssemblyLesson]
}

struct AssemblyLesson: Codable, Equatable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let tag: String
    let goal: String
    let emulatorPresetID: String?
    let emulatorPresetName: String?
    let theory: [String]
    let analogy: String
    let keyIdea: String
    let starterCode: String
    let quiz: AssemblyQuiz
}

struct AssemblyQuiz: Codable, Equatable {
    let question: String
    let options: [String]
    let answer: Int
    let feedback: String
}

struct AssemblyLessonLoadState: Equatable {
    let codeText: String
    let selectedTutorialID: String
    let emulatorPresetID: String?

    init(codeText: String, selectedTutorialID: String, emulatorPresetID: String? = nil) {
        self.codeText = codeText
        self.selectedTutorialID = selectedTutorialID
        self.emulatorPresetID = emulatorPresetID
    }
}

enum AssemblyLessonLoader {
    static func load(_ lesson: AssemblyLesson) -> AssemblyLessonLoadState {
        AssemblyLessonLoadState(
            codeText: lesson.starterCode,
            selectedTutorialID: "",
            emulatorPresetID: lesson.emulatorPresetID
        )
    }
}

enum AssemblyCourseCatalog {
    static func parse(_ data: Data) throws -> AssemblyCourse {
        try JSONDecoder().decode(AssemblyCourse.self, from: data)
    }

    static func bundledCourse(bundle: Bundle = .main) -> AssemblyCourse? {
        guard let url = bundle.url(
            forResource: "course",
            withExtension: "json",
            subdirectory: "tutorials"
        ), let data = try? Data(contentsOf: url) else {
            return nil
        }

        return try? parse(data)
    }
}
