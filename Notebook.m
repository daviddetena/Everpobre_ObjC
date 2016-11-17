#import "Notebook.h"

@interface Notebook ()

+ (NSArray *) observableKeyNames;

@end

@implementation Notebook


#pragma mark - Class methods

// List with the properties to observe. Overwrite from parent class
+ (NSArray *) observableKeyNames{
    return @[@"creationDate", @"name", @"notes"];
}

+(instancetype) notebookWithName:(NSString *) name
                         context:(NSManagedObjectContext *) context{

    // New notebook
    Notebook *notebook = [NSEntityDescription insertNewObjectForEntityForName:[Notebook entityName]
                                                       inManagedObjectContext:context];
    
    // Set dates
    notebook.name = name;
    notebook.creationDate = [NSDate date];
    notebook.modificationDate = [NSDate date];
    
    return notebook;
}

@end