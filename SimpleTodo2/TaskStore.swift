//
//  TaskStore.swift
//  SimpleTodo2
//
//  Created by Stephen Parker on 6/4/25.
//

import SwiftUI
import Foundation

class TaskStore: ObservableObject {
    @Published var tasks: [Task] = [] {
        didSet { save() }
    }

    private let key = "tasks"

    init() {
        load()
    }

    func add(_ title: String) {
        let newTask = Task(title: title)
        withAnimation { tasks.append(newTask) }
    }

    func delete(at offsets: IndexSet) {
        withAnimation { tasks.remove(atOffsets: offsets) }
    }

    func toggle(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            withAnimation { tasks[index].isCompleted.toggle() }
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = saved
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
