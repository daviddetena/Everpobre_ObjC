//
//  AGTCoreDataCollectionViewController.h
//  CoreDataTest
//
//  Created by Fernando Rodríguez Romero on 16/06/14.
//  Copyright (c) 2014 Agbo. All rights reserved.
//  Forked form Ash Furrows AFMasterViewController
//  https://github.com/AshFurrow/UICollectionView-NSFetchedResultsController
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
@interface AGTCoreDataCollectionViewController : UICollectionViewController

#pragma mark - Properties
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSString *detailViewControllerClassName;

#pragma mark - Methods
+(instancetype) coreDataCollectionViewControllerWithFetchedResultsController:(NSFetchedResultsController *) resultsController
                                                                      layout:(UICollectionViewLayout*) layout;

-(id) initWithFetchedResultsController:(NSFetchedResultsController *) resultsController
                                layout:(UICollectionViewLayout*) layout;

@end
