// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Notebook.m instead.

#import "_Notebook.h"

@implementation NotebookID
@end

@implementation _Notebook

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Notebook" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Notebook";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Notebook" inManagedObjectContext:moc_];
}

- (NotebookID*)objectID {
	return (NotebookID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic notes;

- (NSMutableSet<Note*>*)notesSet {
	[self willAccessValueForKey:@"notes"];

	NSMutableSet<Note*> *result = (NSMutableSet<Note*>*)[self mutableSetValueForKey:@"notes"];

	[self didAccessValueForKey:@"notes"];
	return result;
}

@end

@implementation NotebookRelationships 
+ (NSString *)notes {
	return @"notes";
}
@end

