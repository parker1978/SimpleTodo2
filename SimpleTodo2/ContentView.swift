//
//  ContentView.swift
//  SimpleTodo2
//
//  Created by Stephen Parker on 6/4/25.
//

import SwiftUI
import SwiftData
import UIKit

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query private var tasks: [Task]
    @State private var newTaskTitle: NSAttributedString = NSAttributedString(string: "")
    @State private var selectedRange = NSRange(location: 0, length: 0)
    @FocusState private var isInputActive: Bool

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    RichTextEditor(text: $newTaskTitle, selectedRange: $selectedRange, isFocused: $isInputActive)
                        .frame(height: 36)
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary)
                        )
                    Button(action: addTask) {
                        Image(systemName: "plus")
                    }
                    .disabled(newTaskTitle.string.isEmpty)
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
                    Button(action: applyBold) {
                        Image(systemName: "bold")
                    }
                    Button(action: applyItalic) {
                        Image(systemName: "italic")
                    }
                    Button(action: applyUnderline) {
                        Image(systemName: "underline")
                    }
                    Button(action: applyStrikethrough) {
                        Image(systemName: "strikethrough")
                    }
                    Spacer()
                    Button("Dismiss") { isInputActive = false }
                }
            }
        }
    }

    private func addTask() {
        guard !newTaskTitle.string.isEmpty else { return }
        let markdown = (try? AttributedString(newTaskTitle).markdown) ?? newTaskTitle.string
        let newTask = Task(title: markdown)
        context.insert(newTask)
        newTaskTitle = NSAttributedString(string: "")
    }

    private func delete(_ offsets: IndexSet) {
        for index in offsets {
            let task = tasks[index]
            context.delete(task)
        }
    }

    private func toggle(_ task: Task) {
        task.isCompleted.toggle()
    }

    private func selectedOrAllRange() -> NSRange {
        if selectedRange.length > 0 { return selectedRange }
        return NSRange(location: 0, length: newTaskTitle.length)
    }

    private func toggleFontTrait(_ trait: UIFontDescriptor.SymbolicTraits) {
        let range = selectedOrAllRange()
        let mutable = NSMutableAttributedString(attributedString: newTaskTitle)
        var shouldAdd = true
        mutable.enumerateAttribute(.font, in: range) { value, _, stop in
            if let font = value as? UIFont,
               font.fontDescriptor.symbolicTraits.contains(trait) {
                shouldAdd = false
                stop.pointee = true
            }
        }
        mutable.enumerateAttribute(.font, in: range) { value, subRange, _ in
            let base = (value as? UIFont) ?? UIFont.preferredFont(forTextStyle: .body)
            var traits = base.fontDescriptor.symbolicTraits
            if shouldAdd {
                traits.insert(trait)
            } else {
                traits.remove(trait)
            }
            if let descriptor = base.fontDescriptor.withSymbolicTraits(traits) {
                let newFont = UIFont(descriptor: descriptor, size: base.pointSize)
                mutable.addAttribute(.font, value: newFont, range: subRange)
            }
        }
        newTaskTitle = mutable
    }

    private func applyUnderlineStyle(_ style: NSUnderlineStyle, key: NSAttributedString.Key) {
        let range = selectedOrAllRange()
        let mutable = NSMutableAttributedString(attributedString: newTaskTitle)
        var shouldAdd = true
        mutable.enumerateAttribute(key, in: range) { value, _, stop in
            if let raw = value as? Int, raw != 0 {
                shouldAdd = false
                stop.pointee = true
            }
        }
        if shouldAdd {
            mutable.addAttribute(key, value: style.rawValue, range: range)
        } else {
            mutable.removeAttribute(key, range: range)
        }
        newTaskTitle = mutable
    }

    private func applyBold() { toggleFontTrait(.traitBold) }
    private func applyItalic() { toggleFontTrait(.traitItalic) }
    private func applyUnderline() { applyUnderlineStyle(.single, key: .underlineStyle) }
    private func applyStrikethrough() { applyUnderlineStyle(.single, key: .strikethroughStyle) }
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
        if let attributed = try? AttributedString(
            markdown: text,
            options: .init(interpretedSyntax: .full)
        ) {
            return Text(attributed)
        } else {
            return Text(text)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Task.self, inMemory: true)
}
