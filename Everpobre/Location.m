#import "Location.h"
#import "Note.h"
@import AddressBookUI;

@interface Location ()

// Private interface goes here.

@end

@implementation Location

#pragma mark - Class init
+(instancetype) locationWithCLLocation:(CLLocation *) location forNote:(Note *) note{
    
    // Create a new empty loc and set its properties
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
                       }
                   }];
    return loc;
}


@end