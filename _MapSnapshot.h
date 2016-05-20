// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MapSnapshot.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class Location;

@interface MapSnapshotID : NSManagedObjectID {}
@end

@interface _MapSnapshot : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MapSnapshotID *objectID;

@property (nonatomic, strong) NSData* snapshotData;

@property (nonatomic, strong) Location *location;

@end

@interface _MapSnapshot (CoreDataGeneratedPrimitiveAccessors)

- (NSData*)primitiveSnapshotData;
- (void)setPrimitiveSnapshotData:(NSData*)value;

- (Location*)primitiveLocation;
- (void)setPrimitiveLocation:(Location*)value;

@end

@interface MapSnapshotAttributes: NSObject 
+ (NSString *)snapshotData;
@end

@interface MapSnapshotRelationships: NSObject
+ (NSString *)location;
@end

NS_ASSUME_NONNULL_END
