//
//  TestTodoManagerMemoryLeak.swift
//  TodoListMVVMTests

import XCTest
import TodoData

final class TestTodoManagerMemoryLeak: XCTestCase {

    func testTodoManagerLeak() {
       // Directly creating a scope for todoManager
       // The use of `todoManager` is implicit in its role to test for leaks
       weak var weakTodoManager: TodoItemManager? = {
           let manager = TodoItemManager()
           return manager
       }() // manager goes out of scope here, potentially allowing for deallocation
       
       addTeardownBlock {
           // If weakTodoManager is nil, it means TodoItemManager was deallocated as expected
           XCTAssertNil(weakTodoManager, "TodoManager should have been deallocated. Potential memory leak detected.")
       }
    }

}
