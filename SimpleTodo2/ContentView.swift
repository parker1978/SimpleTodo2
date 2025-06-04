//
//  ContentView.swift
//  SimpleTodo2
//
//  Created by Stephen Parker on 6/4/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = TaskStore()
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
                    ForEach(store.tasks) { task in
                        TaskRow(task: task, toggle: { store.toggle(task) })
                    }
                    .onDelete(perform: store.delete)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Todos")
        }
    }

    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        store.add(newTaskTitle)
        newTaskTitle = ""
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
}
