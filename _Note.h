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

@class Notebook;

@interface NoteID : NamedEntityID {}
@end

@interface _Note : NamedEntity
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) NoteID *objectID;

@property (nonatomic, strong, nullable) NSString* text;

@property (nonatomic, strong) Notebook *notebook;

@end

@interface _Note (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;

- (Notebook*)primitiveNotebook;
- (void)setPrimitiveNotebook:(Notebook*)value;

@end

@interface NoteAttributes: NSObject 
+ (NSString *)text;
@end

@interface NoteRelationships: NSObject
+ (NSString *)notebook;
@end

NS_ASSUME_NONNULL_END
