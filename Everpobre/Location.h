#import "_Location.h"
@import CoreLocation;
@class Note;

@interface Location : _Location

#pragma mark - Class init
+(instancetype) locationWithCLLocation:(CLLocation *) location forNote:(Note *) note;

@end