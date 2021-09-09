//
//  TaskTypeController.swift
//  To-Do Manager
//
//  Created by Данил Гусев on 29.08.2021.
//

import UIKit

class TaskTypeController: UITableViewController {
    
    var doAfterTypeSelected: ((TaskPriority) -> Void)?

    typealias TypeCellDescription = (type: TaskPriority, title: String, description: String)
    private var taskTypesInformation: [TypeCellDescription] = [
    (type: .important, title: "Важная", description: "Такой тип задач является наиболее приоритетным для выполнения. Все важные задачи выводятся в самом верху списка задач"),
    (type: .normal, title: "Текущая", description: "Задача с обычным приоритетом")
    ]
    
    var selectedType: TaskPriority = .normal
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellTypeNib = UINib(nibName: "TaskTypeCell", bundle: nil)
        tableView.register(cellTypeNib, forCellReuseIdentifier: "TaskTypeCell" )
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // 1. получение переиспользуемой кастомной ячейки по ее идентификатору
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTypeCell", for: indexPath) as! TaskTypeCell
    // 2. получаем текущий элемент, информация о котором должна быть выве- дена в строке
        let typeDescription = taskTypesInformation[indexPath.row]
    // 3. заполняем ячейку данными
        cell.typeTitle.text = typeDescription.title
        cell.typeDescription.text = typeDescription.description
    // 4. если тип является выбранным, то отмечаем галочкой
        if selectedType == typeDescription.type {
            cell.accessoryType = .checkmark // в ином случае снимаем отметку
            }
        else {
            cell.accessoryType = .none
            
        }
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // получаем выбранный тип
        let selectedType = taskTypesInformation[indexPath.row].type // вызов обработчика
        doAfterTypeSelected?(selectedType)
    // переход к предыдущему экрану
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return taskTypesInformation.count
    }

 
}
