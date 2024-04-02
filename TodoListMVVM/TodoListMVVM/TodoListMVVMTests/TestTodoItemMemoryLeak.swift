//
//  TestTodoItemMemoryLeak.swift
//  TodoListMVVMTests

import XCTest
import TodoData

final class TestTodoItemMemoryLeak: XCTestCase {

    func testTodoItemLeak() {
        // Directly assigning and nullifying the strong reference
        weak var weakTodoItem: TodoItem? = {
            let temporaryTodoItem = TodoItem(title: "Test", parent: nil, isCompleted: false)
            return temporaryTodoItem
        }() // The temporaryTodoItem is deallocated at the end of this closure
        
        // Add a teardown block to check if the object was deallocated
        addTeardownBlock {
            XCTAssertNil(weakTodoItem, "TodoItem should have been deallocated. Potential memory leak detected.")
        }
    }
    
    func testRemovingSubtaskDoesNotLeak() {
        weak var weakSubtaskTodoItem: TodoItem?
        
        // Setup parent and subtask, then remove subtask to test deallocation
        autoreleasepool {
            let parentTodoItem = TodoItem(title: "Parent", parent: nil, isCompleted: false)
            let subtaskTodoItem = TodoItem(title: "Subtask", parent: parentTodoItem, isCompleted: false)

            parentTodoItem.addSubtask(subtaskTodoItem)
            parentTodoItem.removeSubtask(subtaskTodoItem)
            
            // Only the subtask is being checked for deallocation here
            weakSubtaskTodoItem = subtaskTodoItem
        }
        
        // The subtask should be deallocated after being removed from its parent
        addTeardownBlock {
            XCTAssertNil(weakSubtaskTodoItem, "Subtask TodoItem should be deallocated if no memory leak.")
        }
    }
    
    func testAddingSubtaskDoesNotLeak() {
            // Setup weak variables to hold references for testing potential leaks
        weak var weakParentTodoItem: TodoItem?
        weak var weakSubtaskTodoItem: TodoItem?
        
        // A closure that sets up the test scenario, allowing objects to go out of scope thereafter
        autoreleasepool {
            let parentTodoItem = TodoItem(title: "Parent", parent: nil, isCompleted: false)
            let subtaskTodoItem = TodoItem(title: "Subtask", parent: parentTodoItem, isCompleted: false)
            parentTodoItem.addSubtask(subtaskTodoItem)
            
            // Assign the instances to weak variables to test for their deallocation
            weakParentTodoItem = parentTodoItem
            weakSubtaskTodoItem = subtaskTodoItem
        } // Objects potentially deallocated here if no leaks
        
        // Use a teardown block to verify deallocation
        addTeardownBlock {
            XCTAssertNil(weakParentTodoItem, "Parent TodoItem should be deallocated if no memory leak.")
            XCTAssertNil(weakSubtaskTodoItem, "Subtask TodoItem should be deallocated if no memory leak.")
        }
    }
}
