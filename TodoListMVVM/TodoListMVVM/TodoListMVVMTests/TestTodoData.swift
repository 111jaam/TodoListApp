//
//  TestTodoData.swift
//  TodoListMVVMTests

import XCTest
import TodoData

final class TestTodoData: XCTestCase {

    func testTodoItemInitialization() {
        let title = "Test Todo Item"
        let todoItem = TodoItem(title: title, parent: nil, isCompleted: false)
                
        XCTAssertNotNil(todoItem, "The todo item should not be nil.")
        XCTAssertEqual(todoItem.title, title, "The todo item's title should be \(title).")
        XCTAssertFalse(todoItem.isCompleted, "The todo item should initially be not completed.")
    }
    
    func testAddingSubtask() {
        let parentTask = TodoItem(title: "Parent Task", parent: nil, isCompleted: false)
        let subtask = TodoItem(title: "Subtask", parent: parentTask, isCompleted: false)
        
        parentTask.addSubtask(subtask)
        
        XCTAssertTrue(parentTask.subtasks.contains(where: { subtaskInArray in
            guard let subtaskInArrayAsTodoItem = subtaskInArray as? TodoItem else { return false }
            return subtaskInArrayAsTodoItem === subtask
        }))
    }
        
    func testRemovingSubtask() {
        let parentTask = TodoItem(title: "Parent Task", parent: nil, isCompleted: false)
        let subtask = TodoItem(title: "Subtask", parent: parentTask, isCompleted: false)
        
        parentTask.addSubtask(subtask)
        parentTask.removeSubtask(subtask)
        
        XCTAssertFalse(parentTask.subtasks.contains(where: { subtaskInArray in
            guard let subtaskInArrayAsTodoItem = subtaskInArray as? TodoItem else { return false }
            return subtaskInArrayAsTodoItem === subtask
        }))
    }
        
    func testIsSubtaskOf() {
        let parentTask = TodoItem(title: "Parent Task", parent: nil, isCompleted: false)
        let subtask = TodoItem(title: "Subtask", parent: parentTask, isCompleted: false)
        
        XCTAssertTrue(subtask.isSubtask(of: parentTask), "Subtask should be recognized as a subtask of the parent task.")
}
        
    func testDepthInHierarchy() {
        let rootTask = TodoItem(title: "Root Task", parent: nil, isCompleted: false)
        let childTask = TodoItem(title: "Child Task", parent: rootTask, isCompleted: false)
        let grandchildTask = TodoItem(title: "Grandchild Task", parent: childTask, isCompleted: false)
        
        rootTask.addSubtask(childTask)
        childTask.addSubtask(grandchildTask)
        
        XCTAssertEqual(grandchildTask.depthInHierarchy(), 2, "Grandchild task should have a depth of 2 in the hierarchy.")
    }


}
