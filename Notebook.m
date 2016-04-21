#import "Notebook.h"

@interface Notebook ()

// Private interface goes here.

@end

@implementation Notebook


#pragma mark - Class methods

+(instancetype) notebookWithName:(NSString *) name
                         context:(NSManagedObjectContext *) context{

    // New notebook
    Notebook *notebook = [NSEntityDescription insertNewObjectForEntityForName:[Notebook entityName]
                                                       inManagedObjectContext:context];
    
    // Set dates
    notebook.creationDate = [NSDate date];
    notebook.modificationDate = [NSDate date];
    
    return notebook;
}

@end
