//
//  PhotoViewController.m
//  Everpobre
//
//  Created by David de Tena on 18/05/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import "PhotoViewController.h"
#import "Photo.h"

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
