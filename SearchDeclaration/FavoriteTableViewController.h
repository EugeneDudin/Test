//
//  FavoriteTableViewController.h
//  SearchDeclaration
//
//  Created by Jenya on 10.06.18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "ManagedCoreData.h"

@interface FavoriteTableViewController : UITableViewController\
@property (strong)NSMutableArray *favoriteDB;
@property (strong, nonatomic)ManagedCoreData *managedCoreData;
@property (strong, nonatomic)UITextField *commentTF;
@property (strong, nonatomic)NSIndexPath *editCellIndexPath;


@end
