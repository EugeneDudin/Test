//
//  ManagedCoreData.h
//  SearchDeclaration
//
//  Created by Jenya on 6/12/18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import <CoreData/CoreData.h>

@interface ManagedCoreData : NSObject

@property (strong, nonatomic)NSManagedObjectContext *context;
@property (strong, nonatomic)NSFetchRequest *fetchRequest;

- (BOOL)addData:(NSDictionary *)data;
- (NSMutableArray *)getData;
- (BOOL)updateDataAtIndex:(NSInteger)index newValue:(NSString *)value forKey:(NSString *)key;
- (BOOL)deleteDataForIndex:(NSInteger)index;

@end
