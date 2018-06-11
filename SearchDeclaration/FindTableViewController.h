//
//  FindTableViewController.h
//  FindDec
//
//  Created by Jenya on 10/8/18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <CoreData/CoreData.h>

@interface FindTableViewController : UITableViewController<UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong) NSManagedObject *favoritbd;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@end
