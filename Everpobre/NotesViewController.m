//
//  NotesViewController.m
//  Everpobre
//
//  Created by David de Tena on 10/05/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import "NotesViewController.h"
#import "Note.h"
#import "NoteCellView.h"
#import "Photo.h"

static NSString *cellId = @"NoteCellId";

@interface NotesViewController ()

@end

@implementation NotesViewController


#pragma mark - View lifecycle
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Register custom cell
    [self registerNib];
}


#pragma mark - Xib registration
- (void) registerNib{
    UINib *nib = [UINib nibWithNibName:@"NoteCollectionCellView"
                                bundle:nil];
    
    [self.collectionView registerNib:nib
          forCellWithReuseIdentifier:cellId];
}


#pragma mark - Data source
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // Get note
    Note *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Get cell
    NoteCellView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId
                                                                   forIndexPath:indexPath];
    
    // Configure cell (sync model and view)
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    
    cell.titleLabel.text = note.name;
    cell.photoView.image = note.photo.image;
    cell.modificationDateLabel.text = [formatter stringFromDate:note.modificationDate];
    
    return cell;
}

@end