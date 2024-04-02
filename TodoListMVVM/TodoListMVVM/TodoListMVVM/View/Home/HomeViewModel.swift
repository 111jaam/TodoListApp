

import Foundation
import TodoData
import UIKit

class HomeViewModel {
    
    private let todoItemManager = TodoItemManager()
    var todoItems: [TodoItem] = []
    private var currentCompleteItemStatus: [Bool] = []
    
    //Load Defaulf Task, you can change to load by json or anything.
    func loadTasks() {
        todoItemManager.loadTasks()
        todoItems.removeAll()
        guard let rootTasks = todoItemManager.rootTasks as? [TodoItem] else { return }
        for task in rootTasks {
            let flattenedTasks = todoItemManager.flattenTasks(task)
            todoItems.append(contentsOf: flattenedTasks)
        }
    }
    
    func addRootTask(title: String) {
        todoItemManager.addTask(withTitle: title, parent: nil)
    }
    
    func indexPathEffectAfterAddRoot() -> [IndexPath] {
        if let newTask = todoItemManager.rootTasks.lastObject as? TodoItem {
            let flattenedNewTask = todoItemManager.flattenTasks(newTask)
            // Find the insertion index in todoItems
            let insertionStartIndex = todoItems.count
            todoItems.append(contentsOf: flattenedNewTask)
            // Calculate the index paths to insert in the table view
            return (insertionStartIndex..<todoItems.count).map { IndexPath(row: $0, section: 0) }
        }
        return []
    }
    
    func addSubtask(title: String, to parent: TodoItem) {
        todoItemManager.addTask(withTitle: title, parent: parent)
        refreshTodoItemsFromManager()
    }
    
    func indexPathEffectAfterAddSubTask(parent: TodoItem) -> [IndexPath] {
        guard let lastObject = parent.subtasks.lastObject as? TodoItem, let index = todoItems.firstIndex(of: lastObject) else { return [] }
        return [IndexPath(row: index, section: 0)]
    }
    
    func removeTask(at index: Int) {
        let task = todoItems[index]
        todoItemManager.removeTask(task)
    }
    
    func toggleCompletion(for index: Int) -> [IndexPath]{
        let task = todoItems[index]
        currentCompleteItemStatus = todoItems.map {$0.isCompleted}
        task.isCompleted.toggle() // This toggles the isCompleted property of the task.
        let newCompleteItemStatus = todoItems.map {$0.isCompleted}
        return calCulateDifferentIndex(current: currentCompleteItemStatus, new: newCompleteItemStatus)
    }
    
    // Detect list isCompleted changing
    private func calCulateDifferentIndex(current: [Bool], new: [Bool]) -> [IndexPath] {
        let differentList = zip(current, new).enumerated().filter() {
            $1.0 != $1.1
        }.map{$0.0}
                
        return differentList.map {IndexPath(row: $0, section: 0)}
    }
    
    // Find Level of each task
    private func findLevel(of task: TodoItem) -> Int {
        var level = 0
        var currentTask = task
        while let parent = currentTask.parent {
            level += 1
            currentTask = parent
        }
        return level
    }
    
    private func refreshTodoItemsFromManager() {
        todoItems.removeAll()
        for rootTask in todoItemManager.rootTasks {
            
            let flattenedTasks = todoItemManager.flattenTasks(rootTask as! TodoItem)
            todoItems.append(contentsOf: flattenedTasks)
        }
    }
    
    func hierarchicalTitle(for task: TodoItem) -> String {
        
        var titleWithHierarchy: String
        
        if let _ = task.parent {
            // It's a child task, build the title with hierarchy
            var levelTitles: [String] = []
            var currentTask: TodoItem? = task
            var rootTaskNumber = 1
            while let current = currentTask, let parent = current.parent {
                let index = (parent.subtasks as NSArray).index(of: current)
                if index != NSNotFound {
                    levelTitles.insert("\(index + 1)", at: 0)
                }
                currentTask = current.parent
                
                //Find the Root Number
                if currentTask?.parent == nil, let currentTask = currentTask {
                    rootTaskNumber = currentTask.number
                }
            }
            titleWithHierarchy = "Child \(rootTaskNumber)." + levelTitles.joined(separator: ".") + " - " + task.title
        } else {
            // It's a root task, use the number property
            titleWithHierarchy = "Root \(task.number) - " + task.title
        }
        
        return titleWithHierarchy
    }
    
    func indexRangeOfTaskAndSubtasks(for task: TodoItem) -> [IndexPath] {
        
        guard let startIndex = todoItems.firstIndex(where: { $0 === task }) else {
            return []
        }
        
        var endIndex = startIndex
        while endIndex + 1 < todoItems.count, todoItems[endIndex + 1].isSubtask(of: task) {
            endIndex += 1
        }
        
        let rank = startIndex..<endIndex + 1
        return rank.map { IndexPath(row: $0, section: 0) }
    }
    
    func findIndexEffectAfterDelete(for task: TodoItem) -> [IndexPath] {
        
        var indexPath: [IndexPath] = []

        for item in todoItems {
            if item.isSubtask(of: task) {
                if let indexSubEffect = todoItems.firstIndex(of: item) {
                    indexPath.append(IndexPath(row: indexSubEffect, section: 0))
                    if item.subtasks.count > 0 {
                        for i in item.subtasks {
                            let indexSubofSubEffect = item.subtasks.index(of: i)
                            indexPath.append(IndexPath(row: indexSubofSubEffect, section: 0))
                        }
                    }
                }
            }
        }
                
        return indexPath
    }
    
    func removeTask(todoItem: TodoItem) {
        self.todoItemManager.removeTask(todoItem)
        refreshTodoItemsFromManager()
    }
    
    func numberOfItem() -> Int {
        return todoItems.count
    }
    
    func getDataForCellByItem(item: TodoItem) -> CellData {
        
        let hierarchicalTitle = hierarchicalTitle(for: item)
        let buttonImage = buttonImage(item: item)
        let level = findLevel(of: item)
        
        return CellData(title: hierarchicalTitle, level: level, checkImage: buttonImage)
    }
    
    func buttonImage(item: TodoItem) -> String {
        
        return item.isCompleted ? Constant.checkedImage : Constant.unCheckedImage
    }
    
    func canAddSubTask(todoItem: TodoItem) -> Bool {
        
        if todoItem.depthInHierarchy() < Constant.maxTreeLevel {
            return true
        }
        return false
    }
    
    func initEditVC(withStage: ViewStage, todoItem: TodoItem?, atIndex: IndexPath?) -> EditViewController {
        guard let editVC = UIStoryboard(name: Constant.storyboardName, bundle: nil).instantiateViewController(withIdentifier: Constant.editViewControllerIdentifier) as? EditViewController else { return EditViewController() }
        let editVM = EditViewModel(stage: withStage, todoItem: todoItem, atIndex: atIndex)
        editVC.viewModel = editVM
        return editVC
    }
    
    func isFirstRootTask(item: TodoItem) -> Bool {
        return item.number == 1
    }
}
