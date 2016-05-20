//
//  LocationViewController.h
//  Everpobre
//
//  Created by David de Tena on 20/05/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class Location;

@interface LocationViewController : UIViewController

#pragma mark - Properties
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


#pragma mark - Init
-(id) initWithLocation:(Location *) location;

#pragma mark - Actions
- (IBAction)displayStandardMap:(id)sender;
- (IBAction)displaySatelliteMap:(id)sender;
- (IBAction)displayHybridMap:(id)sender;

@end
