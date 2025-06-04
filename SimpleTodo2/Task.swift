//
//  Task.swift
//  SimpleTodo2
//
//  Created by Stephen Parker on 6/4/25.
//

import Foundation

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
}
