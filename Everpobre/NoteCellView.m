//
//  NoteCellView.m
//  Everpobre
//
//  Created by David de Tena on 09/05/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import "NoteCellView.h"
#import "Note.h"
#import "Photo.h"

@interface NoteCellView ()
@property (strong, nonatomic) Note *note;       // Current note to observe
@end

@implementation NoteCellView

#pragma mark - Class methods
+(NSArray *) keys{
    return @[@"title", @"modificationDate", @"photo.image"];
}


#pragma mark - Instance methods
- (void) observeNote: (Note *) note{

    // Save property
    self.note = note;
    
    // Observe changes in note properties that appear in our cell view
    for (NSString *key in [NoteCellView keys]) {
        [self.note addObserver:self
                    forKeyPath:key
                       options:NSKeyValueObservingOptionNew
                       context:NULL];
    }
    // Refresh UI
    [self syncNoteWithView];
}

#pragma mark - View
- (void) prepareForReuse{
    self.note = nil;
    [self syncNoteWithView];
}


#pragma mark - Utils
// Make the changes appear in the UI (the properties we observe)
- (void) syncNoteWithView{
    // Configure cell (sync model and view)
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    
    self.titleLabel.text = self.note.name;
    self.modificationDateLabel.text = [formatter stringFromDate:self.note.modificationDate];
    
    UIImage *img;
    
    if (self.note.photo.image == nil) {
        // Load default image
        img = [UIImage imageNamed:@"noImage.png"];
    }
    else{
        img = self.note.photo.image;
    }
    self.photoView.image = img;
}


#pragma mark - KVO
// Make changes in the UI when changes in observable keys occur
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary<NSString *,id> *)change
                        context:(void *)context{
    
    // Update UI
    [self syncNoteWithView];
}

@end
