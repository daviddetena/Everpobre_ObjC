//
//  NotesViewController.h
//  Everpobre
//
//  Created by David de Tena on 10/05/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import "AGTCoreDataCollectionViewController.h"
@class Notebook;

@interface NotesViewController : AGTCoreDataCollectionViewController

#pragma mark - Properties
@property(nonatomic, strong) Notebook *notebook;

@end
