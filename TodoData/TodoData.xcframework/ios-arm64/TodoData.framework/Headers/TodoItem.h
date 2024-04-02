//
//  TodoItem.h
//  TodoData


#import <Foundation/Foundation.h>
    
NS_ASSUME_NONNULL_BEGIN


@interface TodoItem : NSObject

@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSMutableArray<TodoItem *> *subtasks;
@property (assign, nonatomic, nullable) TodoItem *parent;
@property (assign, nonatomic) BOOL isCompleted;
@property (assign, nonatomic) NSInteger number; // Add this line

- (instancetype)initWithTitle:(NSString *)title
                        parent:(TodoItem * _Nullable)parent
                  isCompleted:(BOOL)isCompleted;

- (void)addSubtask:(TodoItem *)subtask;
- (void)removeSubtask:(TodoItem *)subtask;
- (BOOL)isSubtaskOf:(TodoItem *)task;
- (NSInteger)depthInHierarchy;

@end

NS_ASSUME_NONNULL_END
