//
//  PhotoViewController.m
//  Everpobre
//
//  Created by David de Tena on 18/05/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import "PhotoViewController.h"
#import "Photo.h"

@interface PhotoViewController ()

#pragma mark - Properties
@property (nonatomic, strong) Photo *model;

@end

@implementation PhotoViewController


#pragma mark - Init

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
}

- (IBAction)deletePhoto:(id)sender {
}
@end
