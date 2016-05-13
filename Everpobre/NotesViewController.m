//
//  NotesViewController.m
//  Everpobre
//
//  Created by David de Tena on 10/05/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import "Settings.h"
#import "NotesViewController.h"
#import "Note.h"
#import "NoteCellView.h"
#import "Photo.h"
#import "NoteViewController.h"

static NSString *cellId = @"NoteCellId";

@interface NotesViewController ()

@end

@implementation NotesViewController


#pragma mark - View lifecycle
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Register custom cell
    [self registerNib];
    
    // Setup UI
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    self.title = NOTES_COLLECTION_TITLE;
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
    [cell observeNote:note];        
    return cell;
}


#pragma mark - UICollectionView Delegate
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // Grab the note
    Note *note = [self noteAtIndexPath:indexPath];
    
    // New instance of NoteVC
    NoteViewController *noteVC = [[NoteViewController alloc] initWithModel:note];
    
    // Push
    [self.navigationController pushViewController:noteVC animated:YES];
}


#pragma mark - Utils
-(Note *) noteAtIndexPath:(NSIndexPath *)	indexPath{
    return (Note *) [self.fetchedResultsController objectAtIndexPath:indexPath];
}

@end