//
//  ToDo.swift
//  ToDoList
//
//  Created by マナフォフ・マリフ on 2024/11/08.
//

import Foundation

struct ToDo: Equatable {
    let id = UUID()
    var title: String
    var isComplete: Bool
    var dueDate: Date
    var notes: String?
    
    static func loadToDos() -> [ToDo]? {
        return nil
    }
    
    static func loadSampleToDos() -> [ToDo] {
        let toDo1 = ToDo(title: "My ToDo 1", isComplete: false, dueDate: Date(), notes: "Notes 1")
        let toDo2 = ToDo(title: "My ToDo 2", isComplete: false, dueDate: Date(), notes: "Notes 2")
        let toDo3 = ToDo(title: "My ToDo 3", isComplete: false, dueDate: Date(), notes: "Notes 3")
        
        return [toDo1, toDo2, toDo3]
    }
    
    static func ==(lhs: ToDo, rhs: ToDo) -> Bool {
        return lhs.id == rhs.id
    }
}
