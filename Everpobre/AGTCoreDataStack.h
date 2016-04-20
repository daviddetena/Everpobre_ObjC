//
//  AGTCoreDataStack.h
//
//  Created by Fernando Rodríguez Romero on 1/24/13.
//  Copyright (c) 2013 Agbo. All rights reserved.
//
//  Thanks to Fernando Rodríguez (@frr149) for his Core Data Stack ;-)
//

@import Foundation;
@import CoreData;

@class NSManagedObjectContext;

@interface AGTCoreDataStack : NSObject

@property (strong, nonatomic, readonly) NSManagedObjectContext *context;

+(NSString *) persistentStoreCoordinatorErrorNotificationName;

+(AGTCoreDataStack *) coreDataStackWithModelName:(NSString *)aModelName
                               databaseFilename:(NSString*) aDBName;

+(AGTCoreDataStack *) coreDataStackWithModelName:(NSString *)aModelName;

+(AGTCoreDataStack *) coreDataStackWithModelName:(NSString *)aModelName
                                    databaseURL:(NSURL*) aDBURL;

-(id) initWithModelName:(NSString *)aModelName
            databaseURL:(NSURL*) aDBURL;

-(void) zapAllData;

-(void) saveWithErrorBlock: (void(^)(NSError *error))errorBlock;

-(NSArray *) executeFetchRequest:(NSFetchRequest *)req
                      errorBlock:(void(^)(NSError *error)) errorBlock;


@end
