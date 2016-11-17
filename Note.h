#import "_Note.h"

@interface Note : _Note

#pragma mark - Properties
@property (nonatomic, readonly) BOOL hasLocation;

#pragma mark - Class methods
+(instancetype) noteWithName:(NSString *) name
                    notebook:(Notebook *) notebook
                     context:(NSManagedObjectContext *) context;


@end
