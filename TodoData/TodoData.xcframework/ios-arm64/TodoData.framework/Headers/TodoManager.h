//
//  TodoManager.h
//  TodoData
//

#import <Foundation/Foundation.h>
//#import "TodoItem.h"
#import <TodoData/TodoItem.h>


NS_ASSUME_NONNULL_BEGIN

@interface TodoItemManager : NSObject

@property (nonatomic, retain) NSMutableArray<TodoItem *> *rootTasks;

- (void)loadTasks;
- (NSArray<TodoItem *> *)flattenTasks:(TodoItem *)task;
- (void)addTaskWithTitle:(NSString *)title parent:(nullable TodoItem *)parent;
- (void)removeTask:(TodoItem *)task;

@end

NS_ASSUME_NONNULL_END
