//
//  TaskListController.swift
//  To-Do_Manager_Usov
//
//  Created by Андрей Бородкин on 09.07.2021.
//

import UIKit

class TaskListController: UITableViewController {

    var tasksStorage: TasksStorageProtocol = TasksStorage()
    var tasks: [TaskPriority : [TaskProtocol]] = [:]
    
    // order of section presentation by type
    // array index corresponds to table section index
    var sectionsTypesPosition: [TaskPriority] = [.important, .normal]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTasks()

    }

    private func loadTasks() {
        // preparation of tasks in a collection
        // we will use only those tasks with the position defined in the tableView
        sectionsTypesPosition.forEach { taskType in
            tasks[taskType] = []
        }
        
        // loading and segregation of tasks from storage
        tasksStorage.loadTasks().forEach { task in
            tasks[task.type]?.append(task)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?
        let taskType = sectionsTypesPosition[section]
        if taskType == .important {
            title = "Important"
        } else if taskType == .normal {
            title = "Ongoing"
        }
        return title
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // we specify priority of the task that corresponds to current section
        let taskType = sectionsTypesPosition[section]
        guard let currentTaskType = tasks[taskType] else {return 0}
        
        return currentTaskType.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getConfiguredTaskCell_constraints(for: indexPath)
    }
    
    // cell based on constraints
    private func getConfiguredTaskCell_constraints(for indexPath: IndexPath) -> UITableViewCell {
        // load cell prototype based in identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellConstraints", for: indexPath)
        
        // get info on the task to be presented in the cell
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {return cell}
        
        // text label of the symbol
        let symbolLabel = cell.viewWithTag(1) as? UILabel
        // text label with task description
        let textLabel = cell.viewWithTag(2) as? UILabel
        
        // change symbol in the cell
        symbolLabel?.text = getSymbolForTask(with: currentTask.status)
        // change text in the cell
        textLabel?.text = currentTask.title
        
        // change color of text and symbol
        if currentTask.status == .planned {
            textLabel?.textColor = .black
            symbolLabel?.textColor = .black
        } else {
            textLabel?.textColor = .lightGray
            symbolLabel?.textColor = .lightGray
        }
        return cell
    }
    
    private func getSymbolForTask(with status: TaskStatus) -> String {
        var resultSymbol: String
        if status == .planned {
            resultSymbol = "\u{25CB}"
        } else if status == .completed {
            resultSymbol = "\u{25C9}"
        } else {
            resultSymbol = ""
        }
        return resultSymbol
    }
    
}
