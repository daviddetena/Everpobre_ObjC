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
}


#pragma mark - Data Source
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Find out the notebook in the NSFetchResultsController
    Notebook *nb = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
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


@end
