//
//  NoteViewController.m
//  Everpobre
//
//  Created by David de Tena on 13/05/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import "NoteViewController.h"
#import "Note.h"
#import "Photo.h"

@interface NoteViewController ()
@property (nonatomic, strong) Note *model;
@end

@implementation NoteViewController

#pragma mark - Init
-(id) initWithModel:(id) model{
    if (self = [super initWithNibName:nil bundle:nil]) {
        _model = model;
        self.title = self.model.name;
    }
    return self;
}

#pragma mark - View lifecycle
// Model -> View
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateStyle = NSDateFormatterLongStyle;
    
    self.modificationDateLabel.text = [fmt stringFromDate:self.model.modificationDate];
    self.nameLabel.text = self.model.name;
    self.textView.text = self.model.text;
    
    UIImage *img = self.model.photo.image;
    if (img == nil) {
        img = [UIImage imageNamed:@"noImage.png"];
    }
    self.photoView.image = img;
}


// View -> Model
-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.model.text = self.textView.text;
    self.model.photo.image = self.photoView.image;
}



#pragma mark - Utils
// Override this method to disable orientation changes when in login screen
-(BOOL) shouldAutorotate{
    return NO;
}

@end
