//
//  LocationViewController.m
//  Everpobre
//
//  Created by David de Tena on 20/05/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import "LocationViewController.h"
#import "Location.h"

@interface LocationViewController ()<MKMapViewDelegate>
#pragma mark - Properties
@property (strong, nonatomic) Location *model;

@end

@implementation LocationViewController

#pragma mark - Init
-(id) initWithLocation:(Location *) location{
    if (self = [super initWithNibName:nil bundle:nil]) {
        _model = location;
        self.title = @"Map";
    }
    return self;
}

#pragma mark - View lifecycle
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Add the current location (implements MKAnnotation) as an annotation in the mapView
    [self.mapView addAnnotation:self.model];
    
    // Set initial region and animate (no zoom)
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.model.coordinate, 2000000, 2000000);
    [self.mapView setRegion:region];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // Set new region with zoom after 1 second delay
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.model.coordinate, 500, 500);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mapView setRegion:region animated:YES];
    });
}



#pragma mark - Actions

- (IBAction)displayStandardMap:(id)sender {
    self.mapView.mapType = MKMapTypeStandard;
}

- (IBAction)displaySatelliteMap:(id)sender {
    self.mapView.mapType = MKMapTypeSatellite;
}

- (IBAction)displayHybridMap:(id)sender {
    self.mapView.mapType = MKMapTypeHybrid;
}
@end


#pragma mark - MKMapViewDelegate

