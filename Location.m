#import "Location.h"
#import "Note.h"
#import "MapSnapshot.h"
@import AddressBookUI;
@import CoreLocation;

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
        
        // Create address by means of inverse geocoding
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
        
        // Create mapSnapshot with this location created
        loc.mapSnapshot = [MapSnapshot mapSnapshotForLocation:loc];
        
        return loc;
    }
}



#pragma mark - MKAnnotation

// The title for the MKAnnotation callout
-(NSString *) title{
    return @"I wrote a note here!";
}

// The subtitle for the MKAnnotation callout
-(NSString *) subtitle{
    
    // We need to merge the \n-separated address into a single string
    NSArray *lines = [self.address componentsSeparatedByString:@"\n"];
    NSMutableString *concat = [@"" mutableCopy];
    
    for (NSString *line in lines) {
        [concat appendFormat:@"%@ ", line];
    }
    return concat;
}

// The coordinates for the MKAnnotation
-(CLLocationCoordinate2D) coordinate{
    return CLLocationCoordinate2DMake(self.latitudeValue, self.longitudeValue);
}


@end
