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
#import "Notebook.h"

@interface NoteViewController () <UITextFieldDelegate>
@property (nonatomic, strong) Note *model;
@property (nonatomic) BOOL isNew;
@property (nonatomic) BOOL deleteCurrentNote;
@property (nonatomic) CGRect textViewOrigin;
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

// Create new empty notebook and then call the designated initializer
-(id) initForNewNoteInNotebook:(Notebook *) notebook{
    Note *newNote = [Note noteWithName:@"" notebook:notebook context:notebook.managedObjectContext];
    _isNew = YES;
    return [self initWithModel:newNote];
}


#pragma mark - View lifecycle
// Model -> View
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Sync changes from model to view
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateStyle = NSDateFormatterLongStyle;
    
    self.modificationDateLabel.text = [fmt stringFromDate:self.model.modificationDate];
    self.nameText.text = self.model.name;
    self.textView.text = self.model.text;
    
    UIImage *img = self.model.photo.image;
    if (img == nil) {
        img = [UIImage imageNamed:@"noImage.png"];
    }
    self.photoView.image = img;
    
    [self startObservingKeyboard];
    [self setupInputAccessoryView];
    
    // If this is a new note we need an edition mode to cancel (delete) the current note and pops the VC
    if (self.isNew) {
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                   target:self
                                                                                   action:@selector(cancelNote:)];
        self.navigationItem.rightBarButtonItem = cancelBtn;
    }
    
    
    self.textViewOrigin = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.frame.size.width, self.textView.frame.size.height);
    
    self.nameText.delegate = self;
}


-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (self.deleteCurrentNote) {
        // Delete note if we are in a new note
        [self.model.managedObjectContext deleteObject:self.model];
    }
    else{
        // Sync changes from view to model
        self.model.name = self.nameText.text;
        self.model.text = self.textView.text;
        self.model.photo.image = self.photoView.image;
    }
    
    [self stopObservingKeyboard];
}



#pragma mark - Utils
// Override this method to disable orientation changes when in login screen
-(BOOL) shouldAutorotate{
    return NO;
}


- (void) cancelNote:(id) sender{
    // Mark current note as "to be deleted" and pop VC
    self.deleteCurrentNote = YES;
    [self.navigationController popViewControllerAnimated:YES];
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
    
    // Move textview only for the description
    if ([self.textView isFirstResponder]) {
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
}



- (void) notifyThatKeyboardWillDisappear:(NSNotification *) notification{
    
    // Move textView along with keyboard animation
    if ([self.textView isFirstResponder]) {
        
        // Extract user info with duration
        NSDictionary *dict = notification.userInfo;
        double duration = [[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        // Change uitextview properties => create an animation
        [UIView animateWithDuration:duration
                              delay:0
                            options:0
                         animations:^{
                             
                              self.textView.frame = CGRectMake(self.textViewOrigin.origin.x, self.textViewOrigin.origin.y, self.view.frame.size.width, self.view.frame.size.height);
                              
                             
                         } completion:nil];
        
        [UIView animateWithDuration:duration animations:^{
            // Textview will be completely visible again
            self.textView.alpha = 1;
        }];
    }
}


/*
    Sets up a toolbar to place at the top of the keyboard when its appears
 */
- (void) setupInputAccessoryView{
    
    // Create toolbars for keyboard inputs
    UIToolbar *textViewBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.textView.frame.size.width, 44)];
    //UIToolbar *textFieldBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.textView.frame.size.width, 44)];
    
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
    [textViewBar setItems:@[smileBtn, separatorBtn, doneBtn]];
    //[textFieldBar setItems:@[separatorBtn, doneBtn]];
    self.textView.inputAccessoryView = textViewBar;
    //self.nameText.inputAccessoryView = textFieldBar;
}


// Dismiss keyboard when done button pressed
- (void) dismissKeyboard:(id) sender{
    [self.view endEditing:YES];
}

// Insert the title of the sender as text in the input view
- (void) insertTitle:(UIBarButtonItem *) sender{
    [self.textView insertText:[NSString stringWithFormat:@"%@ ", sender.title]];
}


#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    // Validate text
    
    // Hide keyboard
    [textField resignFirstResponder];
    return YES;
}

@end
