//
//  NoteTableViewController.h
//  Everpobre
//
//  Created by David de Tena on 17/05/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//
//  This VC displays a note detail in a table instead a normal VC

#import <UIKit/UIKit.h>
#import "DetailViewController.h"
@class Note;
@class Notebook;

@interface NoteTableViewController : UITableViewController<DetailViewController, UITextFieldDelegate>

#pragma mark - Init
-(id) initForNewNoteInNotebook:(Notebook *) notebook;

@end