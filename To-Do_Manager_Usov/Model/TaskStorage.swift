//
//  TaskStorage.swift
//  To-Do_Manager_Usov
//
//  Created by Андрей Бородкин on 09.07.2021.
//

import Foundation

protocol TasksStorageProtocol {
    func loadTasks() -> [TaskProtocol]
    func saveTasks(_ tasks: [TaskProtocol])
}

class TasksStorage: TasksStorageProtocol {
    func loadTasks() -> [TaskProtocol] {
        // temporary realisation that returns an array of test tasks
        let testTasks: [TaskProtocol] = [
            Task(title: "Buy bread", type: .normal, status: .planned),
            Task(title: "Wash neko", type: .important, status: .planned),
            Task(title: "Return debt to Arnold", type: .important, status: .completed),
            Task(title: "Buy a new vacuum cleaner", type: .normal, status: .completed),
            Task(title: "Buy flowers for wife", type: .important, status: .planned),
            Task(title: "Call parents", type: .important, status: .planned)
        ]
        return testTasks
    }
    
    func saveTasks(_ tasks: [TaskProtocol]) {
        <#code#>
    }
}
