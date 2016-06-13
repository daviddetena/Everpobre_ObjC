//
//  NoteTableViewController.m
//  Everpobre
//
//  Created by David de Tena on 17/05/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import "NoteTableViewController.h"
#import "PhotoViewController.h"
#import "LocationViewController.h"
#import "Note.h"
#import "Notebook.h"
#import "Photo.h"
#import "Location.h"
#import "MapSnapshot.h"
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
@property (strong, nonatomic) IBOutlet UITableViewCell *deleteNoteCell;

@property (weak, nonatomic) IBOutlet UILabel *modificationDateLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIImageView *mapSnapshotView;
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
    Note *newNote = [Note noteWithName:@"New note"
                              notebook:notebook
                               context:notebook.managedObjectContext];
    _isNew = YES;
    return [self initWithModel:newNote];
}


#pragma mark - View lifecycle
// Model -> View
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Setup navigation bar buttons
    [self setupNavigationButtons];
    // Setup UI elements
    [self setupUIText];
    [self setupUIPhoto];
    [self setupMapSnapshot];
    
    // Observe mapsnapshot, in case it changes in the background it may appear after, so its image will be refreshed
    [self startObservingSnapshot];
    
    // Custom toolbar for keyboard input
    [self setupToolBarForKeyboard];
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
        
        // Enhancement: in case the location could be modified, here we should sync changes
    }
    
    [self stopObservingSnapshot];
}


#pragma mark - Utils

-(BOOL) noteHasLocation{
    return (self.model.location.mapSnapshot.image != nil);
}


// Add two buttons in the navigation bar
-(void) setupNavigationButtons{
    
    // Right button will be "cancel" if it's been created or "activity" otherwise
    
    // Add button for sharing note
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                 target:self
                                                                                 action:@selector(displayShareController:)];
    
    // If this is a new note we need an edition mode to cancel (delete) the current note and pops the VC
    if (self.isNew) {
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                   target:self
                                                                                   action:@selector(cancelNote:)];
        self.navigationItem.rightBarButtonItem = cancelBtn;
    }
    else{
        self.navigationItem.rightBarButtonItem = shareButton;
    }
}

-(void) setupUIText{
    
    // Set content for the labels and text views
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateStyle = NSDateFormatterLongStyle;
    
    self.modificationDateLabel.text = [fmt stringFromDate:self.model.modificationDate];
    self.nameTextField.text = self.model.name;
    self.textView.text = self.model.text;
    
    // Set textfield delegate
    self.nameTextField.delegate = self;
}

// This method presents a modal for confirming the deletion of the current note
- (void) presentConfirmDeletingAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete note?"
                                                                   message:@"This action can not be undone"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Yes, delete"
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [self cancelNote:self];
                                                   }];;
    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
    [self presentViewController:alert animated:YES completion:nil];
}


-(void) setupUIPhoto{
    // Image
    UIImage *img = self.model.photo.image;
    if (!img) {
        img = [UIImage imageNamed:@"noImage.png"];
    }
    self.photoView.image = img;
}


// Setup Map snapshot with the location in the model
-(void) setupMapSnapshot{
    
    UIImage *img = self.model.location.mapSnapshot.image;
    self.mapSnapshotView.userInteractionEnabled = YES;
    if (!img) {
        img = [UIImage imageNamed:@"noSnapshot.png"];
        self.mapSnapshotView.userInteractionEnabled = NO;
    }
    self.mapSnapshotView.image = img;
}


- (void) setupGestureRecognizers{
    // Add gesture recognizer for displaying PhotoVC when tapping the image    
    self.photoView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(displayDetailPhoto:)];
    
    tap.cancelsTouchesInView = NO;
    [self.photoView addGestureRecognizer:tap];
    
    self.mapSnapshotView.userInteractionEnabled = YES;
    UITapGestureRecognizer *secondTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(displayDetailLocation:)];
    
    secondTap.cancelsTouchesInView = NO;
    [self.mapSnapshotView addGestureRecognizer:secondTap];
}



// Override this method to disable orientation changes when in login screen
-(BOOL) shouldAutorotate{
    return NO;
}



// Helper method that composes an array with the objects we want the UIActivityVC to display when sharing the note
- (NSArray *) arrayOfNoteItems{
    
    // We want to share name, text and image
    NSMutableArray *items = [NSMutableArray array];
    
    if (self.model.name) {
        [items addObject:self.model.name];
    }
    
    if (self.model.text) {
        [items addObject:self.model.text];
    }
    
    if (self.model.photo.image) {
        [items addObject:self.model.photo.image];
    }
    
    return items;
}


#pragma mark - KVO
-(void) startObservingSnapshot{
    [self.model addObserver:self
                 forKeyPath:@"location.mapSnapshot.snapshotData"
                    options:NSKeyValueObservingOptionNew context:NULL];
}

-(void) stopObservingSnapshot{
    [self.model removeObserver:self
                    forKeyPath:@"location.mapSnapshot.snapshotData"];
}

-(void) observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context{
    
    // Refresh Map's Snapshot with changes
    [self setupMapSnapshot];
}


#pragma mark - Actions

// Present PhotoVC
- (void) displayDetailPhoto:(id) sender{
    // Make sure a photo (even empty) is passed through
    if (self.model.photo == nil) {
        self.model.photo = [Photo photoWithImage:nil context:self.model.managedObjectContext];
    }
    PhotoViewController *photoVC = [[PhotoViewController alloc]
                                    initWithModel:self.model.photo];
    
    [self.navigationController pushViewController:photoVC animated:YES];
}

// Present LocationVC
- (void) displayDetailLocation:(id) sender{    
    LocationViewController *locationVC = [[LocationViewController alloc] initWithLocation:self.model.location];
    [self.navigationController pushViewController:locationVC animated:YES];
}


// Displays a UIActivityViewController
-(void) displayShareController:(id) sender{
    
    UIActivityViewController *aVC = [[UIActivityViewController alloc] initWithActivityItems:[self arrayOfNoteItems]
                                                                      applicationActivities:nil];
    
    [self presentViewController:aVC animated:YES completion:nil];
}

// When we press "cancel" button, set note as "to be deleted" when viewWillDisappear is called
- (void) cancelNote:(id) sender{
    // Mark current note as "to be deleted" and pop VC
    self.deleteCurrentNote = YES;
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - Keyboard
/*
 Sets up a toolbar to place at the top of the keyboard when its appears
 */
- (void) setupToolBarForKeyboard{
    
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

// Insert the title of the sender as text in the input view
- (void) insertTitle:(UIBarButtonItem *) sender{
    [self.textView insertText:[NSString stringWithFormat:@"%@ ", sender.title]];
}



#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isNew){
        return 4;
    }
    return 5;
}

// Each cell in the xib file has its own size
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        
        if (self.isNew){
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
        else{
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
                    
                    // Delete note cell
                case 4:
                    return self.deleteNoteCell.frame.size.height;
                    break;
                    
                default:
                    return 0.0f;
            }
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
                
            // Photo & map cell. Setup recognizers
            case 2:
                cell = self.photoAndMapCell;
                // Custom recognizers for the photoViews
                [self setupGestureRecognizers];
                break;
                
            // Text cell
            case 3:
                cell = self.textCell;
                break;
                
            // Delete note cell
            case 4:
                cell = self.deleteNoteCell;
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
    
    // If we pressed "delete" we mark as "to be deleted"
    if (indexPath.row == 4) {
        [self presentConfirmDeletingAlert];
        //[self cancelNote:self];
    }
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
