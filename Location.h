#import "_Location.h"
#import <MapKit/MapKit.h>
@import CoreLocation;
@class Note;

@interface Location : _Location<MKAnnotation>

#pragma mark - Class init
+(instancetype) locationWithCLLocation:(CLLocation *) location forNote:(Note *) note;

@end
