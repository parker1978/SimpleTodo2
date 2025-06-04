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

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("New Task", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
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
            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundColor(task.isCompleted ? .gray : .primary)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Task.self, inMemory: true)
}
