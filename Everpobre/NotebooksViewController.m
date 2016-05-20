//
//  NotebooksViewController.m
//  Everpobre
//
//  Created by David de Tena on 22/04/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import "NotebooksViewController.h"
#import "Notebook.h"
#import "NotebookCellView.h"
#import "NotesViewController.h"
#import "Note.h"

@interface NotebooksViewController ()

@end

@implementation NotebooksViewController


#pragma mark - View lifecycle

// Setup UI when it's about to be displayed
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = @"Everpobre";
    
    // Setup navigation bar buttoms
    [self configureBarButtons];
    
    // Suscribe to proximity sensor notitications
    [self setupProximitySensorNotifications];
    
    // Register nib for custom cell
    UINib *cellNib = [UINib nibWithNibName:@"NotebookCellView" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:[NotebookCellView cellId]];
}


- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // Unsuscribe from proximity sensor notifications
    [self tearDownProximitySensorNotifications];
}


#pragma mark - Data Source
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Find out the notebook in the NSFetchResultsController
    Notebook *nb = [self notebookAtIndexPath:indexPath];
    
    // Grab custom cell (reuse if exists)
    NotebookCellView *cell = [tableView dequeueReusableCellWithIdentifier:[NotebookCellView cellId]];
    
    // Sync notebook data with cell (controller with view)
    cell.nameView.text = nb.name;
    cell.numberOfNotesView.text = [NSString stringWithFormat:@"%lu", nb.notes.count];
    
    // Return the cell
    return cell;
}


// Enable editing mode
- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // If deletion mode, get notebook and remove
    if(editingStyle == UITableViewCellEditingStyleDelete){
        Notebook *nb = [self notebookAtIndexPath:indexPath];
        [self.fetchedResultsController.managedObjectContext deleteObject:nb];
    }
}



#pragma mark - TableView Delegate
// Custom cell height
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [NotebookCellView cellHeight];
}

// Tapping a notebook will present a collection view with its notes
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    // Create fetch request. Sort by note name ASC, modification date DESC, creation date DESC
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:[Note entityName]];
    req.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:NamedEntityAttributes.name ascending:YES],
                            [NSSortDescriptor sortDescriptorWithKey:NamedEntityAttributes.modificationDate ascending:NO],
                            [NSSortDescriptor sortDescriptorWithKey:NamedEntityAttributes.creationDate ascending:NO]];
    
    // NSPredicate to filter the results
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"notebook == %@", [self notebookAtIndexPath:indexPath]];
    req.predicate = predicate;
    
    // Optimize Core Data by fetching a set of results instead of all that match the predicate
    // A good rule is to fetch aboute twice the elements that are displayed
    req.fetchBatchSize = 20;
    
    // Create fetchedResultsController
    NSFetchedResultsController *fetchedRC = [[NSFetchedResultsController alloc]initWithFetchRequest:req
                                                                               managedObjectContext:self.fetchedResultsController.managedObjectContext sectionNameKeyPath:nil
                                                                                          cacheName:nil];
    // Layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(140, 150);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    // Create notes controller
    NotesViewController *notesVC = [NotesViewController coreDataCollectionViewControllerWithFetchedResultsController:fetchedRC
                                                                                                               layout:layout];
    
    // Set notebook for the note
    notesVC.notebook = [self notebookAtIndexPath:indexPath];
    
    // Push controller
    [self.navigationController pushViewController:notesVC
                                         animated:YES];
    
}



#pragma mark - Utils

// Object at index X from the NSFetchedResultsController
- (Notebook *) notebookAtIndexPath:(NSIndexPath *) indexPath{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void) configureBarButtons{
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(addNotebook:)];
    
    // Add button to navigation bar
    self.navigationItem.rightBarButtonItem = addButton;
    
    // Add Editing button on the left
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}


#pragma mark - Actions
- (void) addNotebook:(id) sender{
    
    // Create a new Notebook instance and TableView will be refreshed automatically (see AGTCoreDataTableViewController)
    [Notebook notebookWithName:@"New Notebook" context:self.fetchedResultsController.managedObjectContext];
}


#pragma mark - Proximity Sensor

// Check if the device has a proximity sensor
- (BOOL) hasProximitySensor{
    
    UIDevice *device = [UIDevice currentDevice];
    BOOL oldValue = [device isProximityMonitoringEnabled];
    [device setProximityMonitoringEnabled:!oldValue];
    BOOL newValue = [device isProximityMonitoringEnabled];
    [device setProximityMonitoringEnabled:oldValue];
    
    return (oldValue != newValue);
}


// Suscribe to changes in proximity sensor
- (void) setupProximitySensorNotifications{
    
    UIDevice *device = [UIDevice currentDevice];
    
    // Start monitoring changes in Proximity Sensor
    if([self hasProximitySensor]){
        NSLog(@"The device has proximity sensor");
        [device setProximityMonitoringEnabled:YES];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(proximityStateDidChange:)
                       name:UIDeviceProximityStateDidChangeNotification
                     object:nil];
    }
    else{
        NSLog(@"The device has not proximity sensor");
    }
}


// Unsuscribe from changes in proximity sensor
- (void) tearDownProximitySensorNotifications{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}


// UIDeviceProximityStateDidChangeNotification
- (void) proximityStateDidChange:(NSNotification *) notification{
    [self presentUndoRedoAlertController];
}

@end
