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
    
    // Sync changes from model to view
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
    
    [self startObservingKeyboard];
    [self setupInputAccessoryView];
}


-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // Sync changes from view to model
    self.model.text = self.textView.text;
    self.model.photo.image = self.photoView.image;
    
    [self stopObservingKeyboard];
}



#pragma mark - Utils
// Override this method to disable orientation changes when in login screen
-(BOOL) shouldAutorotate{
    return NO;
}


#pragma mark - Keyboard
- (void) startObservingKeyboard{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    // Suscribe to keyboard notifications
    [nc addObserver:self
           selector:@selector(notifyThatKeyboardWillAppear:)
               name:UIKeyboardWillShowNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(notifyThatKeyboardWillDisappear:)
               name:UIKeyboardWillHideNotification
             object:nil];
}

- (void) stopObservingKeyboard{
    // Unsuscribe from keyboard notifications
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}


- (void) notifyThatKeyboardWillAppear:(NSNotification *) notification{
    
    NSLog(@"fecha está en el (%f,%f)",self.modificationDateLabel.frame.origin.x, self.modificationDateLabel.frame.origin.y);
    NSLog(@"dimensiones textview: (%f,%f)", self.textView.frame.size.width, self.textView.frame.size.height);
    
    // Extract user info
    NSDictionary *dict = notification.userInfo;
    
    // Extract animation duration
    double duration = [[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    double xOffset = self.textView.frame.origin.x - self.modificationDateLabel.frame.origin.x;
    double yOffset = self.textView.frame.origin.y - self.modificationDateLabel.frame.origin.y;
    
    // Change uitextview properties => create an animation
    [UIView animateWithDuration:duration
                          delay:0
                        options:0
                     animations:^{
                         
                         for (UIView *each in self.view.subviews) {
                             CGFloat w = each.frame.size.width;
                             CGFloat h = each.frame.size.height;
                             CGRect newFrame = CGRectMake(each.frame.origin.x - xOffset, each.frame.origin.y - yOffset, w, h);
                             each.frame = newFrame;
                             
                             //each.frame.origin = CGPointMake(each.frame.origin.x - xOffset, each.frame.origin.y - yOffset);
                             //each.frame.origin.x = each.frame.origin.x - xOffset;
                         }
                         
                         // Change origin to modification date label
                         /*
                         self.textView.frame = CGRectMake(self.modificationDateLabel.frame.origin.x, self.modificationDateLabel.frame.origin.y, self.textView.frame.size.width, self.textView.frame.size.height);
                          */
                         
                        NSLog(@"nuevas dimensiones textview: (%f,%f)", self.textView.frame.origin.x, self.textView.frame.origin.y);
                         
                     } completion:nil];
    
    [UIView animateWithDuration:duration animations:^{
        // Textview with little transparency
        self.textView.alpha = 0.8;
    }];
}



- (void) notifyThatKeyboardWillDisappear:(NSNotification *) notification{
    // Extract user info
    //NSDictionary *dict = notification.userInfo;
}


/*
    Sets up a toolbar to place at the top of the keyboard when its appears
 */
- (void) setupInputAccessoryView{
    
    // Create toolbar
    UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    
    // Add smile, separator and done buttons
    UIBarButtonItem *separatorBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(dismissKeyboard:)];
    UIBarButtonItem *smileBtn = [[UIBarButtonItem alloc] initWithTitle:@";-)"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(insertTitle:)];
    
    // Set as accessoryInputView
    [bar setItems:@[smileBtn, separatorBtn, doneBtn]];
    self.textView.inputAccessoryView = bar;
}


// Dismiss keyboard when done button pressed
- (void) dismissKeyboard:(id) sender{
    [self.view endEditing:YES];
}

// Insert the title of the sender as text in the input view
- (void) insertTitle:(UIBarButtonItem *) sender{
    [self.textView insertText:[NSString stringWithFormat:@"%@ ", sender.title]];
}

@end
