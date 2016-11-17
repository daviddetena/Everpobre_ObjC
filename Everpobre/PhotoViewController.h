//
//  PhotoViewController.h
//  Everpobre
//
//  Created by David de Tena on 18/05/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"

@interface PhotoViewController : UIViewController<DetailViewController>

#pragma mark - Properties
@property (weak, nonatomic) IBOutlet UIImageView *photoView;

#pragma mark - Actions
- (IBAction)takePhoto:(id)sender;
- (IBAction)deletePhoto:(id)sender;
- (IBAction)applyVintageFilter:(id)sender;
- (IBAction)zoomToFace:(id)sender;

@end