//
//  AppDelegate.m
//  Everpobre
//
//  Created by David de Tena on 20/04/16.
//  Copyright © 2016 David de Tena. All rights reserved.
//

#import "AppDelegate.h"
#import "AGTCoreDataStack.h"
#import "Note.h"
#import "Notebook.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Create a CoreDataStack intance with Model.sqlite saved to Documents folder
    self.model = [AGTCoreDataStack coreDataStackWithModelName:@"Model"];
    
    [self playWithData];
    [self autoSave];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    // A good moment to save is when just stop receiving user touches
    [self save];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // A good moment to save is when just entered background
    [self save];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    NSLog(@"Good bye, cruel world!");
}



#pragma mark - Utils

- (void)playWithData{
    
    // Create a notebook
    Notebook *notebook = [Notebook notebookWithName:@"GOTY games"
                                            context:self.model.context];
    
    [Note noteWithName:@"The Last Of Us Remastered"
                            notebook:notebook
                             context:self.model.context];
    
    [Note noteWithName:@"Uncharted 4"
                            notebook:notebook
                             context:self.model.context];
    
    // Search
    // NSFetchRequest. Search Notes
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[Note entityName]];
    
    // Sorting by name ASC, modificationDate DESC
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:NamedEntityAttributes.name
                                                              ascending:YES],
                                [NSSortDescriptor sortDescriptorWithKey:NamedEntityAttributes.modificationDate
                                                              ascending:NO]];
    
    NSError *error;
    NSArray *results = [self.model.context executeFetchRequest:request error:&error];
    
    if(results == nil){
        NSLog(@"Error when saving: %@", error);
    }
    else{
        NSLog(@"Found %lu item(s)", (unsigned long)[results count]);
    }
    
    // Save
    [self save];
}


// Save to disk
- (void)save{
    
    [self.model saveWithErrorBlock:^(NSError *error) {
        NSLog(@"Error when saving to disk: %s \n\n %@", __func__, error);
    }];
}

- (void)autoSave{
    NSLog(@"Saving automatically...");
    [self save];
    
    // Recursive call with a delay
    [self performSelector:@selector(autoSave) withObject:nil afterDelay:2];
}

@end
