//
//  TodoItem.m
//  TodoData

#import <Foundation/Foundation.h>
#import "TodoItem.h"

@implementation TodoItem

@synthesize number = _number; // Add this line

- (instancetype)initWithTitle:(NSString *)title
                        parent:(TodoItem * _Nullable)parent
                  isCompleted:(BOOL)isCompleted {
    self = [super init];
    if (self) {
         _title = [title retain]; // Retain the title
        _subtasks = [[NSMutableArray alloc] init];
        _parent = parent;
        _isCompleted = isCompleted;
    }
    return self;
}

- (void)dealloc {
    [_title release]; // Release the title
    [_subtasks release]; // Release the subtasks array
    // No need to release parent because it was not retained
    [super dealloc];
}

- (BOOL)isSubtaskOf:(TodoItem *)task {
    TodoItem *currentParent = self.parent;
    while (currentParent != nil) {
        if (currentParent == task) {
            return YES;
        }
        currentParent = currentParent.parent;
    }
    return NO;
}

- (void)addSubtask:(TodoItem *)subtask {
    subtask.parent = self;
    [self.subtasks addObject:subtask];
}

- (void)removeSubtask:(TodoItem *)subtask {
    [self.subtasks removeObject:subtask];
    subtask.parent = nil;
}

- (void)setIsCompleted:(BOOL)isCompleted {
    // Avoid redundant updates to prevent infinite recursion
    if (_isCompleted == isCompleted) {
        return;
    }
    
    _isCompleted = isCompleted;
    
    // Update all subtasks to match the parent task's completion status
    // This loop is safe from infinite recursion because it only acts on child objects,
    // and the guard at the start of this method prevents re-entering this logic for the same completion state
//    if (_isCompleted) {
        for (TodoItem *subtask in self.subtasks) {
            subtask.isCompleted = isCompleted;
        }
//    }

    // If this is a subtask and it's being marked as incomplete, or all siblings are complete, update the parent
    if (self.parent) {
        // If marking as incomplete, immediately mark the parent as incomplete
        if (!isCompleted) {
            self.parent.isCompleted = NO;
        } else {
            // Check if all siblings are complete, including this subtask
            BOOL allSiblingsCompleted = YES;
            for (TodoItem *sibling in self.parent.subtasks) {
                if (!sibling.isCompleted) {
                    allSiblingsCompleted = NO;
                    break;
                }
            }
            // Only update the parent if all siblings are completed
            if (allSiblingsCompleted) {
                self.parent.isCompleted = YES;
            }
        }
    }
}

- (NSInteger)depthInHierarchy {
    NSInteger depth = 0;
    TodoItem *currentItem = self;
    while (currentItem.parent != nil) {
        depth++;
        currentItem = currentItem.parent;
    }
    return depth;
}

@end
