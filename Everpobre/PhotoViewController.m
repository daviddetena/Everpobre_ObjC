//
//  PhotoViewController.m
//  Everpobre
//
//  Created by David de Tena on 18/05/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import "PhotoViewController.h"
#import "Photo.h"
@import CoreImage;

@interface PhotoViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

#pragma mark - Properties
@property (nonatomic, strong) Photo *model;

@end

@implementation PhotoViewController


#pragma mark - Init

// From DetailViewControllerDelegate
-(id) initWithModel:(id) model{
    
    NSAssert(model, @"Model can't be nil");
    
    if (self = [super initWithNibName:nil
                               bundle:nil]) {
        _model = model;
    }
    return self;
}


#pragma mark - View lifecycle

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Sync view with model data
    self.photoView.image = self.model.image;
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // Sync model data with view
    self.model.image = self.photoView.image;
}


#pragma mark - Actions

- (IBAction)takePhoto:(id)sender {
    
    // Create UIImagePicker
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    // Configure it
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // Device has camera
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else{
        // Device has not camera => use camera roll
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    picker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    // Set delegate
    picker.delegate = self;
    
    // Display it
    [self presentViewController:picker
                       animated:YES
                     completion:^{
                         
                     }];
}


- (IBAction)deletePhoto:(id)sender {
    
    // Save photo's initial status
    CGRect oldBounds = self.photoView.bounds;
    
    // Delete photo from the view
    [UIView animateWithDuration:0.6
                          delay:0
                        options:0
                     animations:^{
                         // Reduce size while centering
                         self.photoView.bounds = CGRectZero;
                         self.photoView.alpha = 0;
                         
                         // Affine transform
                         self.photoView.transform = CGAffineTransformMakeRotation(M_2_PI);
                         
                     } completion:^(BOOL finished) {
                         self.photoView.image = nil;
                         self.photoView.alpha = 1;
                         // Restore old bounds for the next time
                         self.photoView.bounds = oldBounds;
                         
                         // Restore Affine Transform
                         self.photoView.transform = CGAffineTransformIdentity;
                     }];
    
    // Delete photo from model
    self.model.image = nil;
}


- (IBAction)applyVintageFilter:(id)sender {
    
    // Create a CIContext
    CIContext *context = [CIContext contextWithOptions:nil];
    
    // Create an input CIImage from our model image
    CIImage *inputImage = [CIImage imageWithCGImage:self.model.image.CGImage];
    
    // Create a filter and set defaults (some with KVC)
    CIFilter *filterOld = [CIFilter filterWithName:@"CIFalseColor"];
    [filterOld setDefaults];
    [filterOld setValue:inputImage forKey:kCIInputImageKey];
    
    // Apply another filter, create vignette filter
    CIFilter *vignetteFilter = [CIFilter filterWithName:@"CIVignette"];
    [vignetteFilter setDefaults];
    // Apply 12pts of intensity on filter
    [vignetteFilter setValue:@12 forKey:kCIInputIntensityKey];
    
    // Chain filters (output from "old" filter is the input for "vignette" filter)
    [vignetteFilter setValue:filterOld.outputImage forKey:kCIInputImageKey];
    
    // Get output image
    CIImage *outputImage = vignetteFilter.outputImage;
    
    
    // Show alert with an UIActivityView animating while processing in the background
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.hidesWhenStopped = YES;
    activityView.frame = CGRectMake(10, 5, 50, 50);
    [activityView startAnimating];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"Applying filter..."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert.view addSubview:activityView];
    [self presentViewController:alert animated:YES completion:nil];
    
    // Apply the filter on the whole output image (in background, it takes a few moments...)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGImageRef result = [context createCGImage:outputImage
                                          fromRect:[outputImage extent]];
        
        // Refresh UI in main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            // Stop activity view and hide the alert
            [activityView stopAnimating];
            [alert dismissViewControllerAnimated:YES completion:nil];            
            
            // Save new image
            UIImage *newImage = [UIImage imageWithCGImage:result];
            self.photoView.image = newImage;
            
            // Release CGImageRef result
            CGImageRelease(result);
        });
    });
}


#pragma mark - UIImagePickerControllerDelegate

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // High memory consumption => pass quickly to core data and trash it
    self.model.image = img;
    
    // Dismiss picker
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end
