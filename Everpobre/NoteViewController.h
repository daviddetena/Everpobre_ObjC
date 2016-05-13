//
//  NoteViewController.h
//  Everpobre
//
//  Created by David de Tena on 13/05/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class Note;


@interface NoteViewController : UIViewController

#pragma mark - Properties
@property (weak, nonatomic) IBOutlet UILabel *modificationDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

#pragma mark - Init
-(id) initWithModel:(Note *) model;

@end