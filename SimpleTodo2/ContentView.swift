//
//  ContentView.swift
//  SimpleTodo2
//
//  Created by Stephen Parker on 6/4/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query private var tasks: [Task]
    @State private var newTaskTitle = ""
    @FocusState private var isInputActive: Bool

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("New Task", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isInputActive)
                    Button(action: addTask) {
                        Image(systemName: "plus")
                    }
                    .disabled(newTaskTitle.isEmpty)
                }
                .padding()

                List {
                    ForEach(tasks) { task in
                        TaskRow(task: task, toggle: { toggle(task) })
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Todos")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button(action: { toggleWrap(prefix: "**", suffix: "**") }) {
                        Image(systemName: "bold")
                    }
                    Button(action: { toggleWrap(prefix: "*", suffix: "*") }) {
                        Image(systemName: "italic")
                    }
                    Button(action: { toggleWrap(prefix: "<u>", suffix: "</u>") }) {
                        Image(systemName: "underline")
                    }
                    Button(action: { toggleWrap(prefix: "~~", suffix: "~~") }) {
                        Image(systemName: "strikethrough")
                    }
                    Spacer()
                    Button("Dismiss") { isInputActive = false }
                }
            }
        }
    }

    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        let newTask = Task(title: newTaskTitle)
        context.insert(newTask)
        newTaskTitle = ""
    }

    private func delete(_ offsets: IndexSet) {
        for index in offsets {
            let task = tasks[index]
            context.delete(task)
        }
    }

    private func toggleWrap(prefix: String, suffix: String) {
        if newTaskTitle.hasPrefix(prefix) && newTaskTitle.hasSuffix(suffix) {
            newTaskTitle = String(newTaskTitle.dropFirst(prefix.count).dropLast(suffix.count))
        } else {
            newTaskTitle = prefix + newTaskTitle + suffix
        }
    }

    private func toggle(_ task: Task) {
        task.isCompleted.toggle()
    }
}

struct TaskRow: View {
    var task: Task
    var toggle: () -> Void

    var body: some View {
        HStack {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .onTapGesture(perform: toggle)
            formattedText(for: task.title)
                .strikethrough(task.isCompleted)
                .foregroundColor(task.isCompleted ? .gray : .primary)
        }
    }

    private func formattedText(for text: String) -> Text {
        var content = text
        var modifiers: [(Text) -> Text] = []
        if content.hasPrefix("**") && content.hasSuffix("**") {
            content = String(content.dropFirst(2).dropLast(2))
            modifiers.append { $0.bold() }
        }
        if content.hasPrefix("*") && content.hasSuffix("*") {
            content = String(content.dropFirst().dropLast())
            modifiers.append { $0.italic() }
        }
        if content.hasPrefix("<u>") && content.hasSuffix("</u>") {
            content = String(content.dropFirst(3).dropLast(4))
            modifiers.append { $0.underline() }
        }
        if content.hasPrefix("~~") && content.hasSuffix("~~") {
            content = String(content.dropFirst(2).dropLast(2))
            modifiers.append { $0.strikethrough() }
        }
        var result = Text(content)
        for modifier in modifiers { result = modifier(result) }
        return result
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Task.self, inMemory: true)
}
