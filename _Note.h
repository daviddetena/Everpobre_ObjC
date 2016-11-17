// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Note.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

#import "NamedEntity.h"

NS_ASSUME_NONNULL_BEGIN

@class Location;
@class Notebook;
@class Photo;

@interface NoteID : NamedEntityID {}
@end

@interface _Note : NamedEntity
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) NoteID *objectID;

@property (nonatomic, strong, nullable) NSString* text;

@property (nonatomic, strong, nullable) Location *location;

@property (nonatomic, strong) Notebook *notebook;

@property (nonatomic, strong, nullable) Photo *photo;

@end

@interface _Note (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;

- (Location*)primitiveLocation;
- (void)setPrimitiveLocation:(Location*)value;

- (Notebook*)primitiveNotebook;
- (void)setPrimitiveNotebook:(Notebook*)value;

- (Photo*)primitivePhoto;
- (void)setPrimitivePhoto:(Photo*)value;

@end

@interface NoteAttributes: NSObject 
+ (NSString *)text;
@end

@interface NoteRelationships: NSObject
+ (NSString *)location;
+ (NSString *)notebook;
+ (NSString *)photo;
@end

NS_ASSUME_NONNULL_END
