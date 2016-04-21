// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Photo.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class Note;

@interface PhotoID : NSManagedObjectID {}
@end

@interface _Photo : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) PhotoID *objectID;

@property (nonatomic, strong) NSData* imageData;

@property (nonatomic, strong, nullable) Note *notes;

@end

@interface _Photo (CoreDataGeneratedPrimitiveAccessors)

- (NSData*)primitiveImageData;
- (void)setPrimitiveImageData:(NSData*)value;

- (Note*)primitiveNotes;
- (void)setPrimitiveNotes:(Note*)value;

@end

@interface PhotoAttributes: NSObject 
+ (NSString *)imageData;
@end

@interface PhotoRelationships: NSObject
+ (NSString *)notes;
@end

NS_ASSUME_NONNULL_END
