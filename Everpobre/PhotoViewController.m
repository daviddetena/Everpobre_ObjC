//
//  PhotoViewController.m
//  Everpobre
//
//  Created by David de Tena on 18/05/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import "PhotoViewController.h"
#import "Photo.h"
#import "UIImage+Resize.h"
@import CoreImage;

@interface PhotoViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

#pragma mark - Properties
@property (nonatomic, strong) Photo *model;
@property (nonatomic) BOOL isCameraSourceSelected;

@end

@implementation PhotoViewController


#pragma mark - Init

// From DetailViewControllerDelegate
-(id) initWithModel:(id) model{
    
    NSAssert(model, @"Model can't be nil");
    
    if (self = [super initWithNibName:nil
                               bundle:nil]) {
        _model = model;
        self.title = @"Note image";
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
    picker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    picker.editing = NO;
    
    // Set delegate
    picker.delegate = self;
    
    // Configure it
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // Device has camera => Present Action sheet
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        
        // Action for taking a new photo
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                                 self.isCameraSourceSelected = YES;
                                                                 [self presentViewController:picker animated:YES completion:nil];
                                                             }];
        
        // Action for selecting a previous photo
        UIAlertAction *cameraRollAction = [UIAlertAction actionWithTitle:@"Photo Library"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                                     [self presentViewController:picker animated:YES completion:nil];
                                                                 }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:nil];
        
        [alert addAction:cameraAction];
        [alert addAction:cameraRollAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];        
    }
    else{
        // Device has not camera => use camera roll
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker
                           animated:YES
                         completion:^{
                             
                         }];
    }
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


/*
    Detect faces, select one and zoom it
 */
- (IBAction)zoomToFace:(id)sender {
    NSArray *features = [self featuresInImage:self.photoView.image];
    
    if (features) {
        // Take the last of the faces found
        CIFeature *face = [features lastObject];
        CGRect faceBounds = [face bounds];
        
        // Create a new image with the "face" from the original
        CIImage *image = [CIImage imageWithCGImage:self.photoView.image.CGImage];
        CIImage *imageCrop = [image imageByCroppingToRect:faceBounds];
        
        UIImage *newImage = [UIImage imageWithCIImage:imageCrop];
        
        // Assign zoomed image to photoView
        self.photoView.image = newImage;
    }
    else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"No faces detected" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:doneAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


#pragma mark - Utils
// This method returns an array of features detected in an image, faces in this case
- (NSArray *) featuresInImage:(UIImage *) image{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:context
                                              options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    
    CIImage *img = [CIImage imageWithCGImage:image.CGImage];
    NSArray *features = [detector featuresInImage:img];
    if ([features count]) {
        return features;
    }
    return nil;
}


#pragma mark - UIImagePickerControllerDelegate

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    // The image taken will be resized and rotated (if needed) in the background
    __block UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Take screen dimensions
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGSize screenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
    
    
    // Show alert with an UIActivityView animating while processing in the background
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.hidesWhenStopped = YES;
    activityView.frame = CGRectMake(screenBounds.size.width/2, screenBounds.size.height/2, 50, 50);
    [self.view addSubview:activityView];
    [activityView startAnimating];
    //UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   //message:@"Loading..."
                                                            //preferredStyle:UIAlertControllerStyleAlert];
    //[alert.view addSubview:activityView];
    //[self presentViewController:alert animated:YES completion:nil];
    
    
    // Rotate (if needed) and reduce size of image taken, in the background (cause it has high memory consuptiom)
    // Thank to Trevor Harmon's Categories
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        img = [img resizedImage:screenSize interpolationQuality:kCGInterpolationMedium];
        
        // Refresh UI in main queue, and model (so the photoView is updated in viewWillDisappear)
        dispatch_async(dispatch_get_main_queue(), ^{
            [activityView stopAnimating];
            self.photoView.image = img;
            self.model.image = img;
        });
    });
    
    // Dismiss picker
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
