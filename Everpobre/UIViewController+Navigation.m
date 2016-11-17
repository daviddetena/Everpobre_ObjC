//
//  UIViewController+Navigation.m
//  Everpobre
//
//  Created by David de Tena on 22/04/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import "UIViewController+Navigation.h"

@implementation UIViewController (Navigation)


- (UINavigationController *) wrappedInNavigation{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
    return nav;
}

@end
