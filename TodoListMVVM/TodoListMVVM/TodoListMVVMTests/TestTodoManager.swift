//
//  TestTodoManager.swift
//  TodoListMVVMTests

import TodoData
import XCTest

final class TestTodoManager: XCTestCase {

    var todoManager: TodoItemManager!

    override func setUp() {
        super.setUp()
        todoManager = TodoItemManager()
    }

    override func tearDown() {
        todoManager = nil
        super.tearDown()
    }
    
    func testLoadTasks() {
        todoManager.loadTasks()
        XCTAssertFalse(todoManager.rootTasks.count == 0, "Root tasks should not be empty after loading tasks.")
    }

    func testAddRootTask() {
        let initialCount = todoManager.rootTasks.count
        todoManager.addTask(withTitle: "New Root Task", parent: nil)
        XCTAssertEqual(todoManager.rootTasks.count, initialCount + 1, "Should have one more root task after addition.")
    }

    func testAddSubtask() {
        let rootTask = TodoItem(title: "Root Task", parent: nil, isCompleted: false)
        todoManager.rootTasks = [rootTask] // Manually setting a root task
        todoManager.addTask(withTitle: "Subtask", parent: rootTask)
        XCTAssertFalse(rootTask.subtasks.count == 0, "Root task should have a subtask after addition.")
    }

    func testRemoveTask() {
        let taskToRemove = TodoItem(title: "Task to Remove", parent: nil, isCompleted: false)
        todoManager.rootTasks = [taskToRemove] // Manually setting the task to be removed
        todoManager.removeTask(taskToRemove)
        XCTAssertTrue(todoManager.rootTasks.count == 0, "Root tasks should be empty after removing the task.")
    }

    func testFlattenTasks() {
        // Setup a task with subtasks
        let rootTask = TodoItem(title: "Root", parent: nil, isCompleted: false)
        let subtask1 = TodoItem(title: "Subtask 1", parent: rootTask, isCompleted: false)
        let subtask2 = TodoItem(title: "Subtask 2", parent: rootTask, isCompleted: false)
        rootTask.subtasks = [subtask1, subtask2]
        todoManager.rootTasks = [rootTask]

        let flattened = todoManager.flattenTasks(rootTask)
        XCTAssertEqual(flattened.count, 3, "Flattened tasks should include root and subtasks.")
    }

}
