//
//  NotebookCellView.h
//  Everpobre
//
//  Created by David de Tena on 22/04/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotebookCellView : UITableViewCell


#pragma mark - Properties
@property (nonatomic, strong) IBOutlet UILabel *nameView;
@property (nonatomic, strong) IBOutlet UILabel *numberOfNotesView;


#pragma mark - Class methods
// Cell identifier and cell height necessary for the TableView
+(NSString *) cellId;
+(CGFloat) cellHeight;


@end
