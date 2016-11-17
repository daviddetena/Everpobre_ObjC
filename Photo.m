#import "Photo.h"

@interface Photo ()

// Private interface goes here.

@end

@implementation Photo

#pragma mark - Properties

// Turn our transient property image into CoreData NSData
- (void) setImage:(UIImage *)image{
    self.imageData = UIImagePNGRepresentation(image);
}

// Custom getter with lazy loading
- (UIImage *) image{
    // Return a temp UIImage with its representation from CoreData (NSData)
    return [UIImage imageWithData:self.imageData];
}


#pragma mark - Class Methods
+(instancetype) photoWithImage:(UIImage *) image
                       context:(NSManagedObjectContext *) context{
    
    Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:[Photo entityName]
                                                 inManagedObjectContext: context];
    
    photo.imageData = UIImageJPEGRepresentation(image, 0.9);
    return photo;
}

@end
