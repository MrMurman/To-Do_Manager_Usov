//
//  TaskEditController.swift
//  To-Do_Manager_Usov
//
//  Created by Андрей Бородкин on 14.07.2021.
//

import UIKit

class TaskEditController: UITableViewController {

    @IBOutlet var taskTitle: UITextField!
    @IBOutlet var taskTypeLabel: UILabel!
    @IBOutlet var taskStatusSwitch: UISwitch!
    
    
    // task parameters
    var taskText: String = ""
    var taskType: TaskPriority = .normal
    var taskStatus: TaskStatus = .planned
    
    // task types naming
    private var taskTitles: [TaskPriority:String] = [
        .important: "Important",
        .normal: "On-going"
    ]

    var doAfterEdit: ((String, TaskPriority, TaskStatus) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // update text field with task name
        taskTitle?.text = taskText
        
        //update labels matching current type
        taskTypeLabel?.text = taskTitles[taskType]
        
        // update task Status
        if taskStatus == .completed {
            taskStatusSwitch.isOn = true
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTaskTypeScreen" {
            // link to destination controller
            let destination = segue.destination as! TaskTypeController
            
            // transfer of selected type
            destination.selectedType = taskType
            
            // transfer of type choosing handler
            destination.doAfterTypeSelected = {[unowned self] selectedType in
                taskType = selectedType
                // update label with current type
                taskTypeLabel?.text = taskTitles[taskType]
            }
        }
    }
   
    
    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        // get actual info
        let title = taskTitle?.text ?? ""
        let type = taskType
        let status: TaskStatus = taskStatusSwitch.isOn ? .completed : .planned
        
        // call handler
        doAfterEdit?(title, type, status)
        
        // return to previous screen
        navigationController?.popViewController(animated: true)
    }
    
}
