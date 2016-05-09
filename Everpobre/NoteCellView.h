//
//  NoteCellView.h
//  Everpobre
//
//  Created by David de Tena on 09/05/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteCellView : UICollectionViewCell

#pragma mark - Properties

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *modificationDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
