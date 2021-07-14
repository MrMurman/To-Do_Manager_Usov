//
//  TaskTypeController.swift
//  To-Do_Manager_Usov
//
//  Created by Андрей Бородкин on 14.07.2021.
//

import UIKit

class TaskTypeController: UITableViewController {

    // 1. tuple that describes task type
    typealias TypeCellDescription = (type: TaskPriority, title: String, description: String)
    
    //2. collection of available task types along with their description
    private var taskTypesInformation: [TypeCellDescription] = [
        (type: .important, title: "Important", description: "This type of task has a higher priority of completion. All important tasks are shown at the top of task list."),
        (type: .normal, title: "On-going", description: "A task with standard priority of completion.")
    ]
    
    //3. the chosen priority
    var selectedType: TaskPriority = .normal
    
    var doAfterTypeSelected: ((TaskPriority) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. get a value of type UINib, that corresponds to xib-file created earlier
        let cellTypeNib = UINib(nibName: "TaskTypeCell", bundle: nil)
        
        // 2. register a custom cell in the table view
        tableView.register(cellTypeNib, forCellReuseIdentifier: "TaskTypeCell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskTypesInformation.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 1. get reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTypeCell", for: indexPath) as! TaskTypeCell
        
        // 2. get current element, which info should be shown in the row
        let typeDescription = taskTypesInformation[indexPath.row]
        
        // 3. supply cell with info
        cell.typeTitle.text = typeDescription.title
        cell.typeDescription.text = typeDescription.description
        
        // 4. if selected type is chosen, mark it with a check mark
        if selectedType == typeDescription.type {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get selected type
        let selectedType = taskTypesInformation[indexPath.row].type
        
        // handler call
        doAfterTypeSelected?(selectedType)
        
        // transition to the previous screen
        navigationController?.popViewController(animated: true)
    }
}
