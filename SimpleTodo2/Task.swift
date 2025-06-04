//
//  Task.swift
//  SimpleTodo2
//
//  Created by Stephen Parker on 6/4/25.
//

import Foundation
import SwiftData
@Model
final class Task {
    var title: String
    var isCompleted: Bool

    init(title: String, isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
    }
}
