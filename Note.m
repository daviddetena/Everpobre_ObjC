#import "Note.h"
#import "Notebook.h"
#import "Location.h"
@import CoreLocation;

@interface Note ()<CLLocationManagerDelegate>

+ (NSArray *) observableKeyNames;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation Note

@synthesize locationManager = _locationManager;

#pragma mark - Getter
-(BOOL) hasLocation{
    return (nil != self.location);
}

// List with the properties to observe. Overwrite from parent class
+ (NSArray *) observableKeyNames{
    return @[@"creationDate", @"name", @"notebook", @"photo", @"location"];
}


#pragma mark - Class init
+(instancetype) noteWithName:(NSString *) name
                    notebook:(Notebook *) notebook
                     context:(NSManagedObjectContext *) context{


    // New note
    Note *note = [NSEntityDescription insertNewObjectForEntityForName:[Note entityName]
                                                       inManagedObjectContext:context];
    
    // Set dates and notebook
    note.name = name;
    note.creationDate = [NSDate date];
    note.modificationDate = [NSDate date];
    note.notebook = notebook;
    
    return note;
}


#pragma mark - Instance init

// Method that all the NSManagedObject execute once in their lifecycle. Use this method to assign a location, if possible, to the note
-(void) awakeFromInsert{
    [super awakeFromInsert];
    
    // Check if permission to location is allowed
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // Only if user permission allowed and location services enabled we can use location
    if (((status == kCLAuthorizationStatusAuthorizedAlways) || (status == kCLAuthorizationStatusAuthorizedWhenInUse) || (status == kCLAuthorizationStatusNotDetermined)) && [CLLocationManager locationServicesEnabled]) {
        
        // Create LocationManager and set delegate
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];
        
        // Not interested in new data after a long time, so we stop the
        // LocationManager after 5 seconds...
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self zapLocationManager];
        });
    }
}



#pragma mark - Utils
// Make the LocationManager stop updating
-(void) zapLocationManager{
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
}


#pragma mark - CLLocationManagerDelegate
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [self zapLocationManager];
    
    // Create new location (from the current location received) only if the note has not location yet
    if (![self hasLocation]) {
        CLLocation *loc = [locations lastObject];
        self.location = [Location locationWithCLLocation:loc forNote:self];
    }
    else{
        NSLog(@"We should never get here...");
    }
}


@end