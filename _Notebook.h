// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Notebook.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

#import "NamedEntity.h"

NS_ASSUME_NONNULL_BEGIN

@class Note;

@interface NotebookID : NamedEntityID {}
@end

@interface _Notebook : NamedEntity
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) NotebookID *objectID;

@property (nonatomic, strong, nullable) NSSet<Note*> *notes;
- (nullable NSMutableSet<Note*>*)notesSet;

@end

@interface _Notebook (NotesCoreDataGeneratedAccessors)
- (void)addNotes:(NSSet<Note*>*)value_;
- (void)removeNotes:(NSSet<Note*>*)value_;
- (void)addNotesObject:(Note*)value_;
- (void)removeNotesObject:(Note*)value_;

@end

@interface _Notebook (CoreDataGeneratedPrimitiveAccessors)

- (NSMutableSet<Note*>*)primitiveNotes;
- (void)setPrimitiveNotes:(NSMutableSet<Note*>*)value;

@end

@interface NotebookRelationships: NSObject
+ (NSString *)notes;
@end

NS_ASSUME_NONNULL_END
