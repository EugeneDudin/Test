//
//  ManagedCoreData.m
//  SearchDeclaration
//
//  Created by Jenya on 6/12/18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import "ManagedCoreData.h"

@implementation ManagedCoreData

static NSString *const BDName = @"Favorite";

-(id)init {
    self = [super init];
    if (self) {
        self.context = [self managedObjectContext];
        self.fetchRequest = [[NSFetchRequest alloc] initWithEntityName:BDName];
    }
    return self;
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (BOOL)addData:(NSDictionary *)data {
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:BDName inManagedObjectContext:self.context];
    for (NSString *aKey in data.allKeys) {
        [managedObject setValue:[data valueForKey:aKey] forKey:aKey];
    }
    return [self error:@"ADD"];
}

- (NSMutableArray *)getData {
    NSMutableArray *data = [[[self managedObjectContext] executeFetchRequest:self.fetchRequest error:nil] mutableCopy];
    return data;
}

- (BOOL)updateDataAtIndex:(NSInteger)index newValue:(NSString *)value forKey:(NSString *)key {
    NSArray *array = [[NSArray alloc] initWithArray:[self getData]];
    NSManagedObject *selectedData = [array objectAtIndex:index];
    
    if (selectedData) {
        [selectedData setValue:value forKey:key];
    }
    
    return [self error:@"Save"];
}

- (BOOL)deleteDataForIndex:(NSInteger)index {
    NSArray *array = [[NSArray alloc] initWithArray:[self getData]];
    [self.context deleteObject:[array objectAtIndex:index]];
    
    return [self error:@"Delete"];
}

- (BOOL)removeDataByID:(NSString *)personID {
    NSEntityDescription *entity = [NSEntityDescription entityForName:BDName inManagedObjectContext:_context];
    
    [_fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", personID];
    [_fetchRequest setPredicate: predicate];
    NSError *error;
    NSArray *array = [_context executeFetchRequest:_fetchRequest error:&error];
    if ([array firstObject] != nil) {
        [self.context deleteObject:[array firstObject]];
    }
    return [self error:@"DELETE"];
}

- (BOOL)error:(NSString *)name {
    NSError *error = nil;
    // Save the object to persistent store
    if (![self.context save:&error]) {
        NSLog(@"Can't %@! %@ %@", name, error, [error localizedDescription]);
        return false;
    }
    return true;
}

@end
