//
//  TaskListController.swift
//  To-Do_Manager_Usov
//
//  Created by Андрей Бородкин on 09.07.2021.
//

import UIKit

class TaskListController: UITableViewController {

    var tasksStorage: TasksStorageProtocol = TasksStorage()
    var tasks: [TaskPriority : [TaskProtocol]] = [:] {
        didSet {
            for (taskGroupPriority, taskGroup) in tasks {
                tasks[taskGroupPriority] = taskGroup.sorted { task1, task2 in
                    let task1position = tasksStatusPosition.firstIndex(of: task1.status) ?? 0
                    let task2position = tasksStatusPosition.firstIndex(of: task2.status) ?? 0
                    return task1position < task2position
                }
            }
            
            // task saving
            var savingArray: [TaskProtocol] = []
            tasks.forEach {_, value in
                savingArray += value
            }
            tasksStorage.saveTasks(savingArray)
        }
    }
    
    // order of section presentation by type
    // array index corresponds to table section index
    var sectionsTypesPosition: [TaskPriority] = [.important, .normal]
    
    // sorting order based on task status
    var tasksStatusPosition: [TaskStatus] = [.planned, .completed]
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // loadTasks()

        navigationItem.leftBarButtonItem = editButtonItem
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
        
        // tasks sorting
//        for (taskGroupPriority, taskGroup) in tasks {
//            tasks[taskGroupPriority] = taskGroup.sorted {task1, task2 in
//                task1.status.rawValue < task2.status.rawValue
//            }
//        }
        
        
    }
    
    func setTasks(_ tasksCollection: [TaskProtocol]) {
        // preparation of collection with tasks
        // we will use only those tasks, which have defied section
        sectionsTypesPosition.forEach {taskType in
            tasks[taskType] = []
        }
        
        // loading and segregation of tasks from storage
        tasksCollection.forEach { task in
            tasks[task.type]?.append(task)
        }
    }
    
    //MARK: - Table view setup
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
        
        // cell based on constraints
        // return getConfiguredTaskCell_constraints(for: indexPath)
        
        //cell based on stack
        return getConfiguredTaskCell_stack(for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1. check whether a task exists
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {return}
        
        // 2. ensure that the task is not completed
        guard tasks[taskType]![indexPath.row].status == .planned else {
            // remove selection from row
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        // 3. mark selected task as completed
        tasks[taskType]![indexPath.row].status = .completed
        
        // 4. reload specific section in the table
        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // get info about the task needing to be planned
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {return nil}
        
//        // verify that the task has "completed" status
//        guard tasks[taskType]![indexPath.row].status == .completed else {return nil}
        
        // create an action to change status to "planned"
        let actionSwipeInstance = UIContextualAction(style: .normal, title: "Not completed") { _,_,_ in
            self.tasks[taskType]![indexPath.row].status = .planned
            self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        
        // create an action to make a transition to editing screen
        let actionEditInstance = UIContextualAction(style: .normal, title: "Edit") { _,_,_ in
            // scene loading from storyboard
            let editScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TaskEditController") as! TaskEditController
            
            // transfer data from edited task
            editScreen.taskText = self.tasks[taskType]![indexPath.row].title
            editScreen.taskType = self.tasks[taskType]![indexPath.row].type
            editScreen.taskStatus = self.tasks[taskType]![indexPath.row].status
            
            // transition of handler for task saving
            editScreen.doAfterEdit = {[unowned self] title, type, status in
                let editedTask = Task(title: title, type: type, status: status)
                tasks[taskType]![indexPath.row] = editedTask
                tableView.reloadData()
            }
            
            // transition to editing scene
            self.navigationController?.pushViewController(editScreen, animated: true)
            
        }
        
        // change background color of the action button
        actionEditInstance.backgroundColor = .darkGray
        
        // create an object that describes available actions
        // depending on the status of the task, there will be shown either 1 or 2 actions
        let actionsConfiguration: UISwipeActionsConfiguration
        if tasks[taskType]![indexPath.row].status == .completed {
            actionsConfiguration = UISwipeActionsConfiguration(actions: [actionSwipeInstance, actionEditInstance])
        } else {
            actionsConfiguration = UISwipeActionsConfiguration(actions: [actionEditInstance])
        }
        
        return actionsConfiguration
//        // return configured object
//        return UISwipeActionsConfiguration(actions: [actionSwipeInstance])
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let taskType = sectionsTypesPosition[indexPath.section]
        // delete the task
        tasks[taskType]?.remove(at: indexPath.row)
        
        // delete the row corresponding to the task
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // manual tasks sorting

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // section from which movement was initiated
        let taskTypeFrom = sectionsTypesPosition[sourceIndexPath.section]
        // section to which movement was initiated
        let taskTypeTo = sectionsTypesPosition[destinationIndexPath.section]
        
        // safe unwrapping of the task
        guard let movedTask = tasks[taskTypeFrom]?[sourceIndexPath.row] else {return}
        
        // delete task from original placement
        tasks[taskTypeFrom]!.remove(at: sourceIndexPath.row)
        // insert task to new destination
        tasks[taskTypeTo]!.insert(movedTask, at: destinationIndexPath.row)

        //if section has changed, change task type according to new placement
        if taskTypeFrom != taskTypeTo {
            tasks[taskTypeTo]![destinationIndexPath.row].type = taskTypeTo
        }
        
        // reload data
        tableView.reloadData()
    }
    
    
    //MARK: - Cell types
    // cell based on constraints
    private func getConfiguredTaskCell_constraints(for indexPath: IndexPath) -> UITableViewCell {
        // load cell prototype based on identifier
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
    
    // cell based on hStack
    private func getConfiguredTaskCell_stack(for indexPath: IndexPath) -> UITableViewCell {
        // load cell prototype based on identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellStack", for: indexPath) as! TaskCell
        
        // get info on the task to be presented in the cell
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else { return cell}
        
        // change text in cell
        cell.title.text = currentTask.title
        // change symbol in cell
        cell.symbol.text = getSymbolForTask(with: currentTask.status)
        
        //change text color
        if currentTask.status == .planned {
            cell.title.textColor = .black
            cell.symbol.textColor = .black
        } else if currentTask.status == .completed {
            cell.title.textColor = .lightGray
            cell.symbol.textColor = .lightGray
        }
        
        return cell
        
    }
    
    // MARK: -Segue managing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateScreen" {
            let destination = segue.destination as! TaskEditController
            destination.doAfterEdit = {[unowned self] title, type, status in
                let newTask = Task(title: title, type: type, status: status)
                tasks[type]?.append(newTask)
                tableView.reloadData()
            }
        }
    }
    
}
