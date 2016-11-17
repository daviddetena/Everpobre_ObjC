#import "_Notebook.h"

@interface Notebook : _Notebook

#pragma mark - Class methods
+(instancetype) notebookWithName:(NSString *) name context:(NSManagedObjectContext *) context;

@end
