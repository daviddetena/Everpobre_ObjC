@import UIKit;
#import "_Photo.h"

@interface Photo : _Photo

#pragma mark - Properties
// Transient property to deal with UIImage instead of NSData
@property (nonatomic, strong) UIImage *image;


#pragma mark - Class methods
+(instancetype) photoWithImage:(UIImage *) image context:(NSManagedObjectContext *) context;

@end
