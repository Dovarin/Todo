//
//  Task.swift
//  To-Do Manager
//
//  Created by Данил Гусев on 28.08.2021.
//

import Foundation


// тип задачи
enum TaskPriority {
// текущая
    case normal
// важная
    case important
}
// состояние задачи
enum TaskStatus: Int {
// запланированная
    case planned
// завершенная
    case completed
}

protocol TaskProtocol {
// название
    var title: String { get set }
// тип
    var type: TaskPriority { get set } // статус
    var status: TaskStatus { get set }
}

struct Task: TaskProtocol {
   
    var title: String
    
    var type: TaskPriority
    
    var status: TaskStatus
    
    
}
