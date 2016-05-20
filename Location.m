#import "Location.h"
#import "Note.h"
@import AddressBookUI;

@interface Location ()

// Private interface goes here.

@end

@implementation Location

#pragma mark - Class init
+(instancetype) locationWithCLLocation:(CLLocation *) location forNote:(Note *) note{
    
    // Check if we already has a location with the same (latitude,longitude), use that instead of creating a new one
    
    // Compound Predicate. Use a more efficent search with a pattern
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[Location entityName]];
    NSPredicate *latitude = [NSPredicate predicateWithFormat:@"abs(latitude) - abs(%lf) < 0.001", location.coordinate.latitude];
    NSPredicate *longitude = [NSPredicate predicateWithFormat:@"abs(longitude) - abs(%lf) < 0.001", location.coordinate.longitude];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[latitude, longitude]];
    
    NSError *error = nil;
    NSArray *results = [note.managedObjectContext executeFetchRequest:request
                                                                error:&error];
    
    NSAssert(results, @"Error while searching...");
    
    if ([results count]) {
        // Location already exists. Use it for the note
        Location *found = [results lastObject];
        [found addNotesObject:note];
        return found;
    }
    else{
        // Create from scratch and set its properties
        Location *loc = [self insertInManagedObjectContext:note.managedObjectContext];
        loc.latitudeValue = location.coordinate.latitude;
        loc.longitudeValue = location.coordinate.longitude;
        [loc addNotesObject:note];
        
        // Set address by means of inverse geocoding
        CLGeocoder *geocoder = [CLGeocoder new];
        [geocoder reverseGeocodeLocation:location
                       completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                           
                           if (error) {
                               NSLog(@"Error while obtaining address...%@", error);
                           }
                           else{
                               loc.address = ABCreateStringWithAddressDictionary([[placemarks lastObject] addressDictionary], YES);
                               NSLog(@"Address is %@", loc.address);
                           }
                       }];
        return loc;
    }
}

@end
