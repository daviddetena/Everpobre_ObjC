#import "_MapSnapshot.h"
@import UIKit;

@interface MapSnapshot : _MapSnapshot

#pragma mark - Properties
// We want to deal with UIImage instead of NSData
@property (nonatomic, strong) UIImage *image;

#pragma mark - Class init
+(instancetype) mapSnapshotForLocation:(Location *) location;

@end
