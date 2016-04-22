//
//  NotebooksViewController.m
//  Everpobre
//
//  Created by David de Tena on 22/04/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import "NotebooksViewController.h"
#import "Notebook.h"

@interface NotebooksViewController ()

@end

@implementation NotebooksViewController


#pragma mark - View lifecycle
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = @"Everpobre";
    
    // Setup navigation bar buttoms
    [self configureBarButtons];
}


#pragma mark - Data Source
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Find out the notebook in the NSFetchResultsController
    Notebook *nb = [self notebookAtIndexPath:indexPath];
    
    // Create a cell (reuse if exists)
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if(cell == nil){
        // Create a new one
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellId];
    }
    
    // Sync notebook data with cell (controller with view)
    cell.textLabel.text = nb.name;
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateStyle = NSDateFormatterMediumStyle;
    cell.detailTextLabel.text = [fmt stringFromDate:nb.modificationDate];
    
    
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

@end
