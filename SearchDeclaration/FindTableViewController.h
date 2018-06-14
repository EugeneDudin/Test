//
//  FindTableViewController.h
//  FindDec
//
//  Created by Jenya on 10/8/18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ManagedCoreData.h"
#import "Alert.h"

@interface FindTableViewController : UITableViewController<UISearchBarDelegate, UITextFieldDelegate, AlertDelegate>

@property (strong, nonatomic)Alert *alert;
@property (strong, nonatomic)NSMutableArray *favoriteID;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic)ManagedCoreData *managedCoreData;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UITextField *commentTF;

@end
