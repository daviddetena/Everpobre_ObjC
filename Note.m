#import "Note.h"

@interface Note ()

// Private interface goes here.

@end

@implementation Note

#pragma mark - Class methods
+(instancetype) noteWithName:(NSString *) name
                    notebook:(Notebook *) notebook
                     context:(NSManagedObjectContext *) context{


    // New note
    Note *note = [NSEntityDescription insertNewObjectForEntityForName:[Note entityName]
                                                       inManagedObjectContext:context];
    
    // Set dates and notebook
    note.creationDate = [NSDate date];
    note.modificationDate = [NSDate date];
    note.notebook = notebook;
    
    return note;
}

@end
