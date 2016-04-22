#import "Note.h"

@interface Note ()

+ (NSArray *) observableKeyNames;

@end

@implementation Note

#pragma mark - Class methods

// List with the properties to observe. Overwrite from parent class
+ (NSArray *) observableKeyNames{
    return @[@"creationDate", @"name", @"notebook", @"photo"];
}

+(instancetype) noteWithName:(NSString *) name
                    notebook:(Notebook *) notebook
                     context:(NSManagedObjectContext *) context{


    // New note
    Note *note = [NSEntityDescription insertNewObjectForEntityForName:[Note entityName]
                                                       inManagedObjectContext:context];
    
    // Set dates and notebook
    note.name = name;
    note.creationDate = [NSDate date];
    note.modificationDate = [NSDate date];
    note.notebook = notebook;
    
    return note;
}

@end