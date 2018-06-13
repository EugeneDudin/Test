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
    if ([self error:@"Add"]) {
        return false;
    }
    return true;
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
    if ([self error:@"Save"]) {
        return false;
    }
    return true;
}

- (BOOL)deleteDataForIndex:(NSInteger)index {
    NSArray *array = [[NSArray alloc] initWithArray:[self getData]];
    [self.context deleteObject:[array objectAtIndex:index]];
    if ([self error:@"Delete"]) {
        return false;
    }
    return true;
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
