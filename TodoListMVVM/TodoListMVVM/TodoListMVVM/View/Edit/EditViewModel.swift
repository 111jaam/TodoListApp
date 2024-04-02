

import Foundation
import TodoData

enum ViewStage {
    case addRootTask
    case editTask
    case addSubTask
}

class EditViewModel {
    
    private var stage = ViewStage.addRootTask
    private var currentTitle = ""
    private var todoItem: TodoItem?
    private var index: IndexPath?
    
    init(stage: ViewStage, todoItem: TodoItem?, atIndex: IndexPath?) {
        self.stage = stage
        self.todoItem = todoItem
        self.index = atIndex
        setCurrentTitle()
    }
    
    func setCurrentTitle() {
        guard let todoItem = todoItem else { return }
        currentTitle = todoItem.title
    }
    
    func titleForView() -> String {
        
        switch stage {
        case .addRootTask:
            return "Add Task"
        case .editTask:
            return "Edit Task"
        case .addSubTask:
            return "Add Sub Task"
        }
    }
    
    func defaultInputText() -> String {
        switch stage {
            
        case .addRootTask:
            return ""
        case .editTask:
            return currentTitle
        case .addSubTask:
            return ""
        }
    }
    
    func isEnableSaveButton(currentInputText: String) -> Bool {
        switch stage {
        case .addRootTask:
            return currentInputText != ""
        case .editTask:
            return currentInputText != "" && currentTitle != currentInputText && currentInputText != todoItem?.parent?.title
        case .addSubTask:
            return currentInputText != "" && currentTitle != currentInputText
        }
    }
    
    func getTodoItem() -> TodoItem {
        
        guard let item = todoItem else { return TodoItem() }
        return item
    }
    
    func getIndex() -> IndexPath {
        guard let index = index else { return IndexPath() } 
        return index
    }
    
    func getState() -> ViewStage {
        return stage
    }
}
