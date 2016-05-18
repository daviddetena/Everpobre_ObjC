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

- (UIImage *) scaleAndRotateImage: (UIImage *)image{
    
    // Max resolution = device screen size * device screen scale
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat scale = [[UIScreen mainScreen] scale];
    int kMaxResolution = iOSDeviceScreenSize.width * (int)scale;

    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef),      CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}


#pragma mark - UIImagePickerControllerDelegate

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Update model so the photoView is updated in viewWillDisappear
    self.model.image = [self scaleAndRotateImage:img];
    
    // Dismiss picker
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
