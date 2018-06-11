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

@interface FavoriteTableViewController : UITableViewController

@property (strong, nonatomic)AppDelegate *delegate;
@property (strong)NSMutableArray *favoriteDB;

@end
