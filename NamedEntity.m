#import "NamedEntity.h"

@interface NamedEntity ()

+ (NSArray *) observableKeyNames;

@end

@implementation NamedEntity


#pragma mark - Class methods

// List with the properties to observe
+ (NSArray *) observableKeyNames{
    return @[];
}


#pragma mark - KVO

// Subscribe for changes in defined properties
// In this case, we want to update modification date with every change in the other properties
- (void) setupKVO{
    for (NSString *key in [[self class] observableKeyNames]) {
        [self addObserver:self
               forKeyPath:key
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:NULL];
    }
}


// Unsuscribe from KVO notifications in the defined properties
- (void) tearDownKVO{
    for (NSString *key in [[self class] observableKeyNames]) {
        [self removeObserver:self forKeyPath:key];
    }
}


// Check which property did change
// In this case, unlike standard notifications, you don't receive the changes on the property you wish.
// You need to check the properties and perform an action for each value.
// We don't mind that because we will update modificationDate no matter which property did change and with which value
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary<NSString *,id> *)change
                        context:(void *)context{
    
    self.modificationDate = [NSDate date];
}



#pragma mark - NSManagedObject Lifecycle

// Once in lifecycle
- (void) awakeFromInsert{
    [super awakeFromInsert];
    [self setupKVO];
}


// N-times in lifecycle => one per search and back from "fault" state
- (void) awakeFromFetch{
    [super awakeFromFetch];
    [self setupKVO];
}


// Tear down KVO when turning into fault
- (void) willTurnIntoFault{
    [self willTurnIntoFault];
    [self tearDownKVO];
}


@end
