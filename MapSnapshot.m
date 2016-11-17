#import "MapSnapshot.h"
#import "Location.h"
#import <MapKit/MapKit.h>

@interface MapSnapshot ()

// Private interface goes here.

@end

@implementation MapSnapshot

#pragma mark - Properties

/*
    Custom getter for UIImage => UIImage from NSData
 */
-(UIImage *) image{
    return [UIImage imageWithData:self.snapshotData];
}


/*
    Custom setter for UIImage => NSData from UIImage
 */
-(void) setImage:(UIImage *)image{
    self.snapshotData = UIImageJPEGRepresentation(image, 0.9);
}


#pragma mark - Class methods
+(instancetype) mapSnapshotForLocation:(Location *) location{
    MapSnapshot *snapshot = [MapSnapshot insertInManagedObjectContext:location.managedObjectContext];
    snapshot.location = location;
    return snapshot;
}


#pragma mark - NSManagedObject lifecycle
/*
    Observe changes in the location to update the snapshot
 */

-(void) awakeFromInsert{
    [super awakeFromInsert];
    // Start observing location. Recalculate snapshot when the location changes
    [self startObserving];
}


-(void) awakeFromFetch{
    [super awakeFromFetch];
    // Start observing location. Recalculate snapshot when the location changes
    [self startObserving];
}

-(void) willTurnIntoFault{
    [super willTurnIntoFault];
    // Stop observing location.
    [self stopObserving];
}


#pragma mark - KVO
// Start observing location changes
-(void) startObserving{
    [self addObserver:self
           forKeyPath:@"location"
              options:NSKeyValueObservingOptionNew
              context:NULL];
}

// Stop observing location changes
-(void) stopObserving{
    [self removeObserver:self
              forKeyPath:@"location"];
}


// What to do when changes in location occur
-(void) observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context{
    
    // Recalculate mapSnapshot
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(self.location.latitudeValue, self.location.longitudeValue);
    
    // Define options for MKMapSnapshot
    MKMapSnapshotOptions *options = [MKMapSnapshotOptions new];
    // The region to show is centered in the location, dimensions 300x300m
    options.region = MKCoordinateRegionMakeWithDistance(center, 300, 300);
    options.mapType = MKMapTypeHybrid;
    //options.size =  CGSizeMake(150, 150);
    
    // Create snapshot
    MKMapSnapshotter *shotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [shotter startWithCompletionHandler:^(MKMapSnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (!error) {
            // Success => Save snapshot into property 'image'
            self.image = snapshot.image;
        }
        else{
            // Error => Non sense. We need to mark 'location' as 'to be deleted', but can't be done wit
            // KVC because 'location' is the property being observed, so we'll got an endless loop
            // We need to use setPrimitiveValue... for: to change the value for the property observed,
            // but this change is not notified by KVO
            [self setPrimitiveLocation:nil];
            [self.managedObjectContext deleteObject:self];
        }
    }];
}


@end
