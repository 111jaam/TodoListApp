//
//  TodoManager.m
//  TodoData


#import <Foundation/Foundation.h>
#import "TodoManager.h"

@implementation TodoItemManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _rootTasks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_rootTasks release]; // Ensure to release the allTasks array
    [super dealloc];
}

- (void)loadTasks {
    // Remove all existing tasks
    [self.rootTasks removeAllObjects];

    // Assign sequential numbers to each root task
    for (NSInteger i = 0; i < [self.rootTasks count]; i++) {
        TodoItem *rootTask = [self.rootTasks objectAtIndex:i];
        rootTask.number = i + 1;
    }
}

- (NSArray<TodoItem *> *)flattenTasks:(TodoItem *)task {
    NSMutableArray<TodoItem *> *flattenedTasks = [NSMutableArray array];
    [flattenedTasks addObject:task];
    
    for (TodoItem *subtask in task.subtasks) {
        [flattenedTasks addObjectsFromArray:[self flattenTasks:subtask]];
    }
    
    return [flattenedTasks copy];
}

- (void)addTaskWithTitle:(NSString *)title parent:(nullable TodoItem *)parent {
    TodoItem *newTask = [[TodoItem alloc] initWithTitle:title parent:parent isCompleted:NO];
    
    if (parent) {
        // Add as a subtask to the specified parent
        [parent.subtasks addObject:newTask];
    } else {
        // Add as a new root task
        [self.rootTasks addObject:newTask];
        // Sequentially number the root tasks
        for (NSInteger i = 0; i < [self.rootTasks count]; i++) {
            TodoItem *rootTask = [self.rootTasks objectAtIndex:i];
            rootTask.number = i + 1;
        }
    }
}

- (void)removeTask:(TodoItem *)task {
    // Check if the task is a root task
    if (!task.parent) {
        // Removing a root task along with its subtasks
        [self recursivelyRemoveTask:task];
        [self.rootTasks removeObject:task];
    } else {
        // Removing a subtask
        [self recursivelyRemoveTask:task];
        [task.parent.subtasks removeObject:task];
    }
    
    // Assign sequential numbers to each root task
    for (NSInteger i = 0; i < [self.rootTasks count]; i++) {
        TodoItem *rootTask = [self.rootTasks objectAtIndex:i];
        rootTask.number = i + 1;
    }
}

- (void)recursivelyRemoveTask:(TodoItem *)task {
    // Recursively remove all subtasks
    for (TodoItem *subtask in task.subtasks) {
        [self recursivelyRemoveTask:subtask]; // Recursive call for each subtask
    }
}

@end
