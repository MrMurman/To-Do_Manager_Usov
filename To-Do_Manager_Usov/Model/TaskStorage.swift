//
//  TaskStorage.swift
//  To-Do_Manager_Usov
//
//  Created by Андрей Бородкин on 09.07.2021.
//

import Foundation
import UIKit

protocol TasksStorageProtocol {
    func loadTasks() -> [TaskProtocol]
    func saveTasks(_ tasks: [TaskProtocol])
}

class TasksStorage: TasksStorageProtocol {

    // link to the storage
    private var storage = UserDefaults.standard
    // key that will save and load data from User defaults
    var storageKey: String = "tasks"
    
    // enumeration with keys to save data in User defaults
    private enum TaskKey: String {
        case title
        case type
        case status
    }

func loadTasks() -> [TaskProtocol] {
    var resultTasks: [TaskProtocol] = []
    let tasksFromStorage = storage.array(forKey: storageKey) as? [[String:String]] ?? []
    for task in tasksFromStorage {
        guard let title = task[TaskKey.title.rawValue],
              let typeRaw = task[TaskKey.type.rawValue],
              let statusRaw = task[TaskKey.status.rawValue] else {continue}
        
        let type: TaskPriority = typeRaw == "important" ? .important : .normal
        let status: TaskStatus = statusRaw == "planned" ? .planned : .completed
        
        resultTasks.append(Task(title: title, type: type, status: status))
    }
    
    
    
    
    // temporary realisation that returns an array of test tasks
//        let testTasks: [TaskProtocol] = [
//            Task(title: "Buy bread", type: .normal, status: .planned),
//            Task(title: "Wash neko", type: .important, status: .planned),
//            Task(title: "Return debt to Arnold", type: .important, status: .completed),
//            Task(title: "Buy a new vacuum cleaner", type: .normal, status: .completed),
//            Task(title: "Buy flowers for wife", type: .important, status: .planned),
//            Task(title: "Call parents", type: .important, status: .planned),
//            Task(title: "Invite Dolf, Jackie, Leonardo, Will and Bruce to a party", type: .important, status: .planned)
//        ]
        //return testTasks
    return resultTasks
    }
    
    func saveTasks(_ tasks: [TaskProtocol]) {
       
        var arrayForStorage: [[String:String]] = []
        tasks.forEach { task in
            var newElementForStorage: Dictionary<String, String> = [:]
            newElementForStorage[TaskKey.title.rawValue] = task.title
            newElementForStorage[TaskKey.type.rawValue] = (task.type == .important) ? "important" : "normal"
            newElementForStorage[TaskKey.status.rawValue] = (task.status == .planned) ? "planned" : "completed"
            arrayForStorage.append(newElementForStorage)
        }
        storage.set(arrayForStorage, forKey: storageKey)
    }
}
