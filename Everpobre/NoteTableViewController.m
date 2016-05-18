//
//  NoteTableViewController.m
//  Everpobre
//
//  Created by David de Tena on 17/05/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import "NoteTableViewController.h"
#import "Note.h"
#import "Notebook.h"
#import "Photo.h"
#import <MapKit/MapKit.h>

@interface NoteTableViewController ()

#pragma mark - Properties

@property (nonatomic) BOOL isNew;
@property (nonatomic) BOOL deleteCurrentNote;

@property (nonatomic, strong) Note *model;

// Cells and IBOutlets
@property (strong, nonatomic) IBOutlet UITableViewCell *modificationDateCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *photoAndMapCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *textCell;

@property (weak, nonatomic) IBOutlet UILabel *modificationDateLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextView *textView;


@end

@implementation NoteTableViewController


#pragma mark - Init
-(id) initWithModel:(id) model{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        _model = model;
        self.title = self.model.name;
    }
    return self;
}


// Create new empty notebook and then call the designated initializer
-(id) initForNewNoteInNotebook:(Notebook *) notebook{
    Note *newNote = [Note noteWithName:@"New note" notebook:notebook context:notebook.managedObjectContext];
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
    self.nameTextField.text = self.model.name;
    self.textView.text = self.model.text;
    
    UIImage *img = self.model.photo.image;
    if (img == nil) {
        img = [UIImage imageNamed:@"noImage.png"];
    }
    self.photoView.image = img;
    [self setupInputAccessoryView];
    
    // If this is a new note we need an edition mode to cancel (delete) the current note and pops the VC
    if (self.isNew) {
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                   target:self
                                                                                   action:@selector(cancelNote:)];
        self.navigationItem.rightBarButtonItem = cancelBtn;
    }
    
    
    // Set delegates
    self.nameTextField.delegate = self;
    
    // Add gesture recognizer for displaying PhotoVC when tapping the image
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(displayDetailPhoto:)];
    
    [self.photoView addGestureRecognizer:tap];
}


-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (self.deleteCurrentNote) {
        // Delete note if we are in a new note
        [self.model.managedObjectContext deleteObject:self.model];
    }
    else{
        // Sync changes from view to model
        self.model.name = self.nameTextField.text;
        self.model.text = self.textView.text;
        self.model.photo.image = self.photoView.image;
    }
    
    //[self stopObservingKeyboard];
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


#pragma mark - Actions

// Present PhotoVC
- (void) displayDetailPhoto:(id) sender{
    NSLog(@"hello");
}


#pragma mark - Keyboard
/*
 Sets up a toolbar to place at the top of the keyboard when its appears
 */
- (void) setupInputAccessoryView{
    
    UIToolbar *textViewBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.textView.frame.size.width, 44)];
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
    self.textView.inputAccessoryView = textViewBar;
}


// Dismiss keyboard when done button pressed
- (void) dismissKeyboard:(id) sender{
    [self.view endEditing:YES];
}



#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

// Each cell in the xib file has its own size
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            // Modification date cell
            case 0:
                return self.modificationDateCell.frame.size.height;
                break;
                
            // Name cell
            case 1:
                return self.nameCell.frame.size.height;
                break;
                
            // Photo & map cell
            case 2:
                return self.photoAndMapCell.frame.size.height;
                break;
                
            // Text cell
            case 3:
                return self.textCell.frame.size.height;
                break;
                
            default:
                return 0.0f;
        }
    }
    return 30.0f;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            
            // Modification date cell
            case 0:
                cell = self.modificationDateCell;
                break;
            
            // Name cell
            case 1:
                cell = self.nameCell;
                break;
                
            // Photo & map cell
            case 2:
                cell = self.photoAndMapCell;
                break;
                
            // Text cell
            case 3:
                cell = self.textCell;
                break;
                
            default:
                break;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UITextFieldDelegate

// What to do if return key pressed
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    // If name is not empty, hide the keyboard
    if (textField.text.length > 0) {
        [textField resignFirstResponder];
        return YES;
    }
    return NO;
}

- (void) textFieldDidEndEditing:(UITextField *)textField{
    // Refresh title with the new name
    self.title = textField.text;
}


@end
