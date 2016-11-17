//
//  NoteCellView.h
//  Everpobre
//
//  Created by David de Tena on 09/05/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//
//  In this case we ignore MVC pattern and let the view know
//  about the model. In such a simple and specific case, we
//  let the cell view know about every change on the model.
//  We need to use the prepareForReuse method to stop observing
//  model changes

#import <UIKit/UIKit.h>
@class Note;

@interface NoteCellView : UICollectionViewCell

#pragma mark - Properties

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *modificationDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *locationView;


#pragma mark - Methods
- (void) observeNote: (Note *) note;

@end
