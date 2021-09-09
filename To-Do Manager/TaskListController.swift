//
//  Task TaskListController.swift
//  To-Do Manager
//
//  Created by Данил Гусев on 28.08.2021.
//

import UIKit

class TaskListController: UITableViewController {

    
    var tasksStorage: TasksStorageProtocol = TasksStorage() // коллекция задач
    var tasks: [TaskPriority:[TaskProtocol]] = [:] {
        didSet {
            for (tasksGroupPriority, tasksGroup) in tasks {
                tasks[tasksGroupPriority] = tasksGroup.sorted{ task1, task2 in
                    let task1position = tasksStatusPosition.firstIndex(of: task1.status) ?? 0
                    let task2position = tasksStatusPosition.firstIndex(of: task2.status) ?? 0
                    return task1position < task2position }
                var savingArray: [TaskProtocol] = []
                tasks.forEach { _, value in
                    savingArray += value
                }
                tasksStorage.saveTasks(savingArray)
            }
        }
    }
   
    var tasksStatusPosition: [TaskStatus] = [.planned, .completed]
    var sectionsTypesPosition: [TaskPriority] = [.important, .normal]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTask()
        navigationItem.leftBarButtonItem = editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let taskType = sectionsTypesPosition[section]
        guard let currentTasksType = tasks[taskType] else {
            return 0
        }
        return currentTasksType.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return getConfiguredTaskCell_constraints(for: indexPath)
        return getConfiguredTaskCell_stack(for: indexPath)
    }
    // MARK: - Controller
    private func getConfiguredTaskCell_constraints(for indexPath: IndexPath) -> UITableViewCell {
    // загружаем прототип ячейки по идентификатору
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellConstraints", for: indexPath)
    // получаем данные о задаче, которую необходимо вывести в ячейке
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
    // текстовая метка символа
        let symbolLabel = cell.viewWithTag(1) as? UILabel // текстовая метка названия задачи
        let textLabel = cell.viewWithTag(2) as? UILabel
    // изменяем символ в ячейке
        symbolLabel?.text = getSymbolForTask(with: currentTask.status) // изменяем текст в ячейке
        textLabel?.text = currentTask.title
    // изменяем цвет текста и символа
        if currentTask.status == .planned {
            textLabel?.textColor = .black
            symbolLabel?.textColor = .black } else {
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
    
    
    private func loadTask() {
        sectionsTypesPosition.forEach { taskType in
            tasks[taskType] = []
        }
        // загрузка и разбор задач из хранилища
        tasksStorage.loadTasks().forEach { task in
            tasks[task.type]?.append(task)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?
        let tasksType = sectionsTypesPosition[section]
        if tasksType == .important {
            title = "Важные"
        }
        else if tasksType == .normal {
            title = "Текущие"
        }
        
    return title
    
    }
    
    // ячейка на основе стека
    private func getConfiguredTaskCell_stack(for indexPath: IndexPath) -> UITableViewCell {
    // загружаем прототип ячейки по идентификатору
    let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellStack", for: indexPath) as! TaskCell
    // получаем данные о задаче, которые необходимо вывести в ячейке
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row]
        else {
            return cell
        }
    // изменяем текст в ячейке
        cell.title.text = currentTask.title
    // изменяем символ в ячейке
        cell.symbol.text = getSymbolForTask(with: currentTask.status)
    // изменяем цвет текста
        if currentTask.status == .planned {
            cell.title.textColor = .black
            cell.symbol.textColor = .black }
        else {
            cell.title.textColor = .lightGray
            cell.symbol.textColor = .lightGray
        }
    return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // 1. Проверяем существование задачи
    let taskType = sectionsTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return
        }
    // 2. Убеждаемся, что задача не является выполненной
    guard tasks[taskType]![indexPath.row].status == .planned else {
    // снимаем выделение со строки
        tableView.deselectRow(at: indexPath, animated: true)
        return
    }
    // 3. Отмечаем задачу как выполненную
        tasks[taskType]![indexPath.row].status = .completed
    // 4. Перезагружаем секцию таблицы
        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic) }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    // получаем данные о задаче, по которой осуществлен свайп
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return nil
        }
    // действие для изменения статуса на "запланирована"
        let actionSwipeInstance = UIContextualAction(style: .normal, title: "Не выполнена") { _,_,_ in
            self.tasks[taskType]![indexPath.row].status = .planned
            self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
    }
    // действие для перехода к экрану редактирования
        let actionEditInstance = UIContextualAction(style: .normal, title: "Изменить") { _,_,_ in
    // загрузка сцены со storyboard
            let editScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TaskEditController") as! TaskEditController
    // передача значений редактируемой задачи
            editScreen.taskText = self.tasks[taskType]![indexPath.row].title
            editScreen.taskType = self.tasks[taskType]![indexPath.row].type
            editScreen.taskStatus = self.tasks[taskType]![indexPath.row].status
            editScreen.doAfterEdit = { [self] title, type, status in
                let editedTask = Task(title: title, type: type, status: status)
                tasks[taskType]![indexPath.row] = editedTask
                tableView.reloadData()
            }
    // переход к экрану редактирования
        self.navigationController?.pushViewController(editScreen, animated: true)
    }
    // изменяем цвет фона кнопки с действием
        actionEditInstance.backgroundColor = .darkGray
    // создаем объект, описывающий доступные действия
    // в зависимости от статуса задачи будет отображено 1 или 2 действия
        let actionsConfiguration: UISwipeActionsConfiguration
        if tasks[taskType]![indexPath.row].status == .completed {
            actionsConfiguration = UISwipeActionsConfiguration(actions: [actionSwipeInstance, actionEditInstance])
            } else
        {
        actionsConfiguration = UISwipeActionsConfiguration(actions: [actionEditInstance]) }
            return actionsConfiguration
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let taskType = sectionsTypesPosition[indexPath.section]
        tasks[taskType]?.remove(at: indexPath.row)
        // удаляем строку, соответствующую задаче
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    // секция, из которой происходит перемещение
        let taskTypeFrom = sectionsTypesPosition[sourceIndexPath.section]
    // секция, в которую происходит перемещение
        let taskTypeTo = sectionsTypesPosition[destinationIndexPath.section]
    // безопасно извлекаем задачу, тем самым копируем ее
        guard let movedTask = tasks[taskTypeFrom]?[sourceIndexPath.row] else {
            return
        }
    // удаляем задачу с места, от куда она перенесена
        tasks[taskTypeFrom]!.remove(at: sourceIndexPath.row)
    // вставляем задачу на новую позицию
        tasks[taskTypeTo]!.insert(movedTask, at: destinationIndexPath.row)
    // если секция изменилась, изменяем тип задачи в соответствии с новой позицией
        if taskTypeFrom != taskTypeTo {
            tasks[taskTypeTo]![destinationIndexPath.row].type = taskTypeTo
        }
    // обновляем данные
    tableView.reloadData()
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateScreen" {
            let destination = segue.destination as! TaskEditController
            destination.doAfterEdit = { [unowned self] title, type, status in
                let newTask = Task(title: title, type: type, status: status)
                tasks[type]?.append(newTask)
                tableView.reloadData()
            }
            
        }
    }
    func setTasks(_ tasksCollection: [TaskProtocol]) {
    // подготовка коллекции с задачами
    // будем использовать только те задачи, для которых определена секция
        sectionsTypesPosition.forEach { taskType in
            tasks[taskType] = [] }
    // загрузка и разбор задач из хранилища
        tasksCollection.forEach { task in
            tasks[task.type]?.append(task) }
    }


}


