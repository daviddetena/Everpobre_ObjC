//
//  AppDelegate.h
//  Everpobre
//
//  Created by David de Tena on 20/04/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AGTCoreDataStack;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) AGTCoreDataStack *model;

@end

