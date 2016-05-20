// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Location.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class MapSnapshot;
@class Note;

@interface LocationID : NSManagedObjectID {}
@end

@interface _Location : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) LocationID *objectID;

@property (nonatomic, strong, nullable) NSString* address;

@property (nonatomic, strong, nullable) NSNumber* latitude;

@property (atomic) double latitudeValue;
- (double)latitudeValue;
- (void)setLatitudeValue:(double)value_;

@property (nonatomic, strong, nullable) NSNumber* longitude;

@property (atomic) double longitudeValue;
- (double)longitudeValue;
- (void)setLongitudeValue:(double)value_;

@property (nonatomic, strong, nullable) MapSnapshot *mapSnapshot;

@property (nonatomic, strong) NSSet<Note*> *notes;
- (NSMutableSet<Note*>*)notesSet;

@end

@interface _Location (NotesCoreDataGeneratedAccessors)
- (void)addNotes:(NSSet<Note*>*)value_;
- (void)removeNotes:(NSSet<Note*>*)value_;
- (void)addNotesObject:(Note*)value_;
- (void)removeNotesObject:(Note*)value_;

@end

@interface _Location (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAddress;
- (void)setPrimitiveAddress:(NSString*)value;

- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (double)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(double)value_;

- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;

- (MapSnapshot*)primitiveMapSnapshot;
- (void)setPrimitiveMapSnapshot:(MapSnapshot*)value;

- (NSMutableSet<Note*>*)primitiveNotes;
- (void)setPrimitiveNotes:(NSMutableSet<Note*>*)value;

@end

@interface LocationAttributes: NSObject 
+ (NSString *)address;
+ (NSString *)latitude;
+ (NSString *)longitude;
@end

@interface LocationRelationships: NSObject
+ (NSString *)mapSnapshot;
+ (NSString *)notes;
@end

NS_ASSUME_NONNULL_END
